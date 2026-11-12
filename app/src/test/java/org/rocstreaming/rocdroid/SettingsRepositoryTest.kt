package org.rocstreaming.rocdroid

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.core.handlers.ReplaceFileCorruptionHandler
import androidx.datastore.preferences.SharedPreferencesMigration
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.emptyPreferences
import androidx.test.core.app.ApplicationProvider
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.io.File

@RunWith(RobolectricTestRunner::class)
class SettingsRepositoryTest {
    @get:Rule
    val tempFolder = TemporaryFolder()

    private lateinit var context: Context
    private lateinit var scope: CoroutineScope
    private lateinit var dataStore: DataStore<Preferences>
    private lateinit var repository: SettingsRepository

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        prefs().edit().clear().commit()

        scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
        dataStore = createDataStore(scope, "settings.preferences_pb")
        repository = SettingsRepository(dataStore, scope)
    }

    @After
    fun tearDown() {
        scope.cancel()
        prefs().edit().clear().commit()
    }

    @Test
    fun defaultsWhenStoreIsEmpty() =
        runBlocking {
            repository.awaitLoaded()

            assertEquals(AppSettings(), repository.settings.value)
        }

    @Test
    fun persistsSenderSettings() =
        runBlocking {
            repository.setSenderConfig("10.0.0.7", false)
            repository.setSourcePort(12001)
            repository.setRepairPort(12002)

            val stored = dataStore.data.first()
            assertEquals("10.0.0.7", stored[KEY_RECEIVER_IP])
            assertEquals(12001, stored[KEY_SOURCE_PORT])
            assertEquals(12002, stored[KEY_REPAIR_PORT])
            assertFalse(stored[KEY_PLAYBACK_CAPTURE]!!)

            val current = repository.settings.value
            assertEquals("10.0.0.7", current.receiverIp)
            assertEquals(12001, current.sourcePort)
            assertEquals(12002, current.repairPort)
            assertFalse(current.usePlaybackCapture)
        }

    @Test
    fun persistsPlaybackVolume() =
        runBlocking {
            repository.setPlaybackVolume(42)

            assertEquals(42, dataStore.data.first()[KEY_PLAYBACK_VOLUME])
            assertEquals(42, repository.settings.value.playbackVolume)
        }

    @Test
    fun clampsPlaybackVolumeWhenSaved() =
        runBlocking {
            repository.setPlaybackVolume(150)
            assertEquals(PlaybackVolume.MAX_PERCENT, dataStore.data.first()[KEY_PLAYBACK_VOLUME])
            assertEquals(PlaybackVolume.MAX_PERCENT, repository.settings.value.playbackVolume)

            repository.setPlaybackVolume(-5)
            assertEquals(PlaybackVolume.MIN_PERCENT, dataStore.data.first()[KEY_PLAYBACK_VOLUME])
            assertEquals(PlaybackVolume.MIN_PERCENT, repository.settings.value.playbackVolume)
        }

    @Test
    fun migratesExistingSharedPreferences() =
        runBlocking {
            prefs()
                .edit()
                .putString("receiver_ip", "10.9.8.7")
                .putInt("source_port", 13001)
                .putInt("repair_port", 13002)
                .putBoolean("playback_capture", false)
                .putInt("playback_volume", 42)
                .commit()

            val migrationScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
            try {
                val migratedStore = createDataStore(migrationScope, "migrated.preferences_pb")
                val migrated = SettingsRepository(migratedStore, migrationScope)
                migrated.awaitLoaded()

                assertEquals(
                    AppSettings(
                        receiverIp = "10.9.8.7",
                        sourcePort = 13001,
                        repairPort = 13002,
                        usePlaybackCapture = false,
                        playbackVolume = 42,
                    ),
                    migrated.settings.value,
                )
            } finally {
                migrationScope.cancel()
            }
        }

    private fun createDataStore(
        scope: CoroutineScope,
        fileName: String,
    ): DataStore<Preferences> =
        PreferenceDataStoreFactory.create(
            scope = scope,
            produceFile = { File(tempFolder.root, fileName) },
            corruptionHandler = ReplaceFileCorruptionHandler { emptyPreferences() },
            migrations = listOf(SharedPreferencesMigration(context, "settings")),
        )

    private fun prefs() = context.getSharedPreferences("settings", Context.MODE_PRIVATE)
}
