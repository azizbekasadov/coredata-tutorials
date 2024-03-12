//
//  Item.swift
//  ObservationSample
//
//  Created by Azizbek Asadov on 12/03/24.
//

import SwiftUI
import SwiftData
import Observation

enum Donut: String, CaseIterable, Identifiable {
    case withHole
    case withoutHole
    
    var id: String {
        self.rawValue
    }
}

@Observable
class FoodTruckModel {
    var orders: [String] = []
    var donuts: [Donut] = Donut.allCases
    var orderCount: Int { orders.count }
    
    init(orders: [String], donuts: [Donut]) {
        self.orders = orders
        self.donuts = donuts
    }
}

//One of the remarkable aspects of Observation is that it eliminates the need for additional property wrappers to make it work with SwiftUI views.

struct DonutMenu: View {
  let model: FoodTruckModel
    
    var body: some View {
        List {
            Section("Donuts") {
                ForEach(model.donuts) { donut in
                    Text(donut.rawValue)
                }
                Button("Add new donut") {
                    //          model.addDonut()
                }
            }
            Section("Orders") {
                LabeledContent("Count", value: "\(model.orderCount)")
            }
        }
    }
}


//1. @State
//Use @State when you need to store view-specific state in a model. In the example of a donut model being used in a sheet presentation, the donutToAdd property is marked with @State. This property is bound to editable fields and its lifetime is tied to the containing view.

struct DonutListView: View {
    var donutList: DonutList
    @State private var donutToAdd: Donut?

    var body: some View {
        List(donutList.donuts) { DonutView(donut: $0) }
        Button("Add Donut") { donutToAdd = Donut() }
            .sheet(item: $donutToAdd) {
                TextField("Name", text: $donutToAdd.name)
                Button("Save") {
                    donutList.donuts.append(donutToAdd)
                    donutToAdd = nil
                }
                Button("Cancel") { donutToAdd = nil }
            }
    }
}

//2. @Environment
//The @Environment property wrapper propagates globally accessible values, allowing them to be shared across multiple locations.
//@Observable class Account {
//  var userName: String?
//}
//
//struct FoodTruckMenuView : View {
//  @Environment(Account.self) var account
//
//  var body: some View {
//    if let name = account.userName {
//      HStack { Text(name); Button("Log out") { account.logOut() } }
//    } else {
//      Button("Login") { account.showLogin() }
//    }
//  }
//}

//3. @Bindable
//The @Bindable property wrapper is lightweight and enables the creation of bindings from a type. To bind a property, use the $ syntax, which is commonly used with observable types. In the donut view example, the name property is bound using @Bindable. This allows editing the name through a TextField.
//
//@Observable class Donut {
//  var name: String
//}
//
//struct DonutView: View {
//  @Bindable var donut: Donut
//
//  var body: some View {
//    TextField("Name", text: $donut.name)
//  }
//}

//In cases where a computed property does not depend on stored properties within the observable type, additional steps are required to make it work with Observation. You need to manually specify when the property is accessed and when it changes. This involves customizing the access points to read and store the property. However, these cases are rare, as most computed properties rely on stored properties.

//Transitioning from ObservableObject to @Observable
//If you’re currently using ObservableObject in your SwiftUI app, transitioning to the new @Observable macro is straightforward. Remove the ObservableObject conformance, @Published property wrappers, and replace them with the @Observable macro. Similarly, update the @ObservedObject and @EnvironmentObject property wrappers to @Bindable and @Environment, respectively. This transition simplifies your code and can potentially improve performance.

// BEFORE Observation
//import SwiftUI
//
//public class FoodTruckModel: ObservableObject {
//  @Published public var truck = Truck()
//  @Published public var orders: [Order] = []
//  @Published public var donuts = Donut.all
//
//  var dailyOrderSummaries: [City.ID: [OrderSummary]] = [:]
//  var monthlyOrderSummaries: [City.ID: [OrderSummary]] = [:]
//}

// AFTER Observation
//import SwiftUI
//import Observation
//
//@Observable public class FoodTruckModel {
//  public var truck = Truck()
//  public var orders: [Order] = []
//  public var donuts = Donut.all
//
//  var dailyOrderSummaries: [City.ID: [OrderSummary]] = [:]
//  var monthlyOrderSummaries: [City.ID: [OrderSummary]] = [:]
//}

@Observable 
final class Store<State, Action> {
    typealias Reduce = (State, Action) -> State
    
    private(set) var state: State
    private let reduce: Reduce
    
    init(initialState state: State, reduce: @escaping Reduce) {
        self.state = state
        self.reduce = reduce
    }
    
    func send(_ action: Action) {
        state = reduce(state, action)
    }
    
//    func startObservation() {
//        withObservationTracking {
//            render(store.state)
//        } onChange: {
//            Task { startObservation() }
//        }
//    }
}


//withObservationTracking {
//    render(store.state)
//} onChange: {
//    print("State changed")
//}

//struct _ContentView: View {
//    @State private var store = Store<AppState, AppAction>(
//        initialState: .init(),
//        reduce: reduce
//    )
//    
//    var body: some View {
//        ProductsView(store: store)
//    }
//}
//
//struct ProductsView: View {
//    @Environment(Store<AppState, AppAction>.self) var store
//    
//    var body: some View {
//        List(store.state.products, id: \.self) { product in
//            Text(product)
//        }
//        .onAppear {
//            store.send(.fetch)
//        }
//    }
//}

//@Observable final class AuthViewModel {
//    var username = ""
//    var password = ""
//    
//    var isAuthorized = false
//    
//    func authorize() {
//        isAuthorized.toggle()
//    }
//}
//
//struct AuthView: View {
//    @Bindable var viewModel: AuthViewModel
//    
//    var body: some View {
//        VStack {
//            if !viewModel.isAuthorized {
//                TextField("username", text: $viewModel.username)
//                SecureField("password", text: $viewModel.password)
//                
//                Button("authorize") {
//                    viewModel.authorize()
//                }
//            } else {
//                Text("Hello, \(viewModel.username)")
//            }
//        }
//    }
//}

//struct InlineAuthView: View {
//    @Environment(AuthViewModel.self) var viewModel
//    
//    var body: some View {
//        @Bindable var viewModel = viewModel
//        
//        VStack {
//            if !viewModel.isAuthorized {
//                TextField("username", text: $viewModel.username)
//                SecureField("password", text: $viewModel.password)
//                
//                Button("authorize") {
//                    viewModel.authorize()
//                }
//            } else {
//                Text("Hello, \(viewModel.username)")
//            }
//        }
//    }
//}
