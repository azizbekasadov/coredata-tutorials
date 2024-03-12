//
//  ExampleModel.swift
//  iTour
//
//  Created by Azizbek Asadov on 10/03/24.
//

import Foundation
import SwiftData

@Model
class Employee {
    var name: String
    
    @Attribute(.unique)
    var emailAddress: String // unique value to be stored
    
    var manager: Employee?
    
    init(name: String, emailAddress: String, manager: Employee?) {
        self.name = name
        self.emailAddress = emailAddress
        self.manager = manager
    }
}


//That being said, you can integrate structs into your models if you want, as long as the structs conform to Codable

@Model
class Customer {
    var name: String
    var address: Address

    init(name: String, address: Address) {
        self.name = name
        self.address = address
    }
}

struct Address: Codable {
    let line1: String
    let line2: String
    let city: String
    let postCode: String
}

//SwiftData is capable of storing a variety of data, but specifically the following:
//
//Any class that uses the @Model macro.
//Any struct that conforms to the Codable protocol.
//Any enum that conforms to the Codable protocol, even if it includes raw values or associated values.

enum Status: Codable {
    case active, inactive(reason: String)
}

@Model
class User {
    var name: String
    var status: Status

    init(name: String, status: Status) {
        self.name = name
        self.status = status
    }
}

//However, there is a catch: if you use collections of value types, e.g. [String], SwiftData will save that directly inside a single property too. Right now it’s encoded as binary property list data, which means you can’t use the contents of your array in a predicate.
//
//If you attempt to do so, your app will just crash at runtime. So, please be very careful.
//
//Of course, this behavior is an implementation detail of SwiftData, and is subject to change at any point in the future – do try it yourself before coming to a final conclusion

@Model
class CreditCard {
    @Attribute(.unique) var number: Int
    var balance: Decimal

    init(number: Int, balance: Decimal) {
        self.number = number
        self.balance = balance
    }
}

//This attribute has two important side effects that are not apparent from the code:
//
//Unique attributes are not supported by CloudKit, and if you attempt to use them your model container will simply refuse to load.
//If you create an object using a unique value, then attempt to create a second object using the same unique value, SwiftData will detect this and perform an upsert rather than an insert.

//@Transient macro so that SwiftData treats it as ephemeral and disposable, so it won’t be saved along with the rest of your data.

@Model class Player {
    var name: String
    var score: Int
    @Transient var levelsPlayed = 0

    var highScoreEntry: String {
        "\(name) scored \(score) points"
    }
    
    init(name: String, score: Int) {
        self.name = name
        self.score = score
    }
}

//There are two important things to remember when working with transient properties in SwiftData:
//
// - 1. Transient properties cannot be used in SwiftData query predicates because the actual data you’re working with doesn’t exist on disk. Attempting to use a transient property will compile just fine, but crash at runtime.
// - 2. Transient properties must always have a default value as shown above, so that when you create a new object or when an existing one is fetched from disk, there’s always a value present.

//SwiftData automatically saves only the stored properties of your models – any computed properties are automatically transient.

//    .externalStorage attribute, which suggests to SwiftData that this data is best stored separately. It will, if needed, stash that data externally from your main SwiftData storage, store only the filename to the external data, then transparently connect the two so you don’t need to take any further action – for the most part external data behaves no differently from internal data.

@Model class UserA {
    var name: String
    var score: Int
    @Attribute(.externalStorage, .allowsCloudEncryption) var avatar: Data

    init(name: String, score: Int, avatar: Data) {
        self.name = name
        self.score = score
        self.avatar = avatar
    }
}

//There are three important provisos when dealing with external storage, and it’s important that you’re aware of them.
//
//First, the .externalStorage attributes merely suggests to SwiftData that some information is best stored outside the main SQLite data store, but it doesn’t have to honor that request. In my tests with this attribute, SwiftData seems happy to store up to about 128K of a Data object right inside its main storage area, with larger data automatically being saved externally.
//
//Second, if you’re using String rather than Data, SwiftData seems happy to store strings of unlimited size without using external files at all no matter whether you use the attribute or not.
//
//Third, for the most part all this is an implementation detail: whether the data is stored right inside the database or not doesn’t matter to us, because it’s loaded and saved the same as internal data. However, you can’t use externally stored properties inside predicates, because the external files aren’t visible to the underlying data store – if you see an error message like [Foundation.__NSSwiftData _bytesPtrForStore]: unrecognized selector sent to instance 0x600000c74ae0 with userInfo of (null) chances are you might have fallen into this trap.


