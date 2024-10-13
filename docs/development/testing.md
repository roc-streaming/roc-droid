# Testing

## Running tests

To run tests, see [Automation](./automation.md).

To setup Android emulator and capture its logs, see [Android development](./android_development.md).

## Widget tests

* When possible, UI classes (`lib/src/ui`) should be tested using Flutter widget testing (`testWidgets()` function).

* Documentation: <https://docs.flutter.dev/cookbook/testing/widget/introduction>

## Unit tests

* When possible, non-UI classes (`lib/src/model`, `lib/src/agent`) should be covered with unit tests (`test()` function)

* Documentation: <https://docs.flutter.dev/cookbook/testing/unit/introduction>
