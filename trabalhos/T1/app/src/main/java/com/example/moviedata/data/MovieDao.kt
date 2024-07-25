package com.example.moviedata.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface MovieDao {
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insert(movie: Movie)

    @Query("SELECT * FROM movies WHERE title = :title")
    suspend fun getMovieByTitle(title: String): Movie?
}
