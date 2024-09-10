package com.vonage.inapp_incoming_voice_call.views

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.vonage.inapp_incoming_voice_call.App
import com.vonage.inapp_incoming_voice_call.api.APIRetrofit
import com.vonage.inapp_incoming_voice_call.databinding.ActivityMainBinding
import com.vonage.inapp_incoming_voice_call.models.Brand
import com.vonage.inapp_incoming_voice_call.utils.Constants
import com.vonage.inapp_incoming_voice_call.utils.navigateToCallActivity
import com.vonage.inapp_incoming_voice_call.utils.navigateToLoginActivity
import com.vonage.inapp_incoming_voice_call.utils.showAlert
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class MainActivity : AppCompatActivity() {
    private val coreContext = App.coreContext
    private val clientManager = coreContext.clientManager
    private var selectedBrand = ""
    private lateinit var brandList: List<String>
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

        APIRetrofit.instance.getBrands().enqueue(object: Callback<List<Brand>> {
            override fun onResponse(call: Call<List<Brand>>, response: Response<List<Brand>>) {
                if (response.isSuccessful) {
                    response.body()?.let { it1 ->
                        brandList = it1.map { brandPair ->  brandPair.brand}
                        val brandsAdaptor = ArrayAdapter(this@MainActivity, android.R.layout.simple_spinner_dropdown_item, brandList)
                        binding.spBrand.adapter = brandsAdaptor
                    }
                }
                else {
                    Handler(Looper.getMainLooper()).post {
                        showAlert(this@MainActivity, "Failed to get Brands", false)
                    }
                }
            }

            override fun onFailure(call: Call<List<Brand>>, t: Throwable) {
                showAlert(this@MainActivity, "Failed to get Brands", false)
            }

        })
    }

    override fun onResume() {
        super.onResume()
        clientManager.sessionId ?: navigateToLoginActivity()
        coreContext.activeCall?.let {
            navigateToCallActivity()
        }
        binding.btCall.isEnabled = true
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

            spBrand.onItemSelectedListener = object: AdapterView.OnItemSelectedListener {
                override fun onItemSelected(p0: AdapterView<*>?, p1: View?, p2: Int, p3: Long) {
                    selectedBrand = brandList[p2]
                }

                override fun onNothingSelected(p0: AdapterView<*>?) {
                    TODO("Not yet implemented")
                }

            }

            btCall.setOnClickListener {
                // prevent double submit
                if (selectedBrand.isEmpty()) {
                    return@setOnClickListener
                }
                binding.btCall.isEnabled = false
                callContactCenter(selectedBrand)
            }
        }
    }

    private fun callContactCenter(selectedBrand: String){
        val callContext = mapOf(
            Constants.EXTRA_KEY_TO to selectedBrand,
        )

        clientManager.startOutboundCall(callContext)
    }
}