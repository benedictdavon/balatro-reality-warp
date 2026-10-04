"""Run Lua 5.1 source checks and stubbed regressions (requires lupa).

This harness does not execute Balatro or validate rendering/event ordering.
"""
from pathlib import Path
import tomllib
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
compile_lua = lua.eval("function(source, name) local fn, err = loadstring(source, name); return fn ~= nil, err end")
for path in sorted(ROOT.rglob("*.lua")):
    ok, error = compile_lua(path.read_text(encoding="utf-8-sig"), str(path.relative_to(ROOT)))
    assert ok, error
print("PASS: all repository Lua files compile under Lua 5.1")
patterns = tomllib.loads((ROOT / "lovely/lovely.toml").read_text(encoding="utf-8"))
target_patches = [p["pattern"] for p in patterns["patches"] if "pattern" in p
                  and "reality_warp_" in p["pattern"].get("payload", "")
                  and "blind_target" in p["pattern"].get("payload", "")]
assert len(target_patches) == 2, "Expected the two target initialization/preview patches"
def verify_target_patch_source(source, patch):
    normalized_source = "\n".join(line.strip() for line in source.splitlines())
    normalized_payload = "\n".join(line.strip() for line in patch["payload"].strip().splitlines())
    original_count = source.count(patch["pattern"])
    applied_count = normalized_source.count(normalized_payload)
    payload_marker_count = sum(
        1 for line in normalized_source.splitlines()
        if "reality_warp_" in line and "blind_target" in line
    )
    assert (original_count, applied_count, payload_marker_count) in ((1, 0, 0), (0, 1, 1)), (
        f"Expected one original pattern OR one complete applied payload: {patch['target']} "
        f"(original={original_count}, applied={applied_count}, "
        f"payload_markers={payload_marker_count})")

def verify_target_patch_validator_controls(patch):
    original = patch["pattern"]
    payload = patch["payload"].strip()
    applied = "\n".join("    " + line for line in payload.splitlines())
    marker_start = payload.find("reality_warp_")
    marker_end = payload.find("(", marker_start)
    assert marker_start >= 0 and marker_end > marker_start, "Expected a recognizable target payload marker"
    partial = payload[:marker_end + 1]

    verify_target_patch_source(original, patch)
    verify_target_patch_source(applied, patch)

    invalid_sources = (
        "",  # missing
        partial,  # truncated without the original pattern
        original + "\n" + partial,  # original mixed with a partial payload
        original + "\n" + applied,  # original mixed with a complete payload
        original + "\n" + original,  # duplicate original pattern
        applied + "\n" + applied,  # duplicate complete payload
        applied + "\n" + partial,  # complete payload plus a duplicate fragment
    )
    for invalid in invalid_sources:
        try:
            verify_target_patch_source(invalid, patch)
        except AssertionError:
            continue
        raise AssertionError(f"Accepted invalid target patch state: {patch['target']}")

dump = ROOT.parent / "lovely/dump"
for patch in target_patches:
    verify_target_patch_validator_controls(patch)
    ok, error = compile_lua("return function(self, blind, blind_choice, type)\n" + patch["payload"] + "\nend", patch["target"])
    assert ok, error
    if dump.exists():
        source = (dump / patch["target"]).read_text(encoding="utf-8-sig")
        verify_target_patch_source(source, patch)
print("PASS: TOML and target payload compilation; installed original/applied patch counts" if dump.exists()
      else "PASS: TOML and target payload compilation; SKIP installed pattern counts (no dump)")
print("PASS: target patch validator original/applied and missing/partial/duplicate/mixed controls")
for path in sorted((ROOT / "tests").glob("test_*.lua")):
    runtime = LuaRuntime(unpack_returned_tuples=True)
    runtime.globals().REPO_ROOT = ROOT.as_posix()
    runtime.execute(path.read_text(encoding="utf-8"))
    print(f"PASS: {path.name}")
