package com.example.moviedata.utils

import android.content.Context
import java.util.*

object EnvHelper {
    private lateinit var properties: Properties

    fun init(context: Context) {
        properties = Properties()
        context.assets.open("config.properties").use { inputStream ->
            properties.load(inputStream)
        }
    }

    fun getApiKey(): String {
        return properties.getProperty("API_KEY") ?: throw IllegalStateException("API_KEY is not defined in config.properties file")
    }
}
