//
//  ContentView.swift
//  Aula-CloudKit
//
//  Created by Lucca Lopes on 06/10/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var vm = CloudKitModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.itens, id: \.id) { item in
                    Text(item.text)
                }
                .onDelete(perform: { indexSet in
                    vm.deleteItems(offsets: indexSet)
                })
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        Task{
                            await vm.fetchItems()
                        }
                    } label: {
                        Label("Fetch Items", systemImage: "arrow.counterclockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        vm.addItem()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}
