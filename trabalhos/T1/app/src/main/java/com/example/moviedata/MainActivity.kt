package com.example.moviedata

import android.graphics.Color
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.bumptech.glide.Glide
import com.example.moviedata.network.MovieResponse
import com.example.moviedata.network.RetrofitClient
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class MainActivity : AppCompatActivity() {

    private lateinit var etMovieTitle: EditText
    private lateinit var btnSearch: Button
    private lateinit var btnBack: Button
    private lateinit var ivMoviePoster: ImageView
    private lateinit var tvMovieTitle: TextView
    private lateinit var tvImdbRating: TextView
    private lateinit var tvMovieDetails: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        etMovieTitle = findViewById(R.id.et_movie_title)
        btnSearch = findViewById(R.id.btn_search)
        btnBack = findViewById(R.id.btn_back)
        ivMoviePoster = findViewById(R.id.iv_movie_poster)
        tvMovieTitle = findViewById(R.id.tv_movie_title)
        tvImdbRating = findViewById(R.id.tv_imdb_rating)
        tvMovieDetails = findViewById(R.id.tv_movie_details)

        btnSearch.setOnClickListener {
            val title = etMovieTitle.text.toString()
            if (title.isNotEmpty()) {
                getMovieDetails(title)
            }
        }

        btnBack.setOnClickListener {
            clearMovieDetails()
        }
    }

    private fun getMovieDetails(title: String) {
        val apiKey = "512c45da"
        val call = RetrofitClient.instance.getMovieDetails(title, apiKey)

        call.enqueue(object : Callback<MovieResponse> {
            override fun onResponse(call: Call<MovieResponse>, response: Response<MovieResponse>) {
                if (response.isSuccessful) {
                    val movie = response.body()
                    movie?.let {
                        tvMovieTitle.text = it.title

                        val rating = it.imdbRating.toFloatOrNull() ?: 0f
                        tvImdbRating.text = "IMDb Rating: ${it.imdbRating}"
                        when {
                            rating > 7 -> tvImdbRating.setBackgroundColor(Color.GREEN)
                            rating in 5.0..7.0 -> tvImdbRating.setBackgroundColor(Color.YELLOW)
                            else -> tvImdbRating.setBackgroundColor(Color.RED)
                        }

                        tvMovieDetails.text = """
                            Plot: ${it.plot}
                            Year: ${it.year}
                            Rated: ${it.rated}
                            Released: ${it.released}
                            Runtime: ${it.runtime}
                            Genre: ${it.genre}
                            Director: ${it.director}
                            Writer: ${it.writer}
                            Actors: ${it.actors}
                            Awards: ${it.awards}
                        """.trimIndent()

                        Glide.with(this@MainActivity)
                            .load(it.poster)
                            .into(ivMoviePoster)
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

    private fun clearMovieDetails() {
        tvMovieTitle.text = ""
        tvImdbRating.text = ""
        tvImdbRating.setBackgroundColor(Color.TRANSPARENT)
        tvMovieDetails.text = ""
        ivMoviePoster.setImageDrawable(null)
        etMovieTitle.text.clear()
    }
}
