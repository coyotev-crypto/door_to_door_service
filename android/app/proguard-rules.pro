# Baidu Map SDK 3.9.9 rules for flutter_baidu_mapapi_map/utils/search.
# Some SDK artifacts reference optional classes that are not packaged by the
# Flutter plugin dependencies, so they must be suppressed with dontwarn.

# 保留百度地图所有类
-keep class com.baidu.** { *; }
-keep class vi.com.** { *; }
-keep class com.baidu.mapsdkplatform.** { *; }
-keep class com.baidu.bmfmap.** { *; }
-keep class com.baidu.flutter_bmflocation.** { *; }
-keep class com.baidu.mapapi.search.** { *; }
-keep class com.baidu.mapapi.utils.** { *; }

# 保留百度地图 protobuf 相关类
-keep class com.baidu.entity.pb.** { *; }
-dontwarn com.baidu.entity.pb.**
-dontwarn com.baidu.mapsdkplatform.comapi.util.MapSDKAdvancedPermission

# 保留使用了 Native 方法的类
-keepclasseswithmembernames class com.baidu.** {
    native <methods>;
}

# 保留所有 JNI 相关类
-keep class com.baidu.platform.comjni.** { *; }

# 如果使用了百度地图的导航或其他模块，可能需要额外添加
-keep class com.baidu.navisdk.** { *; }
-keep class com.baidu.location.** { *; }
