package org.rocstreaming.rocdroid

import android.content.Context
import android.util.Log
import androidx.datastore.core.DataStore
import androidx.datastore.core.handlers.ReplaceFileCorruptionHandler
import androidx.datastore.preferences.SharedPreferencesMigration
import androidx.datastore.preferences.core.MutablePreferences
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.io.IOException

private const val LOG_TAG = "[rocdroid.SettingsRepository]"
private const val DATASTORE_NAME = "settings"
internal const val SHARED_PREFERENCES_NAME = "settings"

private val Context.settingsDataStore: DataStore<Preferences> by preferencesDataStore(
    name = DATASTORE_NAME,
    corruptionHandler = ReplaceFileCorruptionHandler { emptyPreferences() },
    produceMigrations = { context ->
        listOf(SharedPreferencesMigration(context, SHARED_PREFERENCES_NAME))
    },
)

class SettingsRepository internal constructor(
    private val dataStore: DataStore<Preferences>,
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.IO),
) {
    private val _settings = MutableStateFlow(AppSettings())
    val settings: StateFlow<AppSettings> = _settings.asStateFlow()

    private val loaded = CompletableDeferred<Unit>()

    init {
        scope.launch {
            try {
                val preferences =
                    dataStore.data
                        .catch { error ->
                            if (error is IOException) {
                                Log.e(LOG_TAG, "Failed to read settings; using defaults", error)
                                emit(emptyPreferences())
                            } else {
                                throw error
                            }
                        }.first()

                _settings.value = preferences.toAppSettings()
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                Log.e(LOG_TAG, "Failed to load settings; using defaults", e)
            } finally {
                loaded.complete(Unit)
            }
        }
    }

    suspend fun awaitLoaded() {
        loaded.await()
    }

    suspend fun snapshot(): AppSettings {
        awaitLoaded()
        return _settings.value
    }

    suspend fun setSourcePort(value: Int) {
        awaitLoaded()
        _settings.update { it.copy(sourcePort = value) }
        persist { it[KEY_SOURCE_PORT] = value }
    }

    suspend fun setRepairPort(value: Int) {
        awaitLoaded()
        _settings.update { it.copy(repairPort = value) }
        persist { it[KEY_REPAIR_PORT] = value }
    }

    suspend fun setSenderConfig(
        receiverIp: String,
        usePlaybackCapture: Boolean,
    ) {
        awaitLoaded()
        _settings.update {
            it.copy(receiverIp = receiverIp, usePlaybackCapture = usePlaybackCapture)
        }
        persist {
            it[KEY_RECEIVER_IP] = receiverIp
            it[KEY_PLAYBACK_CAPTURE] = usePlaybackCapture
        }
    }

    suspend fun setPlaybackVolume(percent: Int) {
        val clamped = PlaybackVolume.clamp(percent)
        awaitLoaded()
        _settings.update { it.copy(playbackVolume = clamped) }
        persist { it[KEY_PLAYBACK_VOLUME] = clamped }
    }

    private suspend fun persist(edit: (MutablePreferences) -> Unit) {
        try {
            dataStore.edit { preferences -> edit(preferences) }
        } catch (e: IOException) {
            Log.e(LOG_TAG, "Failed to save settings", e)
        }
    }

    companion object {
        @Volatile private var instance: SettingsRepository? = null

        fun get(context: Context): SettingsRepository =
            instance ?: synchronized(this) {
                instance ?: SettingsRepository(
                    context.applicationContext.settingsDataStore,
                ).also { instance = it }
            }
    }
}
