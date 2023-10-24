//
//  CloudKitModel.swift
//  Aula-CloudKit
//
//  Created by Lucca Lopes on 10/10/23.
//

import SwiftUI
import CloudKit
import Combine

@MainActor
final class CloudKitModel: ObservableObject {
    //A variável de itens será a mais usada ao longo do projeto, nela armazenaremos e os dados recuperados do iCloud
    @Published var itens: [Item] = []
    
    //Esta variável servirá apenas para compor o texto nos itens criados
    var currentIndex: Int = 0
    
    // O container é uma referência direta ao banco de dados do app, para criá-lo precisamos de um conta de desenvolvedor.
    let container = CKContainer.init(identifier: "iCloud.Aula.CloudKit")
    
    // Aqui temos a variável da database, nosso principal acesso aos dados armazenados no iCloud do usuário.
    let database: CKDatabase
    
    init() {
        //Definição da database que será usada para a database pública do app, não é a melhor prática introduzir dados individuais dos usuários no conjunto público de dados, mas aqui estamos em um ambiente controlado
        self.database = container.publicCloudDatabase
        
        //Abrimos uma tarefa assíncrona que estará rodando em uma Thread secundária, para evitar travamentos no app
        Task {
            //Aqui recebemos os dados assim que terminarmos de carregá-los do iCloud
            await fetchItems()
            //Uma simples atualização do index que será usado para atualizar os textos dos novos dados
            currentIndex = itens.count
        }
    }
    
    //Função para adicionar um novo item automaticamente e salvá-lo no iCloud
    public func addItem() {
        withAnimation {
            currentIndex+=1
            let newItem = Item(text: "Texto \(currentIndex)")
            itens.append(newItem)
            saveItem(item: newItem)
        }
    }

    public func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                itens.remove(at: index)
            }
        }
    }
    
    private func saveItem(item: Item) {
        //Criando um novo record a partir do nome da classe que foi criada na database do icloud
        let newItem = CKRecord(recordType: "Item")
        //Setando o valor de uma key do record criado a partir do modelo da database
        newItem.setValue(item.text, forKey: "text")
        newItem.setValue(Date(), forKey: "timestamp")
        
        //Setando o valor de uma key do record criado a partir do modelo da database
        newItem.setValuesForKeys([
            "text": item.text,
            "timestamp": Date()
        ])
        
        //salvando o record definido na database do usuário que estamos acessando
        database.save(newItem) { record, error in
            if error == nil {
                //Printando caso o record seja salvo corretamente
                print("Record saved succesfully")
            }else{
                //Printando o erro caso tenha algum
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    public func fetchItems() async{
        let predicate: NSPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Item", predicate: predicate)
        do {
            let resultados = try await database.records(matching: query)
            itens.removeAll()
            
            do {
                for resultado in resultados.matchResults {
                    let record = try resultado.1.get()
                    itens.append(Item(text: record["text"] as! String))
                    print("record - \(record)")
                }
            } catch {
                print("erro - \(error.localizedDescription)")
            }

        } catch {
            print("erro - \(error.localizedDescription)")
        }
    }
}
