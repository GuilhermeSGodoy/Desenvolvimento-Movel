// Crie um arquivo chamado RetrofitClient.kt no pacote network
package com.example.moviedata.network

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import com.example.moviedata.api.OMDbApiService

object RetrofitClient {
    private const val BASE_URL = "http://www.omdbapi.com/?i=tt3896198&apikey="

    val instance: OMDbApiService by lazy {
        val retrofit = Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()

        retrofit.create(OMDbApiService::class.java)
    }
}
