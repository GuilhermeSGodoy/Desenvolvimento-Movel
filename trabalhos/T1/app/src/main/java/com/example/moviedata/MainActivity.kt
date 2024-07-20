package com.example.moviedata

import android.graphics.Color
import android.os.Bundle
import android.view.View
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
                clearMovieDetails() // Limpa as informações do filme antes de uma nova pesquisa
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
                    if (movie != null && movie.title != null && movie.plot != null) { // Verifique se os campos essenciais não são nulos
                        tvMovieTitle.text = movie.title

                        val rating = movie.imdbRating?.toFloatOrNull() ?: 0f
                        tvImdbRating.text = "IMDb Rating: ${movie.imdbRating}"
                        tvImdbRating.setTextColor(getRatingTextColor(rating))
                        when {
                            rating > 7 -> tvImdbRating.setBackgroundColor(Color.GREEN)
                            rating in 5.0..7.0 -> tvImdbRating.setBackgroundColor(Color.YELLOW)
                            else -> tvImdbRating.setBackgroundColor(Color.RED)
                        }

                        tvMovieDetails.text = formatMovieDetails(movie)
                        tvMovieDetails.visibility = View.VISIBLE

                        Glide.with(this@MainActivity)
                            .load(movie.poster)
                            .into(ivMoviePoster)
                    } else {
                        tvMovieDetails.text = "Movie not found, try searching again."
                        tvMovieDetails.visibility = View.VISIBLE
                    }
                } else {
                    tvMovieDetails.text = "Failed to retrieve movie details. Please try again."
                    tvMovieDetails.visibility = View.VISIBLE
                }
            }

            override fun onFailure(call: Call<MovieResponse>, t: Throwable) {
                tvMovieDetails.text = "Failed to retrieve movie details: ${t.message}"
                tvMovieDetails.visibility = View.VISIBLE
            }
        })
    }

    private fun clearMovieDetails() {
        tvMovieTitle.text = ""
        tvImdbRating.text = ""
        tvImdbRating.setBackgroundColor(Color.TRANSPARENT)
        tvMovieDetails.text = ""
        tvMovieDetails.visibility = View.GONE
        ivMoviePoster.setImageDrawable(null)
        etMovieTitle.text.clear()
    }

    private fun getRatingTextColor(rating: Float): Int {
        return when {
            rating > 7 -> Color.BLACK
            rating in 5.0..7.0 -> Color.BLACK
            else -> Color.WHITE
        }
    }

    private fun formatMovieDetails(movie: MovieResponse): String {
        return """
            Plot: ${movie.plot}
            Year: ${movie.year}
            Rated: ${movie.rated}
            Released: ${movie.released}
            Runtime: ${movie.runtime}
            Genre: ${movie.genre}
            Director: ${movie.director}
            Writer: ${movie.writer}
            Actors: ${movie.actors}
            Awards: ${movie.awards}
        """.trimIndent()
    }
}
