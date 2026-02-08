package com.susu.diary

import android.media.MediaRecorder
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.susu.diary/recorder"
    private var mediaRecorder: MediaRecorder? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startRecording" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("NO_PATH", "Path is required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        mediaRecorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            MediaRecorder(this)
                        } else {
                            @Suppress("DEPRECATION")
                            MediaRecorder()
                        }
                        mediaRecorder?.apply {
                            setAudioSource(MediaRecorder.AudioSource.MIC)
                            setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                            setAudioEncodingBitRate(128000)
                            setAudioSamplingRate(44100)
                            setOutputFile(path)
                            prepare()
                            start()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("RECORD_ERROR", e.message, null)
                    }
                }
                "stopRecording" -> {
                    try {
                        mediaRecorder?.apply {
                            stop()
                            release()
                        }
                        mediaRecorder = null
                        result.success(true)
                    } catch (e: Exception) {
                        mediaRecorder = null
                        result.error("STOP_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}