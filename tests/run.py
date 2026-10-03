"""Run Lua 5.1 source checks and stubbed regressions (requires lupa).

This harness does not execute Balatro or validate rendering/event ordering.
"""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
compile_lua = lua.eval("function(source, name) local fn, err = loadstring(source, name); return fn ~= nil, err end")
for path in sorted(ROOT.rglob("*.lua")):
    ok, error = compile_lua(path.read_text(encoding="utf-8-sig"), str(path.relative_to(ROOT)))
    assert ok, error
print("PASS: all repository Lua files compile under Lua 5.1")
for path in sorted((ROOT / "tests").glob("test_*.lua")):
    runtime = LuaRuntime(unpack_returned_tuples=True)
    runtime.globals().REPO_ROOT = ROOT.as_posix()
    runtime.execute(path.read_text(encoding="utf-8"))
    print(f"PASS: {path.name}")
