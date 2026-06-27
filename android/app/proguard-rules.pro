-keep class io.agora.** {*;}
-dontwarn  io.agora.**

# Baidu Map SDK references this optional advanced-permission class in some
# artifacts, but the class is not packaged by the Flutter plugin dependency.
-dontwarn com.baidu.mapsdkplatform.comapi.util.MapSDKAdvancedPermission
