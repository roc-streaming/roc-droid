# Roc Toolkit native library
-keep class org.rocstreaming.roctoolkit.** { *; }
-keep interface org.rocstreaming.roctoolkit.** { *; }

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep R class
-keep class org.rocstreaming.rocdroid.R { *; }
-keep class org.rocstreaming.rocdroid.R$* { *; }

# Keep ViewBinding generated classes
-keep class org.rocstreaming.rocdroid.databinding.** { *; }

# Suppress warnings for Roc Toolkit native methods
-dontwarn org.rocstreaming.roctoolkit.**

# Keep native method names
-keepclasseswithmembernames class * {
    native <methods>;
}
