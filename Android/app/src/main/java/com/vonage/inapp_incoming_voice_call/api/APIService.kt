package com.vonage.inapp_incoming_voice_call.api

import com.vonage.inapp_incoming_voice_call.models.User
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.HTTP
import retrofit2.http.POST

interface APIService {
    @POST("user")
    fun getCredential(
        @Body loginInformation: LoginInformation
    ): Call<User>
}