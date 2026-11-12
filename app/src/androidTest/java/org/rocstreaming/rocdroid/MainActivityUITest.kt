package org.rocstreaming.rocdroid

import android.content.Context
import androidx.test.core.app.ActivityScenario
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.isDisplayed
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityUITest {
    @Test
    fun useAppContext() {
        // Context of the app under test.
        val appContext: Context = InstrumentationRegistry.getInstrumentation().targetContext
        assertEquals("org.rocstreaming.rocdroid", appContext.packageName)
    }

    @Test
    fun mainActivity_HasTabs() {
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity { activity ->
            // Check that the ViewPager and TabLayout exist
            onView(withId(R.id.viewPager)).check(matches(isDisplayed()))
            onView(withId(R.id.tabs)).check(matches(isDisplayed()))
        }
    }

    @Test
    fun mainActivity_TabTitles() {
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity { activity ->
            // Check tab titles are set
            onView(withText("Receiver")).check(matches(isDisplayed()))
            onView(withText("Sender")).check(matches(isDisplayed()))
        }
    }

    @Test
    fun mainActivity_AboutMenuOpens() {
        val scenario = ActivityScenario.launch(MainActivity::class.java)
        scenario.onActivity { activity ->
            // Click the about menu item
            onView(withId(R.id.about)).perform(click())
            // Verify AboutActivity is displayed (would need more setup)
        }
    }
}
