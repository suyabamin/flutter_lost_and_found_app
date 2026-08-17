# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.iid.**
-keep class com.google.firebase.iid.** { *; }

# ML Kit - Text Recognition (all scripts)
-keep class com.google.mlkit.** { *; }
-keep class com.google_mlkit_** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google_mlkit_**

# ML Kit text recognition scripts
-dontwarn com.google.mlkit.vision.text.chinese.**
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-dontwarn com.google.mlkit.vision.text.devanagari.**
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-dontwarn com.google.mlkit.vision.text.japanese.**
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.korean.** { *; }

# ML Kit link firebase
-dontwarn com.google.mlkit.linkfirebase.**
-keep class com.google.mlkit.linkfirebase.** { *; }

# Suppress all other missing class warnings
-dontwarn **
