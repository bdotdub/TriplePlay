# TriplePlay

A demo of a better authentication flow for tvOS apps using iOS

![](http://f.cl.ly/items/2D0L112l0z1p1V0O3h04/tvos.gif)

For more background, read the [blog post](https://medium.com/@bdotdub/signing-into-apps-on-apple-tv-sucks-d36fd00e6712)

---------------

## Running the iOS app

In your terminal:

1. Go into the iOS directory: `cd iOS/TriplePlay`
1. Install Cocoapods: `pod install`
1. Open project in Xcode: `open TriplePlay.xcworkspace`

The build and run the app from Xcode.

## Running the tvOS app

In your terminal:

1. Go into the iOS directory: `cd tvOS/Timehop`
1. Install Cocoapods: `pod install`
1. Open project in Xcode: `open Timehop.xcworkspace`

The build and run the app from Xcode.

## Security Disclaimer

In practice, you wouldn't actually want to pass the authentication token. In this example, anyone listening for the `_timehop_auth._tcp.` would be able to grab the (potentially sensitive) data you're passing to the tvOS app.

Some alternate flows could be:

* Flip the roles. Have the tvOS provide the service and send over a single use token. The iOS app could then take that token and pass it to the backend service. The tvOS app could poll the backend service to see if anyone has authenticated using that one time token.
* Dynamically create the service name. The service type is hard coded in this example, but you could display a randomly generated token in the tvOS app and enter it on the iOS app. You could then be listening / publishing to a service of type `_timehop_auth_RaNd0mt0ken._tcp.`

## LICENSE

MIT. See `LICENSE`
