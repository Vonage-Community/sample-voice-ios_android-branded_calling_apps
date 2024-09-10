package com.vonage.inapp_incoming_voice_call.api

import com.vonage.inapp_incoming_voice_call.models.Brand
import com.vonage.inapp_incoming_voice_call.models.User
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query

interface APIService {
    @POST("user")
    fun getCredential(
        @Body loginInformation: LoginInformation
    ): Call<User>

    @GET("token")
    fun getToken(
        @Query("username") username: String
    ): Call<User>

    @GET("brands")
    fun getBrands(): Call<List<Brand>>
}