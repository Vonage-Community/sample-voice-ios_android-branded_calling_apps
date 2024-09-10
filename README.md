# InApp Branded Call
A branded incoming call involves tailoring the call display with the company's name, logo, and pertinent details, thereby promoting professionalism, trust, and improved customer interaction. 
This reference app demonstrates how to generate a branded call from a web contact center to a mobile app user.

## Backend Server
1. Deploy a backend [branded calling server](https://codecache.serverless.vonage.com/b7ef45ea-d5e4-44f6-9754-947014890ed5_branded-calling) in Vonage Codecache
 

## Setup Push Notification
### iOS: 
1. Generate Push Cert: [Link](https://developer.vonage.com/en/vonage-client-sdk/set-up-push-notifications/ios#generating-a-push-certificate)
1. Upload your Push Cert: [Link](https://developer.vonage.com/en/vonage-client-sdk/set-up-push-notifications/ios#upload-your-certificate)

### Android:
1. Connect your application to Firebase: [Link](https://developer.vonage.com/en/vonage-client-sdk/set-up-push-notifications/android#connect-your-vonage-application-to-firebase)
1. Add google-services.json into the Android app module root directory: [Link](https://developer.vonage.com/en/vonage-client-sdk/set-up-push-notifications/android#add-firebase-configuration-to-your-application)

## iOS
1. Go to `iOS` folder
1. Run `pod install` to install the dependencies
1. Open your project in Xcode using the .xcworkspace file
1. Go to Uitls/Configuration.swift File and paste your backend server url to `backendServer`.
1. Connect your device and run the project. \
Note: Run it on real device, as the simulator might not works for callkit and/or voip push

## Android
1. Open Android folder in Android Studio
1. Go to utils/Constants.kt file, and paste your backend server url to `BACKEND_URL`.
1. Run the project

## Login the App:
1. Fill in the phone number in E.164 Format without the (+) sign
1. Click the "Sign Up" button if the user has never been created
1. Click the "Login" button if the user has been been created