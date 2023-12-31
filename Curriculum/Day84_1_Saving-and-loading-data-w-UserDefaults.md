# Saving and loading data with UserDefaults

This app mostly works, but it has one fatal flaw: any data we add gets wiped out when the app is relaunched, which doesn’t make it much use for remembering who we met. We can fix this by making the **Prospects** initializer able to load data from **UserDefaults**, then write it back when the data changes.

This time our data is stored using a slightly easier format: although the **Prospects** class uses the **@Published** property wrapper, the **people** array inside it is simple enough that it already conforms to **Codable** just by adding the protocol conformance. So, we can get most of the way to our goal by making three small changes:

1. Updating the **Prospects** initializer so that it loads its data from **UserDefaults** where possible.
2. Adding a **save()** method to the same class, writing the current data to **UserDefaults**.
3. Calling **save(**) when adding a prospect or toggling its **isContacted** property.

We’ve looked at the code to do all that previously, so let’s get to it. We already have a simple initializer for **Prospects**, so we can update it to use **UserDefaults** like this:
```
init() {
    if let data = UserDefaults.standard.data(forKey: "SavedData") {
        if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
            people = decoded
            return
        }
    }

    people = []
}
```
As for the **save()** method, this will do the same thing in reverse – add this:
```
func save() {
    if let encoded = try? JSONEncoder().encode(people) {
        UserDefaults.standard.set(encoded, forKey: "SavedData")
    }
}
```
Our data is changed in two places, so we need to make both of those call **save()** to make sure the data is always written out.

The first is in the **toggle()** method of **Prospects**, so modify it to this:
```
func toggle(_ prospect: Prospect) {
    objectWillChange.send()
    prospect.isContacted.toggle()
    save()
}
```
The second is in the **handleScan(result:)** method of **ProspectsView**, where we add new prospects to the array. Find this line:

prospects.people.append(person)
And add this directly below:
```
prospects.save()
```
If you run the app now you’ll see that any contacts you add will remain there even after you relaunch the app, so we could easily stop here. However, this time I want to go a stage further and fix two other problems:

1. We’ve had to hard-code the key name “SavedData” in two places, which again might cause problems in the future if the name changes or needs to be used in more places.
2. Having to call **save()** inside **ProspectsView** isn’t good design, partly because our view really shouldn’t know about the internal workings of its model, but also because if we have other views working with the data then we might forget to call **save()** there.

To fix the first problem we should create a property on **Prospects** to contain our save key, so we use that property rather than a string for **UserDefaults**.

Add this to the **Prospects** class:
```
let saveKey = "SavedData"
```
We can then use that rather than a hard-coded string, first by modifying the initializer like this:
```
if let data = UserDefaults.standard.data(forKey: saveKey) {
```    
And by modifying the **save()** method to this:
```
UserDefaults.standard.set(encoded, forKey: saveKey)
```
This approach is much safer in the long term – it’s far too easy to write “SaveKey” or “savedKey” by accident, and in doing so introduce all sorts of bugs.

As for the problem of calling **save()**, this is actually a deeper problem: when we write code like prospects.people.append(person) we’re breaking a software engineering principle known as encapsulation. This is the idea that we should limit how much external objects can read and write values inside a class or a struct, and instead provide methods for reading (getters) and writing (setters) that data.

In practical terms, this means rather than writing **prospects.people.append(person)** we’d instead create an **add()** method on the **Prospects** class, so we could write code like this: **prospects.add(person)**. The result would be the same – our code adds a person to the **people** array – but now the implementation is hidden away. This means that we could switch the array out to something else and **ProspectsView** wouldn’t break, but it also means we can add extra functionality to the **add()** method.

So, to solve the second problem we’re going to create an **add()** method in **Prospects** so that we can internally trigger **save()**. Add this now:
```
func add(_ prospect: Prospect) {
    people.append(prospect)
    save()
}
```
Even better, we can use access control to stop external writes to the **people** array, meaning that our views must use the **add()** method to add prospects. This is done by changing the definition of the **people** property to this:
```
@Published private(set) var people: [Prospect]
```
Now that only code inside **Prospects** calls the **save()** method, we can mark that as being private too:
```
private func save() {
```
This helps lock down our code so that we can’t make mistakes by accident – the compiler simply won’t allow it. In fact, if you try building the code now you’ll see exactly what I mean: **ProspectsView** tries to append to the **people** array and call **save()**, which is no longer allowed.

To fix that error and get our code compiling cleanly again, replace those two lines with this:
```
prospects.add(person)
```
Switching away from strings then using encapsulation and access control are simple ways of making our code safer, and are some great steps towards building better software.

