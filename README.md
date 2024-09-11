# Branded Calling Client Apps
An incoming branded call involves tailoring the call display with the company's name, logo, and pertinent details which promoting professionalism, trust, and improved customer interaction. 

This reference app demonstrates how to generate a branded call to a mobile app user using the [Vonage Client SDK](https://developer.vonage.com/en/vonage-client-sdk/overview).

## Backend Server
First you will need to deploy a backend server which uses SIP to connect to your call centre. You can deploy the [Branded Calling project](https://codecache.serverless.vonage.com/b7ef45ea-d5e4-44f6-9754-947014890ed5_branded-calling) on Vonage Code Hub, or deploy it yourself from [GitHub](https://github.com/Vonage-Community/sample-voice-nodejs-branded_calling).
 

## Setup Push Notification
The reference client applications have been built with push notifications. Here are some quick links to the Vonage developer documentation on how to get set up. 

### iOS: 
1. [Generate Push Certificate](https://developer.vonage.com/en/vonage-client-sdk/set-up-push-notifications/ios#generating-a-push-certificate)
1. [Upload your Push Certificate](https://developer.vonage.com/en/vonage-client-sdk/set-up-push-notifications/ios#upload-your-certificate)

### Android:
1. [Connect your application to Firebase](https://developer.vonage.com/en/vonage-client-sdk/set-up-push-notifications/android#connect-your-vonage-application-to-firebase)
1. [Add google-services.json](https://developer.vonage.com/en/vonage-client-sdk/set-up-push-notifications/android#add-firebase-configuration-to-your-application)


## Run the iOS App
1. Go to `iOS` folder
1. Run `pod install` to install the dependencies
1. Open your project in Xcode using the .xcworkspace file
1. Go to Uitls/Configuration.swift File and paste your backend server url as the value for `backendServer`.
1. Connect your device and run the project.
> Note: Run it on real device, as the simulator might not work for CalKit and/or VoIP Push Notifications

## Run the Android App
1. Open Android folder in Android Studio
1. Go to utils/Constants.kt file, and paste your backend server url as the value for `BACKEND_URL`.
1. Run the project

## Login the App:
1. Fill in the phone number in E.164 Format without the (+) sign
1. Click the "Sign Up" button if the user has not yet been created
1. Click the "Login" button if the user has been been created
