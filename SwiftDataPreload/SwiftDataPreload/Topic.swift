//
//  Topic.swift
//  SwiftDataPreload
//
//  Created by Azizbek Asadov on 12/03/24.
//

import Foundation
import SwiftData

@Model
class Topic {
    var name: String
    var content: String

    init(name: String, content: String = "") {
        self.name = name
        self.content = content
    }
}


actor TopicResearcher {
    let context: ModelContext
    
    init(container: ModelContainer) {
        self.context = ModelContext(container)
    }
    
    func research(_ identifier: PersistentIdentifier) async throws {
        guard let topic = context.model(for: identifier) as? Topic else {
            return
        }
        
        print("Researching \(topic.name)…")
        print("Lots of work here…")
    }
}

//There are only two things that are safe to send between actors: a ModelContainer and a PersistentIdentifier. This means the safe way to pass data between actors is to:
//
//1. Pass a model container instance from your main actor to another actor.
//2. Use that to create a model context on the other actor.
//3. Pass the persistent identifier of your model object from your main actor to the other actor.
//4. Use that to load the object on the other actor.

import SwiftUI

struct TopicContentView: View {
    @Query(sort: \Topic.name) var topics: [Topic]
    @Environment(\.modelContext) var modelContext
    
    @State private var researcher: TopicResearcher
    
    var body: some View {
        NavigationStack {
            List(topics) { topic in
                VStack(alignment: .leading) {
                    Text(topic.name)
                }
                .swipeActions {
                    Button("Research", systemImage: "magnifyingglass") {
                        research(topic)
                    }
                }
            }
            .navigationTitle("AutoResearcher")
            .toolbar {
                Button("Add Sample", action: addSample)
            }
        }
    }
    
    init(container: ModelContainer) {
        let researcher = TopicResearcher(container: container)
        _researcher = State(initialValue: researcher)
    }
    
    private func addSample() {
        let topic1 = Topic(name: "The Roman Empire")
        let topic2 = Topic(name: "Travis Kelce")
        modelContext.insert(topic1)
        modelContext.insert(topic2)
    }
    
    private func research(_ topic: Topic) {
        let id = topic.id
        
        Task.detached(priority: .background) { [researcher] in
            try await researcher.research(id)
        }
    }
}

//ModelContainer and PersistentIdentifier are both sendable, whereas model objects and model contexts are not.

//Beyond those basics, there are a handful of specific things to know:
//
//You can create many ModelContext instances from a single, shared ModelContainer, across any number of actors. The correct approach is to send your model container into your actor, then create a local model context there.
//When you want to transfer a model object from one actor to another, you should send its id property (a PersistentIdentifier instance) then load it locally on the other actor. Do not attempt to send a model instance directly between actors.
//If you create a model context inside a Task, you must call save() explicitly in order to write your chance, even when autosave is enabled for that context – autosave may not have a chance to run before the context is discarded.
//All SwiftData calls happen synchronously with the exception of enumerate(), which uses a callback for individual objects. This means SwiftData only ever works with data that is synced to your local data store, even when there are further changes waiting in iCloud.
//If you're using SwiftData with MVVM, @Observable does not automatically imply @MainActor. While you can update your SwiftUI views from an @Observable object running on a background actor, chances are your animations won't work quite right. I'd suggest using @Observable @MainActor to avoid this problem.

