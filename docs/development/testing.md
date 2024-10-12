# Testing

## General information about testing

* It is important to test the application on real devices, but for convenience, emulators are widely used for development and testing purposes. Here you can find documentation on how to set up such emulators:

  * [Emulator Setup Documentation](./emulator.md)

## UI tests

* If possible, all classes of roc-droid `UI` should be tested

* The type of testing used for the `UI` is defined by `Flutter` as widget testing.

* The `UI` should be tested based on the `Flutter` `testWidgets()` functionality.

* Widget testing is described in the `Flutter` documentation here: <https://docs.flutter.dev/cookbook/testing/widget/introduction>

## Model tests

* If possible, all classes of roc-droid `Model` should be tested

* The type of testing used for the `Model` is defined by `Flutter` as unit testing.

* The `Model` should be tested based on the `Dart` `test()` functionality.

* Unit testing is described in the `Flutter` documentation here: <https://docs.flutter.dev/cookbook/testing/unit/introduction>

## Agent tests

* If possible, all classes of roc-droid `Agent` should be tested

TODO - add Agent unit testing description

