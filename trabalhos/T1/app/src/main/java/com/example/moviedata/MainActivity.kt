package com.example.moviedata

import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.bumptech.glide.Glide
import com.example.moviedata.data.AppDatabase
import com.example.moviedata.data.Movie
import com.example.moviedata.network.MovieResponse
import com.example.moviedata.network.RetrofitClient
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch
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
    private lateinit var fab: FloatingActionButton

    private lateinit var movieDatabase: AppDatabase

    private var currentMovie: MovieResponse? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        movieDatabase = AppDatabase.getDatabase(applicationContext)

        etMovieTitle = findViewById(R.id.et_movie_title)
        btnSearch = findViewById(R.id.btn_search)
        btnBack = findViewById(R.id.btn_back)
        ivMoviePoster = findViewById(R.id.iv_movie_poster)
        tvMovieTitle = findViewById(R.id.tv_movie_title)
        tvImdbRating = findViewById(R.id.tv_imdb_rating)
        tvMovieDetails = findViewById(R.id.tv_movie_details)
        fab = findViewById(R.id.fab)

        btnSearch.setOnClickListener {
            val title = etMovieTitle.text.toString()
            if (title.isNotEmpty()) {
                getMovieDetails(title)
            }
        }

        btnBack.setOnClickListener {
            clearMovieDetails()
        }

        fab.setOnClickListener {
            showAddMovieOptions()
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
                        currentMovie = it
                        tvMovieTitle.text = it.title
                        tvMovieTitle.visibility = View.VISIBLE

                        val rating = it.imdbRating.toFloatOrNull() ?: 0f
                        tvImdbRating.text = "IMDb Rating: ${it.imdbRating}"
                        when {
                            rating > 7 -> tvImdbRating.setBackgroundColor(Color.GREEN)
                            rating in 5.0..7.0 -> tvImdbRating.setBackgroundColor(Color.YELLOW)
                            else -> tvImdbRating.setBackgroundColor(Color.RED)
                        }
                        tvImdbRating.visibility = View.VISIBLE

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
                        tvMovieDetails.visibility = View.VISIBLE

                        Glide.with(this@MainActivity)
                            .load(it.poster)
                            .into(ivMoviePoster)
                        ivMoviePoster.visibility = View.VISIBLE

                        fab.visibility = View.VISIBLE
                    }
                } else {
                    tvMovieDetails.text = "Failed to retrieve movie details"
                    tvMovieDetails.visibility = View.VISIBLE
                    fab.visibility = View.GONE
                }
            }

            override fun onFailure(call: Call<MovieResponse>, t: Throwable) {
                tvMovieDetails.text = "Failed to retrieve movie details: ${t.message}"
                tvMovieDetails.visibility = View.VISIBLE
                fab.visibility = View.GONE
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
        fab.visibility = View.GONE
    }

    private fun showAddMovieOptions() {
        val movieTitle = tvMovieTitle.text.toString()
        if (movieTitle.isNotEmpty() && currentMovie != null) {
            val options = arrayOf("Assistidos", "Quero Assistir", "Favoritos")
            AlertDialog.Builder(this)
                .setTitle("Adicionar à lista")
                .setItems(options) { _, which ->
                    val listType = options[which]
                    saveMovie(currentMovie!!, listType)
                }
                .show()
        }
    }

    private fun saveMovie(movieResponse: MovieResponse, listType: String) {
        val movie = Movie(
            title = movieResponse.title,
            listType = listType
        )
        lifecycleScope.launch {
            movieDatabase.movieDao().insert(movie)
            Snackbar.make(fab, "Filme adicionado à lista $listType", Snackbar.LENGTH_LONG).show()
        }
    }
}
