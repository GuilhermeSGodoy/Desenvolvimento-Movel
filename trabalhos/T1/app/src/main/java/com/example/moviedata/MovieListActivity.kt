package com.example.moviedata

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.moviedata.data.AppDatabase
import com.example.moviedata.data.Movie
import com.example.moviedata.data.MovieAdapter
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class MovieListActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var movieAdapter: MovieAdapter
    private lateinit var movieDatabase: AppDatabase

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_movie_list)

        movieDatabase = AppDatabase.getDatabase(applicationContext)

        recyclerView = findViewById(R.id.recycler_view)
        recyclerView.layoutManager = LinearLayoutManager(this)
        movieAdapter = MovieAdapter(
            { movie -> showMovieDetails(movie.title) },
            { movie -> showRemoveDialog(movie) }
        )
        recyclerView.adapter = movieAdapter

        val listType = intent.getStringExtra("LIST_TYPE")
        listType?.let {
            fetchMoviesByListType(it)
        }
    }

    private fun fetchMoviesByListType(listType: String) {
        lifecycleScope.launch {
            val movies = movieDatabase.movieDao().getMoviesByListType(listType)
            movieAdapter.submitList(movies)
        }
    }

    private fun showMovieDetails(title: String) {
        val intent = Intent(this, MainActivity::class.java).apply {
            putExtra("MOVIE_TITLE", title)
        }
        startActivity(intent)
    }

    private fun showRemoveDialog(movie: Movie) {
        AlertDialog.Builder(this)
            .setTitle("Remover Filme")
            .setMessage("Deseja remover esse filme da lista?")
            .setPositiveButton("Sim") { _, _ ->
                removeMovie(movie)
            }
            .setNegativeButton("Não", null)
            .show()
    }

    private fun removeMovie(movie: Movie) {
        lifecycleScope.launch {
            movieDatabase.movieDao().deleteMovieByTitleAndListType(movie.title, movie.listType)
            fetchMoviesByListType(movie.listType)
            Snackbar.make(recyclerView, "Filme removido da lista", Snackbar.LENGTH_LONG).show()
        }
    }
}
