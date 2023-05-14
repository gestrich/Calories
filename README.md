# Calorie Counter

## App Store Deploy

* Increment the "Marketing Version" in build settings.
* Increment the "Project Version" in build settings.
* Submit for review
* Tag released commit: git tag -a 1.6 -m "Version 1.6 - SwiftUI release"

## Feature Roadmap

* CloudKit Sync Support
* Watch App
  * Calories Remaining
  * Add recent entry
* Watch Complication
  * Calories Remaining

### CloudKit + Watch Release
    * Settings in Core Data
    * Share Core Data with Extension
        * https://medium.com/@pietromessineo/ios-share-coredata-with-extension-and-app-groups-69f135628736
    * Complications Update
        * Using Push Notifications in CloudKit
            * https://stackoverflow.com/questions/68350388
        * Just send the info via various APIs
            * https://blog.eidinger.info/watchos-articles-from-apple
    * Test Upgrade
        * Remove all CloudKit development environment
        * Install old Calorie model on release device
        * Update and check all records synced on another device
        * Check general syncing behavior
    * Check core data model has all changes saved (I made some during SwiftUI refactor) 
    * Remove these notes
    * Use Xcode Build to release
        * Check TestFlight Behavior
    * References
        * Mirroring data to CloudKit: https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit
        * Transitioning a live app: https://medium.com/@dmitrydeplov/coredata-cloudkit-integration-for-a-live-app-57b6cfda84ad
        

### Later Release

* Combined Edit Functionality
    * Consider merging Entry view
    * Keyboard
        * Dismiss when scrolling
        * Dismiss when view appears after in background
    * Edit Functionality?
* Undo Support
