package com.example.moviedata

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.moviedata.network.MovieResponse
import com.example.moviedata.network.RetrofitClient
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class MainActivity : AppCompatActivity() {

    private lateinit var etMovieTitle: EditText
    private lateinit var btnSearch: Button
    private lateinit var tvMovieDetails: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        etMovieTitle = findViewById(R.id.et_movie_title)
        btnSearch = findViewById(R.id.btn_search)
        tvMovieDetails = findViewById(R.id.tv_movie_details)

        btnSearch.setOnClickListener {
            val title = etMovieTitle.text.toString()
            if (title.isNotEmpty()) {
                getMovieDetails(title)
            }
        }
    }

    private fun getMovieDetails(title: String) {
        val apiKey = "512c45da" // Substitua pela sua chave de API
        val call = RetrofitClient.instance.getMovieDetails(title, apiKey)

        call.enqueue(object : Callback<MovieResponse> {
            override fun onResponse(call: Call<MovieResponse>, response: Response<MovieResponse>) {
                if (response.isSuccessful) {
                    val movie = response.body()
                    movie?.let {
                        tvMovieDetails.text = """
                            Title: ${it.title}
                            Year: ${it.year}
                            Rated: ${it.rated}
                            Released: ${it.released}
                            Runtime: ${it.runtime}
                            Genre: ${it.genre}
                            Director: ${it.director}
                            Writer: ${it.writer}
                            Actors: ${it.actors}
                            Plot: ${it.plot}
                            Language: ${it.language}
                            Country: ${it.country}
                            Awards: ${it.awards}
                            IMDb Rating: ${it.imdbRating}
                        """.trimIndent()
                    }
                } else {
                    tvMovieDetails.text = "Failed to retrieve movie details"
                }
            }

            override fun onFailure(call: Call<MovieResponse>, t: Throwable) {
                tvMovieDetails.text = "Failed to retrieve movie details: ${t.message}"
            }
        })
    }
}