//In Core Data we were able to use NSCoreDataCoreSpotlightDelegate to trigger spotlight indexing of Spotlight-enabled data, but this is not currently an option for SwiftData apps.


//if let path = modelContext.container.configurations.first?.url.path(percentEncoded: false) {
//    let attrs = [FileAttributeKey.protectionKey: FileProtectionType.completeUnlessOpen]
//    try? FileManager.default.setAttributes(attrs, ofItemAtPath: path)
//}


@Model class PlayerA {
    var name: String
    var score: Int
    var lastModified: Date

    init(name: String, score: Int) {
        self.name = name
        self.score = score
        self.lastModified = .now
    }

    func update<T>(keyPath: ReferenceWritableKeyPath<PlayerA, T>, to value: T) {
        self[keyPath: keyPath] = value
        lastModified = .now
    }
}

//Note: SwiftData properties do not support willSet or didSet property observers, so we’re effectively bouncing our changes through a new method in lieu of using didSet.

@Model
class School {
    var name: String
    /*@Relationship(inverse: \Student.school) */var students: [Student]

    init(name: String, students: [Student]) {
        self.name = name
        self.students = students
    }
}

@Model
class Student {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \School.students) var school: School?

    init(name: String, school: School?) {
        self.name = name
        self.school = school
    }
}

// MARK: - One-to-One Relationship

@Model
class Country {
    var name: String
    var capitalCity: City?

    init(name: String, capitalCity: City? = nil) {
        self.name = name
        self.capitalCity = capitalCity
    }
}

@Model
class City {
    var name: String
    var latitude: Double
    var longitude: Double
    var country: Country?

    init(name: String, latitude: Double, longitude: Double, country: Country? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.country = country
    }
}

let country = Country(name: "England")
let city = City(name: "London", latitude: 51.507222, longitude: -0.1275, country: country)

//modelContext.insert(city)

// MARK: - One-to-Many Relationship

@Model
class Movie {
    var name: String
    var releaseYear: Int
    var director: Director?

    init(name: String, releaseYear: Int, director: Director) {
        self.name = name
        self.releaseYear = releaseYear
        self.director = director
    }
}

@Model
class Director {
    var name: String
    @Relationship(deleteRule: .nullify, inverse: \Movie.director) var movies: [Movie]

    init(name: String, movies: [Movie]) {
        self.name = name
        self.movies = movies
    }
}

//There are a handful of rules you need to follow with these relationships:
//
// - If you intend to use inferred relationships, one side of your data must be optional.
/// - If you use an explicit relationship where one side of your data is non-optional, be careful how you delete objects – SwiftData uses the .nullify delete rule by default, which can put your data into in an invalid state. To avoid this problem, either use an option value, or use a .cascade delete rule.
/// - Do not attempt to use collection types other than Array, because your code will simply not compile.

// MARK: N-to-N Relationship

@Model
class Actor {
    var name: String
    var movies: [MovieA] = [] // due to the inverse relationship of the alphabetical order -> bug fix

    init(name: String, movies: [MovieA]) {
        self.name = name
        self.movies = movies
    }
}

@Model
class MovieA {
    var name: String
    var releaseYear: Int
    @Relationship(inverse: \Actor.movies) var cast: [Actor]

    init(name: String, releaseYear: Int, cast: [Actor]) {
        self.name = name
        self.releaseYear = releaseYear
        self.cast = cast
    }
}


//This means in the above examples models named Actor and Movie will work but Movie and Person will not. Until a fix is released, a workaround is to provide a default value for your relationship array, like this: var movies: [Movie] = [].

// MARK: N2N Cascade DelRule
@Model
class House {
    var address: String
    @Relationship(deleteRule: .cascade, inverse: \Room.house) var rooms: [Room]

    init(address: String, rooms: [Room] = []) {
        self.address = address
        self.rooms = rooms
    }
}

@Model
class Room {
    var house: House
    var name: String

    init(house: House, name: String) {
        self.house = house
        self.name = name
    }
}

//“cascade delete” means that multi-level relationships automatically delete all the way down the chain

@Model
class SchooAl {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \StudenAt.school) var students: [StudenAt]

    init(name: String, students: [StudenAt] = []) {
        self.name = name
        self.students = students
    }
}

@Model
class StudenAt {
    var name: String
    var school: SchooAl
    @Relationship(deleteRule: .cascade) var results: [Result]

    init(name: String, school: SchooAl, results: [Result] = []) {
        self.name = name
        self.school = school
        self.results = results
    }
}

