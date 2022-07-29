# PlantUML native image with GraalVM

PlantUML is a tool used to create visualizations for documentation.

It is sometimes convenient to have a tool available as a simple Linux binary
executable file, rather than a Java application, requiring a separate JDK 
installation. One specific use case for this is continuous integration (CI).

This project uses GraalVM to generate and distribute this binary.

The predecessor project, which had required its developer quite a bit of
blood, sweat and tears, is https://github.com/vektory79/plantuml-native-image.

This project starts from scratch, since over the intervening two years, GraalVM
has advanced significantly, requiring quite a bit less custom work for each
application.

