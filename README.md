# Today-Widget

1. Today-Widget describes how to implement Today's App Extension (Widget) in your app.

2. Some new updations are added to widget APIs in iOS 10. So, this project includes implementation details for both (iOS 10) and (iOS 8 or iOS 9). 

3. Project describes:
  1. Sharing code between App and Widget
  2. Sharing data between App and Widget
  3. Open App from Widget
  4. Show More/Show Less functionality in Widget using Auto-Layout
  5. Updating Widget content
  6. Show/Hide widget from containing App (optional)

4. Implementation in Swift 3.0

## Preview
<img src="https://github.com/pgpt10/Today-Widget/blob/master/Screenshot.PNG"  width='300' height='534' alt="Preview gif">

## App Extension
1. Introduced in iOS 8

2. An app extension lets you extend custom functionality and content beyond your app and make it available to users while they’re interacting with other apps or the system.

3. Used for specific task

4. Not an app

## Terminology
1. Containing App - The app for which extension is created

2. Types of Extensions - Today(Widget), Share, Custom Keyboard, Photo Editing etc.

3. Extension Point - Each extension is tied to a single area of the system. Eg. Today Extension - Notification center, Share Extension - UIActivityViewController

4. Extension Container
    Extension is different from app
    Separate binary that runs independent of the containing app
    Can add multiple extensions to a single app
    To distribute app extensions to users, you submit a containing app to the App Store, when user installs the app, extension is also installed with it

5.  Host App - App from which the extension is launched

## Project Details

This project contains 3 things:

1. Containing App : App shows the restaurants that are near to your current location. The restaurants are fetched through Google Places API - "Nearby Search" using the current location and displayed in a table. App uses the Location Services of iOS. The details of a particular restaurant are then fetched through Google Places API - "Place Detail" using placeID of the selected restaurant. Each restaurant has a unique placeID. Instead of restaurants, you can fetch any kind of place (Eg. Bank, School, Hospital etc.) according to your requirement.

2. Today Extension : Whenever the user view a restaurant's detail in containing app , its details are saved in the share container. Maximum 5 details can be saved in the container. This limit can be changed according to your requirement. Whenever the widget is loaded, these saved restaurant details are fetched from the shared container and used to update the widget's content. When a restaurant detail is tapped in the widget, containing app is opened using "openURL:" and the detail page corresponding to selected restaurant is displayed.

3. Framework : App and widget both share some of the code. So, a framework is created that contains the code common to both App and widget.

## Things to do on Apple Developer Portal

1. Create App ID for Containing App
2. Create App ID for Extension
3. Create App Group
4. Assign App Group to App ID of Containing App
5. Assign App Group to App ID of Extension
6. Create Provision Profile for App ID of Containing App
7. Create Provision Profile for App ID of Extension

## iOS 8 and iOS 9 implementaion details

For iOS 8 and iOS 9, the height changes are to be handled explicitly. For this auto-layout is used. Show More/Show Less functionality need to be provided explicitly.
Show More - increases the table height constraint according to the content
Show Less - decreases the table height constraint to show only single row.

## iOS 10 implementation details

In iOS 10, Show More/Show Less functionality is provided by the API itself. 
Use:

1. NCWidgetDisplayMode and 
2. func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)

to handle widget height changes. You don't need any explicit height constraint for this. Also explicit Show More/Show Less button is not required.

### Note: 
To show/hide widget from containing app - Search for "TODO" in project and follow the instructions.
