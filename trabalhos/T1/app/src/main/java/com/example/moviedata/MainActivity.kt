package com.example.moviedata

import android.content.Intent
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
import com.example.moviedata.utils.Consts
import com.example.moviedata.utils.EnvHelper
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
    private lateinit var btnWantToWatch: Button
    private lateinit var btnFavorites: Button
    private lateinit var btnWatched: Button
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

        EnvHelper.init(this)

        movieDatabase = AppDatabase.getDatabase(applicationContext)

        etMovieTitle = findViewById(R.id.et_movie_title)
        btnSearch = findViewById(R.id.btn_search)
        btnBack = findViewById(R.id.btn_back)
        ivMoviePoster = findViewById(R.id.iv_movie_poster)
        tvMovieTitle = findViewById(R.id.tv_movie_title)
        tvImdbRating = findViewById(R.id.tv_imdb_rating)
        tvMovieDetails = findViewById(R.id.tv_movie_details)
        fab = findViewById(R.id.fab)
        btnWantToWatch = findViewById(R.id.btn_want_to_watch)
        btnWatched = findViewById(R.id.btn_watched)
        btnFavorites = findViewById(R.id.btn_favorites)

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

        btnWantToWatch.setOnClickListener {
            openMovieList(Consts.WantToWatch)
        }

        btnWatched.setOnClickListener {
            openMovieList(Consts.Watched)
        }

        btnFavorites.setOnClickListener {
            openMovieList(Consts.Favorites)
        }

        val movieTitleFromList = intent.getStringExtra("MOVIE_TITLE")
        movieTitleFromList?.let {
            getMovieDetails(it)
        }

        updateListCounts()
    }

    private fun getMovieDetails(title: String) {
        val apiKey = EnvHelper.getApiKey()
        val call = RetrofitClient.instance.getMovieDetails(title, apiKey)

        call.enqueue(object : Callback<MovieResponse> {
            override fun onResponse(call: Call<MovieResponse>, response: Response<MovieResponse>) {
                try {
                    if (response.isSuccessful) {
                        val movie = response.body()
                        if (movie != null && movie.title.isNotEmpty()) {
                            currentMovie = movie
                            tvMovieTitle.text = movie.title
                            tvMovieTitle.visibility = View.VISIBLE

                            val rating = movie.imdbRating.toFloatOrNull() ?: 0f

                            val ratingText = getString(R.string.imdb_rating, movie.imdbRating)
                            tvImdbRating.text = ratingText

                            when {
                                rating > 7 -> tvImdbRating.setBackgroundColor(Color.GREEN)
                                rating in 5.0..7.0 -> tvImdbRating.setBackgroundColor(Color.YELLOW)
                                else -> tvImdbRating.setBackgroundColor(Color.RED)
                            }
                            tvImdbRating.visibility = View.VISIBLE

                            val detailsText = getString(
                                R.string.movie_details,
                                movie.plot,
                                movie.year,
                                movie.rated,
                                movie.released,
                                movie.runtime,
                                movie.genre,
                                movie.director,
                                movie.writer,
                                movie.actors,
                                movie.awards
                            )
                            tvMovieDetails.text = detailsText

                            tvMovieDetails.visibility = View.VISIBLE

                            Glide.with(this@MainActivity)
                                .load(movie.poster)
                                .into(ivMoviePoster)
                            ivMoviePoster.visibility = View.VISIBLE

                            fab.visibility = View.VISIBLE
                        }
                    }
                } catch (e: Exception) {
                    tvMovieDetails.visibility = View.VISIBLE
                    tvMovieDetails.text = getString(R.string.movie_details_error)
                    fab.visibility = View.GONE
                }
            }

            override fun onFailure(call: Call<MovieResponse>, t: Throwable) {
                tvMovieDetails.text = getString(R.string.movie_details_error)
                tvMovieDetails.visibility = View.VISIBLE
                fab.visibility = View.GONE
            }
        })

    }

    override fun onResume() {
        super.onResume()
        updateListCounts()
        // Verifique se currentMovie não é nulo e ajuste a visibilidade do fab
        fab.visibility = if (currentMovie != null) View.VISIBLE else View.GONE
    }

    private fun clearMovieDetails() {
        tvMovieTitle.text = ""
        tvImdbRating.text = ""
        tvImdbRating.setBackgroundColor(Color.TRANSPARENT)
        tvMovieDetails.text = ""
        ivMoviePoster.setImageDrawable(null)
        etMovieTitle.text.clear()
        fab.visibility = View.GONE

        tvMovieTitle.visibility = View.GONE
        tvImdbRating.visibility = View.GONE
        tvMovieDetails.visibility = View.GONE
        ivMoviePoster.visibility = View.GONE

        currentMovie = null // Reset currentMovie
    }

    private fun showAddMovieOptions() {
        val movieTitle = tvMovieTitle.text.toString()
        if (movieTitle.isNotEmpty() && currentMovie != null) {
            val options = arrayOf(Consts.WantToWatch, Consts.Watched, Consts.Favorites)
            val localizedOptions = arrayOf(
                getString(R.string.want_to_watch),
                getString(R.string.watched),
                getString(R.string.favorites)
            )
            AlertDialog.Builder(this)
                .setTitle(getString(R.string.add_to_list_title))
                .setItems(localizedOptions) { _, which ->
                    val listType = options[which]
                    val listText = localizedOptions[which]
                    saveMovie(currentMovie!!, listType, listText)
                }
                .show()
        }
    }

    private fun saveMovie(movieResponse: MovieResponse, listType: String, listText: String) {
        val movie = Movie(
            title = movieResponse.title,
            listType = listType,
            posterUrl = movieResponse.poster,
            rating = movieResponse.imdbRating,
            year = movieResponse.year
        )
        lifecycleScope.launch {
            val existingMovie = movieDatabase.movieDao().getMovieByTitleAndListType(movie.title, movie.listType)
            if (existingMovie == null) {
                movieDatabase.movieDao().insert(movie)
                Snackbar.make(fab, getString(R.string.movie_added_to_list, listText), Snackbar.LENGTH_LONG).show()
                updateListCounts()
            } else {
                Snackbar.make(fab, getString(R.string.movie_already_in_list, listText), Snackbar.LENGTH_LONG).show()
            }
        }
    }


    private fun openMovieList(listType: String) {
        val intent = Intent(this, MovieListActivity::class.java).apply {
            putExtra("LIST_TYPE", listType)
        }
        startActivity(intent)
    }

    private fun updateListCounts() {
        lifecycleScope.launch {
            val wantToWatchCount = movieDatabase.movieDao().countMoviesInList(Consts.WantToWatch)
            val watchedCount = movieDatabase.movieDao().countMoviesInList(Consts.Watched)
            val favoritesCount = movieDatabase.movieDao().countMoviesInList(Consts.Favorites)

            val string_want_to_watch = getString(R.string.want_to_watch)
            val string_watched = getString(R.string.watched)
            val string_favorites = getString(R.string.favorites)

            btnWantToWatch.text = "$string_want_to_watch ($wantToWatchCount)"
            btnWatched.text = "$string_watched ($watchedCount)"
            btnFavorites.text = "$string_favorites ($favoritesCount)"
        }
    }
}
