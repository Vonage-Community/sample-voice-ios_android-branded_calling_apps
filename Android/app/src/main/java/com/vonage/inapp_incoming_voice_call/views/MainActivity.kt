package com.vonage.inapp_incoming_voice_call.views

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.os.Bundle
import android.telecom.Connection
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.vonage.inapp_incoming_voice_call.App
import com.vonage.inapp_incoming_voice_call.api.APIRetrofit
import com.vonage.inapp_incoming_voice_call.databinding.ActivityMainBinding
import com.vonage.inapp_incoming_voice_call.utils.Constants
import com.vonage.inapp_incoming_voice_call.utils.navigateToCallActivity
import com.vonage.inapp_incoming_voice_call.utils.navigateToLoginActivity
import com.vonage.inapp_incoming_voice_call.utils.showToast
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class MainActivity : AppCompatActivity() {
    private val coreContext = App.coreContext
    private val clientManager = coreContext.clientManager
    private lateinit var binding: ActivityMainBinding

    /**
     * This Local BroadcastReceiver will be used
     * to receive messages from other activities
     */
    private val messageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // Call State Updated
            intent?.getStringExtra(CallActivity.CALL_STATE)?.let { callStateExtra ->
                if (callStateExtra == CallActivity.CALL_RINGING) {
                    navigateToCallActivity()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Set Bindings
        setBindings()

        ContextCompat.registerReceiver(
            this,
            messageReceiver,
            IntentFilter(CallActivity.MESSAGE_ACTION),
            ContextCompat.RECEIVER_NOT_EXPORTED
        )

        binding.btcall.setOnClickListener {
            callContactCenter()
        }
    }

    override fun onResume() {
        super.onResume()
        clientManager.sessionId ?: navigateToLoginActivity()
        coreContext.activeCall?.let {
            navigateToCallActivity()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(messageReceiver)
    }

    private fun setBindings(){
        binding.apply {
            clientManager.currentUser?.let {
                tvLoggedInPhone.text = it.name
            }
        }
    }

    private fun callContactCenter(){
        val callContext = mapOf(
            Constants.EXTRA_KEY_TO to "contact center",
        )

        clientManager.startOutboundCall(callContext)
    }
}