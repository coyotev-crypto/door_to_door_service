package com.doortodoor.service

import com.baidu.mapapi.base.BmfMapApplication

class MainApplication : BmfMapApplication() {
    override fun onCreate() {
        super.onCreate()
        // 百度地图 SDK 初始化
        // 注意：flutter_baidu_mapapi_map 插件会自动处理初始化
    }
}
