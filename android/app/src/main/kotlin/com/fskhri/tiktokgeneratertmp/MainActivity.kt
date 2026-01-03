package com.fskhri.tiktokgeneratertmp

import android.webkit.CookieManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.fskhri.tiktokgeneratertmp/cookies"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getCookies" -> {
                    try {
                        val url = call.argument<String>("url") ?: "https://www.tiktok.com"
                        val cookieManager = CookieManager.getInstance()
                        val cookies = cookieManager.getCookie(url)
                        result.success(cookies)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get cookies: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

