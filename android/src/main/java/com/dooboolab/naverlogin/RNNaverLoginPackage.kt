package com.dooboolab.naverlogin

import com.facebook.react.ReactPackage
import com.facebook.react.bridge.JavaScriptModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

class RNNaverLoginPackage : ReactPackage {
    override fun createNativeModules(reactContext: ReactApplicationContext) = listOf(RNNaverLoginModule(reactContext))

    // Deprecated from RN 0.47
    override fun createJSModules(): List<Class<out JavaScriptModule?>> = emptyList()

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> = emptyList()
}