@Model
class Result {
    var subject: String
    var grade: Int

    init(subject: String, grade: Int) {
        self.subject = subject
        self.grade = grade
    }
}

//@Relationship macro allows us to specify minimum and maximum number of objects that should exist in a one-to-many or many-to-many connection.
@Model
class DogWalker {
    var name: String
    @Relationship(maximumModelCount: 5) var dogs: [Dog]

    init(name: String, dogs: [Dog] = []) {
        self.name = name
        self.dogs = dogs
    }
}

@Model
class Dog {
    var name: String
    var walker: DogWalker?

    init(name: String, walker: DogWalker? = nil) {
        self.name = name
        self.walker = walker
    }
}

//If you're given the persistent identifier of a SwiftData model instance and want to load the matching object for it, you should use the model(for:) method of your model context, like this:
//
//if let sneakers = modelContext.model(for: yourID) as? Movie {
//    print(sneakers.director)
//}

//Rather annoyingly this will cause a crash if your persistent identifier is invalid, so I prefer to use the registeredModel(for:) variant that only returns an object if it exists in the current model context.
//if let sneakers = modelContext.registeredModel(for: yourID) as? Movie {
//    print(sneakers.director)
//}


// SAVING
//At its simplest form, saving a SwiftData object takes three steps: creating it, inserting into your model context, then calling save() on that context.

//all SwiftData objects have an id property that unique identifies them, however before the object has been saved for the first time that identifier will be temporary.

// rollback() if needed to discard all changes

//If you use an array on one side of your relationship and an optional on the other, SwiftData will correctly infer the relationship and keep both sides in sync even without calling save() on the context.
//If you use a non-optional on the other side, you must specify the delete rule manually and call save() when inserting the data, otherwise SwiftData won’t refresh the relationship until application is relaunched – even if you call save() at a later date, and even if you create and run a new FetchDescriptor from scratch.

//fileprivate func sDelete() {
//    @Environment(\.modelContext) var modelContext
//    
//    do {
//        try modelContext.delete(model: School.self)
//    } catch {
//        print("Failed to delete all schools.")
//    }
//}
//
//fileprivate func subDelete() {
//    @Environment(\.modelContext) var modelContext
//    
//    try modelContext.delete(model: School.self, where: #Predicate { school in
//        school.students.isEmpty
//    })
//}

//If you’re deleting an object that has relationships, SwiftData will act on those relationships as part of the deletion – that’s the .nullify delete rule by default, but you might also have requested .cascade or one of the others. If you have a cascade delete in place, SwiftData will automatically continue the cascade down through all objects in a chain: deleting a School might delete all its students, and deleting students might delete all their exam results, for example.*/

//fileprivate func fetch() {
//    let now = Date.now
//    let fetchDescriptor = FetchDescriptor<Movie>(predicate: #Predicate({
//        $0.releaseYear > now
//    }),sortBy: [SortDescriptor(\.name), SortDescriptor(\.releaseDate, order: .reverse)])
//    fetchDescriptor.fetchLimit = 10
//    fetchDescriptor.propertiesToFetch = [\Movie.name, \.releaseYear]
//    fetchDescriptor.relationshipKeyPathsForPrefetching = [\.director]
////
////    do {
////        let movies = try modelContext.fetch(fetchDescriptor)
////
////        for movie in movies {
////            print("Found \(movie.name)")
////        }
////    } catch {
////        print("Failed to load Movie model.")
////    }
//}

//That loads all instances of a Movie model, with no filtering or sorting applied. It won’t load any relationships automatically, and will instead load those only when you request them.

//Important: If you issue a custom fetch immediately after inserting some data, any data linked through relationships won’t be visible even if you’ve manually called save(), and even if you specifically set includePendingChanges to true. Yes, when you call save() the data is written to disk immediately, but SwiftData seems to wait until the next runloop before making that data available for querying.


func querySample() {
    @Query(filter: #Predicate<Movie> { movie in
        movie.director.name == "Ridley Scott"
    }) var movies: [Movie]
    
    @Query(filter: #Predicate<Movie> { movie in
        movie.name.starts(with: "Back to the Future")
    }) var movies: [Movie]
    
    @Query(filter: #Predicate<Movie> { movie in
        movie.name.localizedStandardContains("JAWS") // crashes in Runtime
    }) var movies: [Movie]
    
    @Query(filter: #Predicate<Movie> { movie in
        movie.cast.isEmpty
    }) var movies: [Movie]// works
    
    @Query(filter: #Predicate<Movie> { movie in
        movie.cast.isEmpty == false
    }) var movies: [Movie] // crash in runtime
    
    @Query(filter: #Predicate<Movie> { movie in
        !movie.cast.isEmpty
    }) var movies: [Movie]// works
    
