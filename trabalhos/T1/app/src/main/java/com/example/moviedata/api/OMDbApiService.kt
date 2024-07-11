package com.example.moviedata.api

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query
import com.example.moviedata.network.MovieResponse

interface OMDbApiService {
    @GET("/")
    fun getMovieDetails(
        @Query("t") title: String,
        @Query("apikey") apiKey: String
    ): Call<MovieResponse>
}
