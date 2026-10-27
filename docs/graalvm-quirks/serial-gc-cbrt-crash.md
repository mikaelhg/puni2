# Serial GC crash: "No reference map information found" around `Math.cbrt`

Native images built with the default Serial GC intermittently abort with:

```
Fatal error: No reference map information found
```

The trigger is a GC safepoint reached while a thread is executing
`Math.cbrt`. The garbage collector walks that thread's stack, finds a frame
with no reference map at the stopped instruction, and kills the process.

| GraalVM | GC | Crashes |
|---|---|---|
| Oracle GraalVM 25.0.5.0.3 | Serial | yes |
| GraalVM CE 25.0.2 | Serial | yes |
| Oracle GraalVM 25.0.5.0.3 | G1 | not observed |

Older releases were not tested. The bug was seen on Linux x86-64 with the
default `-march` (`x86-64-v3`).

**Workaround:** build with `--gc=G1` (Oracle GraalVM only), as the
release workflow does.

## How it shows up in PlantUML

PlantUML reaches `Math.cbrt` through Java2D's Marlin renderer when stroking
curves (`sun.java2d.marlin.Helpers.cubicRootsInAB`). Rendering all 296
sample diagrams in one process crashed in about 0.6% of runs on Oracle
GraalVM (2 of 333) and more often on CE 25.0.2 (5 of 139). A crashed run
stops part way through, leaving missing and 0-byte images behind.

The crash dump starts with the frame the GC could not handle:

```
ip: 0x6524638919b1  sp: 0x7c449affbc40  info:CodeInfo@0x7c44a2582b28
Fatal error: No reference map information found
```

and the failing GC thread is in
`com.oracle.svm.core.genscavenge.GCImpl.walkStack`. Matching the `sp` against
the per-thread stack traces further down the dump finds the thread that was
stopped there. In both PlantUML crashes it was a rendering worker:

```
SafepointSlowpath.freezeAtSafepoint(SafepointSlowpath.java:213)
...
SafepointSlowpath.enterSlowPathSafepointCheck(SafepointSlowpath.java:101)
java.lang.Math.cbrt(Math.java:450)
sun.java2d.marlin.Helpers.cubicRootsInAB(Helpers.java)        <- sp from the header
sun.java2d.marlin.Curve.perpendiculardfddf(Curve.java:158)
sun.java2d.marlin.Curve.rootsOfROCMinusW(Curve.java:179)
sun.java2d.marlin.Helpers.findSubdivPoints(Helpers.java:325)
...
sun.java2d.marlin.Stroker._curveTo(Stroker.java:1231)
```

So the caller of `Math.cbrt` has no reference map at that call site, while
`Math.cbrt` itself can stop at a safepoint. This looks like the compiler
treating the `cbrt` call as one that never reaches a safepoint, but this
was not confirmed in the GraalVM sources.

## Reproducer

[CbrtGcRepro.java](CbrtGcRepro.java) runs threads calling `Math.cbrt` in a
loop while the main thread allocates garbage as fast as it can, so
collections land while those threads are inside `cbrt`.

```bash
javac -d classes CbrtGcRepro.java
native-image -cp classes -o repro-serial CbrtGcRepro
native-image --gc=G1 -cp classes -o repro-g1 CbrtGcRepro

./repro-serial 8 5        # 8 cbrt threads, 5 seconds: crashes
./repro-serial 8 5 sqrt   # control, same loop with Math.sqrt: survives
./repro-g1 8 60           # survives
```

| Binary | `cbrt` | `sqrt` (control) |
|---|---|---|
| Oracle 25.0.5, Serial | crashed 5/5, within ~30 ms | 0/5 |
| CE 25.0.2, Serial | crashed 5/5 | 0/3 |
| Oracle 25.0.5, G1 | survived 5 × 5 s and 2 × 60 s | 0/5 |

In the reproducer `cbrt` is inlined into the worker loop, so the crash dump
shows the thread stopped in
`SafepointSlowpath.enterSlowPathSafepointCheckCalleeSavedCCONV` directly from
`Thread.run` instead of from a separate `Math.cbrt` frame. The failure is the
same: no reference map at a safepoint in code containing `Math.cbrt`, and it
only happens when `cbrt` is involved.

## Notes on reproducing intermittent native-image crashes

Repeating the full PlantUML run would have needed hundreds of runs per data
point. What worked better:

1. **Read the crash dump instead of counting crashes.** The `ip:`/`sp:` header
   names the frame the GC choked on; the thread whose stack contains that
   `sp` shows what was running.
2. **Shrink to the suspected code path** and **raise the odds**: many threads
   in the suspect code, an allocation loop forcing constant collections. The
   chance of a crash grows with the number of collections that land while a
   thread is in the vulnerable code.
3. **Keep a control** (`sqrt` here) that differs only in the suspected
   ingredient.

Not needed here, but useful when the dump is less telling:

- `rr record --chaos` records a run with randomised scheduling and replays a
  captured crash deterministically under a debugger.
- Building with `-g` maps crash addresses to source lines in `gdb`.
- `-XX:+PrintGCSummary` and `-XX:+VerboseGC` show how many collections a run
  does, and so how many chances it has to crash.
