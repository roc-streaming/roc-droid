# Emulator setup

## Windows Android emulator setup

* Android Studio is used to set up the Windows Android emulator.

* Open Android studio and navigate to `AVD Manager` (`Tools/AVD Manager`)
  
* You can use `AVD Manager` to examine all your Android emulators.

* Click the `+ Create Virtual Device...` button to add a new Android emulator.
  
* Select the desired device definition and click `Next`.

* Select the desired system image and click `Next`.

* Select the desired AVD device name and click `Finish`.

* Go to your IDE (in our example we will use `Visual Studio Code`) and click `Select device to use` (usually in the bottom right corner of `Visual Studio Code`). Select the new Android emulator device from the list that opens and check that it boots and works without errors.
  
* Click `Run/Start Debugging` in the IDE while the Android emulator device is active to verify that the application opens and runs correctly on the new AVD.
