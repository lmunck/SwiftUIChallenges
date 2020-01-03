//
//  ContentView.swift
//  SwiftUIChallenges
//
//  Created by Anders Munck on 03/01/2020.
//  Copyright © 2020 Anders Munck. All rights reserved.
//

/*
Situation:
Two pickers, one selecting a category and the other selecting the items in that category.

Challenge:
The second picker shows the right items, but always select items from the first category.

To see issue, copy below code into ContentView on a single-view app.
*/


import SwiftUI

struct Item: Identifiable {
    var id = UUID()
    var category:String
    var item:String
}

let myCategories:[String] = ["Category 1","Category 2"]

let myItems:[Item] = [
    Item(category: "Category 1", item: "Item 1.1"),
    Item(category: "Category 1", item: "Item 1.2"),
    Item(category: "Category 2", item: "Item 2.1"),
    Item(category: "Category 2", item: "Item 2.2"),
    Item(category: "Category 2", item: "Item 2.3"),
    Item(category: "Category 2", item: "Item 2.4"),
]

class MyObject: ObservableObject {
    
    // Select Category
    @Published var selectedCategory:String = myCategories[0]
    @Published var selectedCategoryItems:[Item] = []
    @Published var selectedCategoryInt:Int = 0 {
        didSet {
            selectCategoryActions(selectedCategoryInt)
        }
    }
    // Select Item
    @Published var selectedItem:Item = myItems[0]
    @Published var selectedItemInt:Int = 0 {
        didSet {
            selectedItem = myItems[selectedItemInt]
        }
    }
    
    // Initialize values
    init() {
        selectCategoryActions(selectedCategoryInt)
    }
    
    // Actions when selecting a new category
    func selectCategoryActions(_ selectedCategoryInt:Int) {
        selectedCategory = myCategories[selectedCategoryInt]
        
        // Get items in category
        selectedCategoryItems = myItems.filter{ $0.category.contains(selectedCategory)}
        
        // Select item in category
        let selectedItemIntWrapped:Int? = myItems.firstIndex { $0.category == selectedCategory }
        if let selectedItemInt = selectedItemIntWrapped {
            self.selectedItem = myItems[selectedItemInt]
        }
    }
}



// Picker for selecting a category
struct SelectCategory: View {
    var myCategories:[String]
    @Binding var selectedCategoryInt:Int
    var body: some View {
        VStack {
            Picker(selection: self.$selectedCategoryInt, label: Text("Select category")) {
                ForEach(0 ..< self.myCategories.count, id: \.self) {
                    Text("\(self.myCategories[$0])")
                }
            }.labelsHidden()
        }
    }
}

// Picker for selecting items within the category
struct SelectItem: View {
    var selectedCategoryItems:[Item]
    @Binding var selectedItemInt:Int
    var body: some View {
        VStack {
            // MARK: Something is going wrong here. I don't get right Item ID's
            Picker(selection: self.$selectedItemInt, label: Text("Select item")) {
                ForEach(0 ..< self.selectedCategoryItems.count, id: \.self) {
                    Text("\(self.selectedCategoryItems[$0].item)")
                }
                /*ForEach(selectedCategoryItems, id: \.id) { item in
                    Text("\(item.content)")
                }*/
            }.labelsHidden()
        }
    }
}

struct ContentView: View {
    @ObservedObject var myObject = MyObject()

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("When selecting Category 2, it shows Category 2 items, but selects from Category 1.")
            Text("Selected category: \(myObject.selectedCategory)")
            Text("Selected item: \(myObject.selectedItem.item)")
            SelectCategory(
                myCategories: myCategories,
                selectedCategoryInt: self.$myObject.selectedCategoryInt)
            
            SelectItem(
                selectedCategoryItems: self.myObject.selectedCategoryItems,
                selectedItemInt: self.$myObject.selectedItemInt)
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
