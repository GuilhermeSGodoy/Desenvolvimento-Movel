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

    @Query("SELECT * FROM movies WHERE listType = :listType")
    suspend fun getMoviesByListType(listType: String): List<Movie>

    @Query("SELECT COUNT(*) FROM movies WHERE listType = :listType")
    suspend fun countMoviesInList(listType: String): Int

    @Query("SELECT * FROM movies WHERE title = :title AND listType = :listType")
    suspend fun getMovieByTitleAndListType(title: String, listType: String): Movie?

    @Query("DELETE FROM movies WHERE title = :title AND listType = :listType")
    suspend fun deleteMovieByTitleAndListType(title: String, listType: String)
}