//    @Query(filter: #Predicate<Movie> { movie in
//        if movie.director.name.contains("Steven") {
//            if movie.cost > 100_000_000 {
//                return true
//            } else {
//                return false
//            }
//        } else {
//            return false
//        }
//    }) var movies: [Movie]
    
//    @Query(filter: #Predicate<Movie> { movie in
//        if movie.director.name.contains("Steven") {
//            if movie.cost > 100_000_000 {
//                return true
//            }
//        }
//
//        return false
//    }) var movies: [Movie] // crash
    
    // Instead use:
//    @Query(filter: #Predicate<Movie> { movie in
//        movie.director.name.contains("Steven") && movie.cost > 100_000_000
//    }) var movies: [Movie]
    
//    @Query(filter: #Predicate<Movie> { movie in
//        movie.cast.filter { $0.age < 18 }.count >= 3
//    }) var movies: [Movie]
    
//    @Query(filter: #Predicate<Movie> { movie in
//        movie.cast.allSatisfy { $0.name.count <= 10 }
//    }) var movies: [Movie] // crash
    
//    @Query(filter: #Predicate<Movie> { movie in
//        movie.cast.filter { $0.movies.count > 3 }.isEmpty
//    }) var movies: [Movie] // crash
}

//How to get natural string sorting for SwiftData queries
//create a SortDescriptor using the .localizedStandard comparator. For example, if you were using the @Query macro you'd write something like this:
//
//@Query(sort: [SortDescriptor(\User.name, comparator: .localizedStandard)])


//let descriptor = FetchDescriptor<Employee>(predicate: #Predicate { $0.salary > 100_000 })
//let count = (try? modelContext.fetchCount(descriptor)) ?? 0

// DELETE ALL
//try modelContext.delete(model: School.self, where: #Predicate { $0.students.isEmpty })

//ModelContext and all SwiftData models do not conform to Sendable, which means they can't be transferred between Swift actors. ModelContainer does conform to Sendable, so please use that to create your background context.

final class BackgroundDataHander {
    private var context: ModelContext

    init(with container: ModelContainer) {
        context = ModelContext(container)
    }
}

actor BGDataHandlerActor {
    private var context: ModelContext

    init(with container: ModelContainer) {
        context = ModelContext(container)
    }
}
//Important: If you intend to create a background context using an actor in order to do bulk data imports, I would recommend against storing the context as a property because the extra actor synchronization will slow down your code dramatically.
//Apple's official view is that autosave is enabled for the main context, but not for model context created by hand. In my experience this is inconsistent: yes, the main context always has autosave enabled, but any extra contexts you create by hand may or may not.
//Tip: Until we have more certainty around when autosave is actually enabled or not, I would recommend being explicit when creating your background contexts.

//Because SwiftData models are not sendable, you should transfer them between tasks using their id property. This allows you to load the object on your background context, without worrying about data races.

//How to add support for undo and redo

//    .modelContainer(for: [Store.self, Book.self], isUndoEnabled: true)
//@Environment(\.undoManager) var undoManager
//undoManager?.undo()
//container = try ModelContainer(for: Store.self, Book.self)
//container.mainContext.undoManager = UndoManager()

//Tip: Calling undo() or redo() undoes or redoes the last set of changes you made, but what “last set of changes” means is a bit fuzzy.
//All changes made in the current runloop are grouped together into a single undo/redo batch, even if you attempt to start a fresh transaction inside the runloop


//do {
//    try modelContext.delete(model: Country.self)
//    try modelContext.delete(model: City.self)
//} catch {
//    print("Failed to clear all Country and City data.")
//}


//let descriptor = FetchDescriptor<Student>()
//var totalResults = 0
//var totalDistinctions = 0
//var totalPasses = 0
//
//do {
//    try modelContext.enumerate(descriptor) { student in
//        totalResults += student.scores.count
//        totalDistinctions += student.scores.filter { $0 >= 85 }.count
//        totalPasses += student.scores.filter { $0 >= 70 && $0 < 85 }.count
//    }
//} catch {
//    print("Unable to calculate student results.")
//}
//
//print("Total test results: \(totalResults)")
//print("Distinctions: \(totalDistinctions)")
//print("Passes: \(totalPasses)")

//SwiftData’s model context has a dedicated enumerate() method that is designed to traverse large amounts of data efficiently.
