"""Reconstruct serialized run primitives in a fresh Lua VM, without Balatro/disk saves."""
from pathlib import Path
from lupa.lua51 import LuaRuntime
from lupa.luajit21 import LuaRuntime as LuaJITRuntime

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "tests/test_ante_schedule.lua").read_text(encoding="utf-8")

for runtime_type in (LuaRuntime, LuaJITRuntime):
    writer = runtime_type(unpack_returned_tuples=True)
    writer.globals().REPO_ROOT = ROOT.as_posix()
    writer.execute(SOURCE)
    serialized = writer.globals().ANTE_COLD_EXPORT
    assert isinstance(serialized, str) and serialized
    del writer
    reader = runtime_type(unpack_returned_tuples=True)
    reader.globals().REPO_ROOT = ROOT.as_posix()
    reader.globals().ANTE_COLD_IMPORT = serialized
    reader.execute(SOURCE)
    print(f"PASS: {runtime_type.__module__} fresh-VM reconstruction")
