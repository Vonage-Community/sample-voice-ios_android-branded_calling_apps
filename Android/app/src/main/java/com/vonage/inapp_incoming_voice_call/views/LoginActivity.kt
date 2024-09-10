package com.vonage.inapp_incoming_voice_call.views
import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.vonage.inapp_incoming_voice_call.App
import com.vonage.inapp_incoming_voice_call.api.APIRetrofit
import com.vonage.inapp_incoming_voice_call.api.LoginInformation
import com.vonage.inapp_incoming_voice_call.databinding.ActivityLoginBinding
import com.vonage.inapp_incoming_voice_call.models.User
import com.vonage.inapp_incoming_voice_call.utils.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class LoginActivity : AppCompatActivity() {

    companion object {
        private const val PERMISSIONS_REQUEST_CODE = 123
    }

    // Only permission with a 'dangerous' Protection Level
    // need to be requested explicitly
    private val permissions = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU)
        arrayOf(
            Manifest.permission.POST_NOTIFICATIONS,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.CALL_PHONE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.MANAGE_OWN_CALLS,
            Manifest.permission.ANSWER_PHONE_CALLS,
            Manifest.permission.READ_PHONE_NUMBERS,
        )
        else arrayOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.CALL_PHONE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.MANAGE_OWN_CALLS,
            Manifest.permission.ANSWER_PHONE_CALLS,
            Manifest.permission.READ_PHONE_NUMBERS,
        )
    private val arePermissionsGranted : Boolean get() {
        return permissions.all {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
        }
    }
    private val coreContext = App.coreContext
    private val clientManager = coreContext.clientManager
    private lateinit var binding: ActivityLoginBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)

        checkPermissions()

        // Submit Form
        binding.btLogin.setOnClickListener {
            val phoneNumber = binding.etPhoneNumber.text.toString()

            if ( phoneNumber == "") {
                showToast(this, "Missing/Wrong User Information")

                return@setOnClickListener
            }
            login(phoneNumber)
        }

        binding.btSignUp.setOnClickListener {
            val phoneNumber = binding.etPhoneNumber.text.toString()

            if ( phoneNumber == "") {
                showToast(this, "Missing/Wrong User Information")

                return@setOnClickListener
            }
            login(phoneNumber, true)
        }
    }

    override fun onResume() {
        super.onResume()
        clientManager.sessionId?.let {
            navigateToMainActivity()
            return
        }
        if (coreContext.user != null && coreContext.authToken != null) {
            // Refresh token
            login(coreContext.user!!.name)
        }
    }
    private fun login(phoneNumber: String, newUser: Boolean = false) {
        binding.btLogin.isEnabled = false
        // Loading spinner
        binding.pbLogin.visibility = View.VISIBLE
        binding.clSignInForm.visibility = View.GONE

        binding.etPhoneNumber.clearFocus()

        var apiRetro = APIRetrofit.instance.getToken(phoneNumber)
        if (newUser) {
            apiRetro = APIRetrofit.instance.getCredential(LoginInformation(phoneNumber))
        }

        apiRetro.enqueue(object: Callback<User> {
            override fun onResponse(call: Call<User>, response: Response<User>) {
                if (response.isSuccessful) {
                    response.body()?.let { it1 ->
                        clientManager.login(it1.token, onSuccessCallback = {
                            navigateToMainActivity()
                        }, onErrorCallback = {
                            Handler(Looper.getMainLooper()).post {
                                binding.btLogin.isEnabled = true
                                binding.pbLogin.visibility = View.GONE
                                binding.clSignInForm.visibility = View.VISIBLE
                            }
                        })


                    }
                }
                else {
                    Handler(Looper.getMainLooper()).post {
                        binding.btLogin.isEnabled = true
                        binding.pbLogin.visibility = View.GONE
                        binding.clSignInForm.visibility = View.VISIBLE
                        showAlert(this@LoginActivity, "Failed to get Credential", false)
                    }
                }
            }

            override fun onFailure(call: Call<User>, t: Throwable) {
                binding.btLogin.isEnabled = true
                binding.pbLogin.visibility = View.GONE
                binding.clSignInForm.visibility = View.VISIBLE
                showAlert(this@LoginActivity, "Failed to get Credential", false)
            }

        })
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if(arePermissionsGranted){
            coreContext.telecomHelper
        }
    }

    private fun checkPermissions() {
        if (!arePermissionsGranted) {
            // Request permissions
            ActivityCompat.requestPermissions(this, permissions, PERMISSIONS_REQUEST_CODE)
        }else {
            coreContext.telecomHelper
        }
    }

}