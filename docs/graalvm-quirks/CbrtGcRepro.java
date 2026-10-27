// Minimal reproducer candidate for the native-image GC crash
// "Fatal error: No reference map information found".
//
// Both PlantUML crashes had a worker thread parked at a safepoint inside
// Math.cbrt, called from sun.java2d.marlin.Helpers.cubicRootsInAB, and the
// GC failed to find a reference map for the caller frame at that call site.
//
// Usage: CbrtGcRepro [cbrtThreads] [seconds] [mode]
//   mode: cbrt (default) | sqrt (control: same loop without cbrt)
public class CbrtGcRepro {

    static volatile double sink;
    static volatile Object keep;

    public static void main(String[] args) throws Exception {
        int threads = args.length > 0 ? Integer.parseInt(args[0]) : 4;
        long seconds = args.length > 1 ? Long.parseLong(args[1]) : 10;
        boolean cbrt = !(args.length > 2 && args[2].equals("sqrt"));

        for (int t = 0; t < threads; t++) {
            Thread th = new Thread(() -> {
                double[] pts = new double[4];
                while (true) {
                    sink = roots(pts, cbrt);
                }
            });
            th.setDaemon(true);
            th.start();
        }

        // Allocate garbage constantly so collections (and safepoints) happen
        // as often as possible while the other threads sit in cbrt.
        long end = System.nanoTime() + seconds * 1_000_000_000L;
        long gcs = 0;
        while (System.nanoTime() < end) {
            Object[] junk = new Object[256];
            for (int i = 0; i < junk.length; i++) {
                junk[i] = new byte[4096];
            }
            keep = junk;
            gcs++;
        }
        System.out.println("survived " + seconds + "s, mode=" + (cbrt ? "cbrt" : "sqrt")
                + ", threads=" + threads + ", allocation rounds=" + gcs);
    }

    // Shaped like Helpers.cubicRootsInAB: an object reference (pts) is live
    // across the math call, so the frame needs a reference map there.
    static double roots(double[] pts, boolean cbrt) {
        double s = 0;
        for (int k = 1; k < 1000; k++) {
            double v = k * 0.37 + pts[k & 3];
            s += cbrt ? Math.cbrt(v) : Math.sqrt(v);
            pts[k & 3] = s * 1e-9;
        }
        return s;
    }
}
