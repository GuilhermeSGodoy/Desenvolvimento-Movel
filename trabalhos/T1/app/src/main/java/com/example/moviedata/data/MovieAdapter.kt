package com.example.moviedata.data

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.moviedata.R

class MovieAdapter(
    private val onMovieClick: (Movie) -> Unit,
    private val onMovieLongClick: (Movie) -> Unit
) : ListAdapter<Movie, MovieAdapter.MovieViewHolder>(MovieDiffCallback()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MovieViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_movie, parent, false)
        return MovieViewHolder(view)
    }

    override fun onBindViewHolder(holder: MovieViewHolder, position: Int) {
        val movie = getItem(position)
        holder.bind(movie, onMovieClick, onMovieLongClick)
    }

    class MovieViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val ivPoster: ImageView = itemView.findViewById(R.id.iv_poster)
        private val tvTitle: TextView = itemView.findViewById(R.id.tv_title)
        private val tvYear: TextView = itemView.findViewById(R.id.tv_year)
        private val tvRating: TextView = itemView.findViewById(R.id.tv_rating)

        fun bind(movie: Movie, onMovieClick: (Movie) -> Unit, onMovieLongClick: (Movie) -> Unit) {
            tvTitle.text = movie.title
            tvYear.text = movie.year
            tvRating.text = movie.rating

            val rating = movie.rating?.toFloatOrNull() ?: 0f
            val drawable = tvRating.background as GradientDrawable
            drawable.cornerRadius = 16f
            drawable.setStroke(2, Color.BLACK)

            val backgroundColor = when {
                rating > 7 -> Color.GREEN
                rating in 5.0..7.0 -> Color.YELLOW
                else -> Color.RED
            }
            drawable.setColor(backgroundColor)

            Glide.with(itemView.context)
                .load(movie.posterUrl)
                .into(ivPoster)

            itemView.setOnClickListener { onMovieClick(movie) }
            itemView.setOnLongClickListener {
                onMovieLongClick(movie)
                true
            }
        }
    }

    class MovieDiffCallback : DiffUtil.ItemCallback<Movie>() {
        override fun areItemsTheSame(oldItem: Movie, newItem: Movie): Boolean {
            return oldItem.id == newItem.id
        }

        override fun areContentsTheSame(oldItem: Movie, newItem: Movie): Boolean {
            return oldItem == newItem
        }
    }
}
