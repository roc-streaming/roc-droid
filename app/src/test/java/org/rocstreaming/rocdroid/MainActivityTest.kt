package org.rocstreaming.rocdroid

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.ComponentName
import android.content.DialogInterface
import android.content.Intent
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import androidx.appcompat.app.AlertDialog
import androidx.test.core.app.ActivityScenario
import androidx.test.core.app.ApplicationProvider
import com.google.android.material.tabs.TabLayout
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.any
import org.mockito.kotlin.anyOrNull
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.never
import org.mockito.kotlin.same
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.shadows.ShadowDialog
import org.robolectric.shadows.ShadowToast

/**
 * Drives the real [MainActivity] and its fragments. Only [SenderReceiverService] is replaced,
 * because the real one needs the native Roc library and audio hardware.
 */
@RunWith(RobolectricTestRunner::class)
class MainActivityTest {
    private lateinit var application: Application
    private lateinit var service: SenderReceiverService

    @Before
    fun setUp() {
        application = ApplicationProvider.getApplicationContext()
        service = mock()

        shadowOf(application).grantPermissions(Manifest.permission.POST_NOTIFICATIONS)
        shadowOf(application).setComponentNameAndServiceForBindService(
            ComponentName(application, SenderReceiverService::class.java),
            service.LocalBinder(),
        )
    }

    @After
    fun tearDown() =
        runBlocking {
            // The settings repository is a process-wide singleton: undo what a test changed.
            val repository = SettingsRepository.get(application)
            repository.setSourcePort(AppSettings.DEFAULT_SOURCE_PORT)
            repository.setRepairPort(AppSettings.DEFAULT_REPAIR_PORT)
        }

