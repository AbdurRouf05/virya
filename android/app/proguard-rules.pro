# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core (unused in standalone offline app)
-dontwarn com.google.android.play.core.**

# Virya custom native classes
-keep class com.abdurrouf.virya.** { *; }

# SQLite
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# Keep annotations and signatures
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod
