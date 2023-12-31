# Adding user locations to a map

This project is going to be based around a map view, asking users to add places to the map that they want to visit. To do that we need to place a **Map** so that it takes up our whole view, track its center coordinate, and then also whether or not the user is viewing place details, what annotations they have, and more.

We’re going to start with a full-screen **Map** view, then place a translucent circle on top to represent the center point. Although this view will have a binding to track the center coordinate, we don’t need to use that to place the circle – a simple **ZStack** will make sure the circle always stays in the center of the map.

First, add an extra **import** line so we get access to MapKit’s data types:
```
import MapKit
```
Second, add a property inside **ContentView** that will store the current state of the map. Later on we’re going to use this to add a place mark:
```
@State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
```
That starts the map so that most of Western Europe and North Africa are visible.

And now we can fill in the **body** property
```
ZStack {
    Map(coordinateRegion: $mapRegion)
        .ignoresSafeArea()
    Circle()
        .fill(.blue)
        .opacity(0.3)
        .frame(width: 32, height: 32)
}
```
If you run the app now you’ll see you can move the map around freely, but there’s always a blue circle showing exactly where the center is.

All this work by itself isn’t terribly interesting, so the next step is to add a button in the bottom-right that lets us add place marks to the map. We’re already inside a **ZStack**, so the easiest way to align this button is to place it inside a **VStack** and a **HStack** with spacers before it each time. Both those spacers end up occupying the full vertical and horizontal space that’s left over, making whatever comes at the end sit comfortably in the bottom-right corner.

We’ll add some functionality for the button soon, but first let’s get it in place and add some basic styling to make it look good.

Please add this **VStack** below the Circle:
```
VStack {
    Spacer()
    HStack {
        Spacer()
        Button {
            // create a new location
        } label: {
            Image(systemName: "plus")
        }
        .padding()
        .background(.black.opacity(0.75))
        .foregroundColor(.white)
        .font(.title)
        .clipShape(Circle())
        .padding(.trailing)
    }
}
```
Notice how I added the **padding()** modifier twice there – once is to make sure the button is bigger before we add a background color, and the second time to push it away from the trailing edge.

Where things get *interesting* is how we place locations on the map. We’ve bound the location of the map to a property in **ContentView**, but now we need to send in an array of locations we want to show.

This takes a few steps, starting with a basic definition of the type of locations we’re creating in our app. This needs to conform to a few protocols:

- **Identifiable**, so we can create many location markers in our map.
- **Codable**, so we can load and save map data easily.
- **Equatable**, so we can find one particular location in an array of locations.

In terms of the data it will contain, we’ll give each location a name and description, plus a latitude and longitude. We’ll also need to add a unique identifier so SwiftUI is happy to create them from dynamic data.

So, create a new Swift file called Location.swift, giving it this code:
```
struct Location: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String
    let latitude: Double
    let longitude: Double
}
```
Storing latitude and longitude separately gives us **Codable** conformance out of the box, which is always nice to have. We’ll add a little more to that shortly, but it’s enough to get us moving.

Now that we have a data type where we can store an individual location, we need an array of those to store all the places the user wants to visit. We’ll put this into **ContentView** for now just we can get moving, but again we’ll return to it shortly to add more.

So, start by adding this property to **ContentView**:
```
@State private var locations = [Location]()
```
Next, we want to add a location to that whenever the + button is tapped, so replace the **// create a new location** comment with this:
```
let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
locations.append(newLocation)
```
Finally, update **ContentView** so that it sends in the **locations** array to be converted into annotations:
```
Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
    MapMarker(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
}
.ignoresSafeArea()
```
That’s enough map work for now, so go ahead and run your app again – you should be able to move around as much as you need, then press the + button to add locations.

I know it took a fair amount of work to get set up, but at least you can see the basics of the app coming together!

