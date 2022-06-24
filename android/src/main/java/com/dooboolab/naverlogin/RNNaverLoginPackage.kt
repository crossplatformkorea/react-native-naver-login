package com.dooboolab.naverlogin

import android.view.View
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.JavaScriptModule
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ReactShadowNode
import com.facebook.react.uimanager.ViewManager

class RNNaverLoginPackage : ReactPackage {
    override fun createNativeModules(
        reactContext: ReactApplicationContext?
    ): MutableList<NativeModule> {
        return mutableListOf(RNNaverLoginModule(reactContext))
    }

    override fun createJSModules(): MutableList<Class<out JavaScriptModule>> {
        return mutableListOf()
    }

    override fun createViewManagers(
        reactContext: ReactApplicationContext?
    ): MutableList<ViewManager<View, ReactShadowNode>> {
        return mutableListOf()
    }
}