    @Test
    fun launchShowsReceiverAndSenderTabs() {
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            scenario.onActivity { activity ->
                val tabs = activity.findViewById<TabLayout>(R.id.tabs)
                val titles = (0 until tabs.tabCount).map { tabs.getTabAt(it)?.text.toString() }

                assertEquals(listOf("Receiver", "Sender"), titles)
            }
        }
    }

    @Test
    fun startReceiverReachesServiceAfterActivityIsRecreated() {
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            scenario.recreate()

            scenario.onActivity { activity ->
                activity.findViewById<Button>(R.id.startReceiverButton).performClick()
            }

            verify(service).startReceiver()
        }
    }

    @Test
    fun showsStopButtonWhenReceiverIsAlreadyRunning() {
        whenever(service.isReceiverAlive()).thenReturn(true)

        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            scenario.onActivity { activity ->
                assertEquals("Stop receiver", startReceiverButtonText(activity))
            }
        }
    }

    @Test
    fun marksReceiverTabWhenReceiverIsAlreadyRunning() {
        whenever(service.isReceiverAlive()).thenReturn(true)

        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            scenario.onActivity { activity ->
                assertEquals(255, tabIndicatorAlpha(activity, RECEIVER_TAB))
                assertEquals(0, tabIndicatorAlpha(activity, SENDER_TAB))
            }
        }
    }

    @Test
    fun followsReceiverStateReportedByService() {
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            val listener = argumentCaptor<(Boolean) -> Unit>()
            verify(service).setReceiverStateChangedListeners(listener.capture())

            listener.firstValue(true)
            shadowOf(Looper.getMainLooper()).idle()

            scenario.onActivity { activity ->
                assertEquals("Stop receiver", startReceiverButtonText(activity))
                assertEquals(255, tabIndicatorAlpha(activity, RECEIVER_TAB))
            }

            listener.firstValue(false)
            shadowOf(Looper.getMainLooper()).idle()

            scenario.onActivity { activity ->
                assertEquals("Start receiver", startReceiverButtonText(activity))
                assertEquals(0, tabIndicatorAlpha(activity, RECEIVER_TAB))
            }
        }
    }

    @Test
    fun sourcePortCanBeEditedFromSenderTab() {
        launchOnSenderTab().use { scenario ->
            scenario.onActivity { activity ->
                viewDescribedAs(activity, "Edit source stream port").performClick()
            }

            enterPortInDialog("12001")

            assertEquals(12001, awaitSettings { it.sourcePort == 12001 }.sourcePort)
        }
    }

    @Test
    fun repairPortCanBeEditedFromSenderTab() {
        launchOnSenderTab().use { scenario ->
            scenario.onActivity { activity ->
                viewDescribedAs(activity, "Edit repair stream port").performClick()
            }

            enterPortInDialog("12002")

            assertEquals(12002, awaitSettings { it.repairPort == 12002 }.repairPort)
        }
    }

    @Test
    fun rejectsPortThatAnAppCannotListenOn() {
        launchOnSenderTab().use { scenario ->
            scenario.onActivity { activity ->
                viewDescribedAs(activity, "Edit source stream port").performClick()
            }

            enterPortInDialog("80")

            assertEquals(INVALID_PORT_MESSAGE, ShadowToast.getTextOfLatestToast())
            assertEquals(AppSettings.DEFAULT_SOURCE_PORT, settledSettings().sourcePort)
        }
    }

    @Test
    fun rejectsEmptyPort() {
        launchOnSenderTab().use { scenario ->
            scenario.onActivity { activity ->
                viewDescribedAs(activity, "Edit source stream port").performClick()
            }

            enterPortInDialog("")

            assertEquals(INVALID_PORT_MESSAGE, ShadowToast.getTextOfLatestToast())
            assertEquals(AppSettings.DEFAULT_SOURCE_PORT, settledSettings().sourcePort)
        }
    }

    @Test
    fun rejectsPortAlreadyUsedByTheOtherStream() {
        launchOnSenderTab().use { scenario ->
            scenario.onActivity { activity ->
                viewDescribedAs(activity, "Edit repair stream port").performClick()
            }

            enterPortInDialog(AppSettings.DEFAULT_SOURCE_PORT.toString())

            assertEquals(INVALID_PORT_MESSAGE, ShadowToast.getTextOfLatestToast())
            assertEquals(AppSettings.DEFAULT_REPAIR_PORT, settledSettings().repairPort)
        }
    }

    @Test
    fun playbackCaptureSenderStartsOnlyAfterCaptureConsent() {
        shadowOf(application).grantPermissions(Manifest.permission.RECORD_AUDIO)

        launchOnSenderTab().use { scenario ->
            scenario.onActivity { activity ->
                activity.findViewById<Button>(R.id.startSenderButton).performClick()
            }
            val request = awaitCaptureConsentRequest(scenario)

            // Until the user has agreed nothing may start: Android 14+ refuses a media
            // projection foreground service at this point.
            verify(service, never()).startProjectionSender(any(), any(), any())
            verify(service, never()).startSender(any(), anyOrNull())

            val consent = Intent()
            scenario.onActivity { activity ->
                shadowOf(activity).receiveResult(request, Activity.RESULT_OK, consent)
            }

            verify(service).startProjectionSender(
                eq(AppSettings.DEFAULT_RECEIVER_IP),
                eq(Activity.RESULT_OK),
                same(consent),
            )
        }
    }

    @Test
    fun declinedCaptureConsentStartsNothing() {
        shadowOf(application).grantPermissions(Manifest.permission.RECORD_AUDIO)

        launchOnSenderTab().use { scenario ->
            scenario.onActivity { activity ->
                activity.findViewById<Button>(R.id.startSenderButton).performClick()
            }
            val request = awaitCaptureConsentRequest(scenario)

            scenario.onActivity { activity ->
                shadowOf(activity).receiveResult(request, Activity.RESULT_CANCELED, null)
            }

            verify(service, never()).startProjectionSender(any(), any(), any())
            verify(service, never()).startSender(any(), anyOrNull())
        }
    }

    private fun awaitCaptureConsentRequest(scenario: ActivityScenario<MainActivity>): Intent {
        repeat(100) {
            shadowOf(Looper.getMainLooper()).idle()

            var request: Intent? = null
            scenario.onActivity { activity ->
                request = shadowOf(activity).peekNextStartedActivityForResult()?.intent
            }
            request?.let { return it }

            Thread.sleep(20)
        }
        throw AssertionError("the capture consent prompt was not requested")
    }

    private fun launchOnSenderTab(): ActivityScenario<MainActivity> =
        ActivityScenario.launch(
            Intent(application, MainActivity::class.java).putExtra("open_sender_tab", true),
        )

    private fun viewDescribedAs(
        activity: MainActivity,
        description: String,
    ): View {
        val matches = ArrayList<View>()
        activity.window.decorView.findViewsWithText(
            matches,
            description,
            View.FIND_VIEWS_WITH_CONTENT_DESCRIPTION,
        )

        assertEquals("views described as \"$description\"", 1, matches.size)
        return matches.single()
    }

    private fun enterPortInDialog(port: String) {
        val dialog = ShadowDialog.getLatestDialog()
        assertNotNull("a port dialog should be showing", dialog)

        firstEditText(dialog.window!!.decorView)!!.setText(port)
        (dialog as AlertDialog).getButton(DialogInterface.BUTTON_POSITIVE).performClick()
        shadowOf(Looper.getMainLooper()).idle()
    }

    private fun firstEditText(view: View): EditText? =
        when (view) {
            is EditText -> view
            is ViewGroup -> (0 until view.childCount).firstNotNullOfOrNull { firstEditText(view.getChildAt(it)) }
            else -> null
        }

    private fun settings(): AppSettings = SettingsRepository.get(application).settings.value

    // Saving goes through a coroutine that hops to an I/O thread and back to the main looper.
    private fun awaitSettings(condition: (AppSettings) -> Boolean): AppSettings {
        repeat(100) {
            shadowOf(Looper.getMainLooper()).idle()
            if (condition(settings())) return settings()
            Thread.sleep(20)
        }
        return settings()
    }

    // Gives a save that should not happen the chance to happen anyway.
    private fun settledSettings(): AppSettings {
        repeat(10) {
            shadowOf(Looper.getMainLooper()).idle()
            Thread.sleep(20)
        }
        return settings()
    }

    private fun startReceiverButtonText(activity: MainActivity): String =
        activity.findViewById<Button>(R.id.startReceiverButton).text.toString()

    private fun tabIndicatorAlpha(
        activity: MainActivity,
        tab: Int,
    ): Int = activity.findViewById<TabLayout>(R.id.tabs).getTabAt(tab)!!.icon!!.alpha

    private companion object {
        const val RECEIVER_TAB = 0
        const val SENDER_TAB = 1
        const val INVALID_PORT_MESSAGE = "The two ports must differ and be in the range 1024–65535."
    }
}
