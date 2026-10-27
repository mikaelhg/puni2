package puni2;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Native image entrypoint wrapping PlantUML's own main class.
 *
 * A native image has no java.home, but AWT font setup on Linux requires one
 * (sun.awt.FontConfiguration throws "java.home property not set"). It also
 * requires $java.home/lib to exist: otherwise FontConfiguration never falls
 * through to the libfontconfig based FcFontConfiguration, and every diagram
 * renders as an empty file. The build ships an empty lib/ next to the
 * executable for this purpose.
 */
public class Main {

    public static void main(String[] args) throws Exception {
        if (System.getProperty("java.home") == null) {
            System.setProperty("java.home", javaHome());
        }
        net.sourceforge.plantuml.Run.main(args);
    }

    private static String javaHome() {
        try {
            Path exeDir = Files.readSymbolicLink(Paths.get("/proc/self/exe")).getParent();
            if (exeDir != null && Files.isDirectory(exeDir.resolve("lib"))) {
                return exeDir.toString();
            }
        } catch (Exception e) {
            // fall through
        }
        // Any directory with a lib/ subdirectory works; /usr/lib exists on every Linux
        return File.separator + "usr";
    }
}
