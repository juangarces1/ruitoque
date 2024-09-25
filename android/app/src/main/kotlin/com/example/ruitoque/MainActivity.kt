package com.example.ruitoque

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.ruitoque/communication"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendMessage") {
                val message = call.argument<String>("message")
                if (message != null) {
                    sendMessageToWearable(message)
                    result.success(null)
                } else {
                    result.error("ERROR", "Mensaje nulo", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendMessageToWearable(message: String) {
        Wearable.getNodeClient(this).connectedNodes
            .addOnSuccessListener { nodes ->
                for (node in nodes) {
                    Wearable.getMessageClient(this)
                        .sendMessage(node.id, "/message_path", message.toByteArray())
                        .addOnSuccessListener {
                            println("Mensaje enviado a ${node.displayName}")
                        }
                        .addOnFailureListener { e ->
                            println("Error al enviar mensaje: ${e.message}")
                        }
                }
            }
            .addOnFailureListener { e ->
                println("Error al obtener nodos conectados: ${e.message}")
            }
    }
}
