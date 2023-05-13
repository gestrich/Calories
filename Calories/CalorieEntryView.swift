//
//  CalorieEntryView.swift
//  Calories
//
//  Created by Bill Gestrich on 8/30/20.
//  Copyright © 2020 Bill Gestrich. All rights reserved.
//

import SwiftUI
import CoreData

struct CalorieEntryView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var path: NavigationPath
    @State private var foodName: String = ""
    @State private var calories: String = ""
    @State var foodType: CalorieEntryFoodType = .foodEntry
    @FocusState var foodTextFieldFocused: Bool
    @FocusState var caloriesTextFieldFocused: Bool
    @State var addedFoodIDs: [NSManagedObjectID] = []
    @State var shouldShowAddLabel: Bool = false
    
    @SectionedFetchRequest(fetchRequest: PersistenceManager.recentFetchRequest(), sectionIdentifier: \.sectionedDateName)
    var sectionedFoodResults: SectionedFetchResults<String, Food>
    
    @State var inputContext: CalorieEntryViewInputContext
    
    var body: some View {
        VStack{
            TextField(namePlaceholderText, text: $foodName)
                .onSubmit {
                    caloriesTextFieldFocused = true
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($foodTextFieldFocused)
                .padding()
            TextField(caloriesPlaceholderText, text: $calories)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.numberPad)
                .focused($caloriesTextFieldFocused)
                .padding()
            ZStack {
                if let lastAddedFood = lastAddedFood {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("\(lastAddedFood.name) \(lastAddedFood.calories) calories")
                    }
                        .foregroundColor(Color(ThemeKit.buttonTextColor()))
                        .opacity(shouldShowAddLabel ? 1.0 : 0.0)
                }
                Button(action: {
                    saveFoodEntry()
                    resetInputFieldsAndFocusFoodTextField()
                }) {
                    Text(buttonText)
                        .foregroundColor(Color(ThemeKit.buttonTextColor()))
                }
                .opacity(!isFormReadyForSubmission || shouldShowAddLabel ? 0.0 : 1.0)
            }
            .padding()
            if case .createContext = inputContext {
                calorieListView
            }
            Spacer()
        }
        .padding(.top, 30)
        .navigationTitle(actionTitle)
        .onAppear {
            if case .editContext(let foodToEdit) = inputContext {
                foodName = foodToEdit.name
                calories = foodToEdit.absoluteCalories().stringValue
                foodType = foodToEdit.isExercise() ? .exerciseEntry : .foodEntry
            }

            foodTextFieldFocused = true
            updateFetchRequest()//View is hanging onto fetch request after dismissal and reopening.
        }
        .onChange(of: foodName) { newValue in
            updateFetchRequest()
        }
        .onChange(of: foodType, perform: { newValue in
            switch newValue {
            case .foodEntry:
                calories = calories.replacingOccurrences(of: "-", with: "")
            case .exerciseEntry:
                calories = "-" + calories
            }
        })
        .onChange(of: calories, perform: { newValue in
            if calories.contains("-") {
                foodType = .exerciseEntry
            } else {
                foodType = .foodEntry
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if case .editContext(let foodToEdit) = inputContext {
                    Button(role: .destructive) {
                        delete(food: foodToEdit)
                        path.removeLast()
                    } label: {
                        Image(systemName: "trash")
                            .tint(Color.red)
                    }
                }
            }
            if foodTextFieldFocused {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Next") {
                        caloriesTextFieldFocused = true
                    }
                    .disabled(foodName.count == 0)
                }
            } else if caloriesTextFieldFocused {
                ToolbarItemGroup(placement: .keyboard) {
                    Picker("Activity Type", selection: $foodType) {
                        foodImage
                            .tag(CalorieEntryFoodType.foodEntry)
                        runImage
                            .tag(CalorieEntryFoodType.exerciseEntry)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button(actionTitle) {
                        saveFoodEntry()
                        resetInputFieldsAndFocusFoodTextField()
                    }
                    .disabled(!isFormReadyForSubmission)
                }
            }
        }
    }
    
    var calorieListView: some View {
        return List {
            ForEach (sectionedFoodResults) { sectionItems in
                Section(CalorieEntryView.sectionTitleForFoods(foods: sectionItems.map({$0}), formattedDateName: sectionItems.id)){
                    ForEach(sectionItems) { food in
                        Button {
                            cloneFood(food)
                        } label: {
                            CalorieRowView(name: food.name, calories: food.calories.intValue, shouldShowAddButton: true)
                                .listRowSeparator(.hidden)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                cloneFood(food)
                            } label: {
                                Label("Add", systemImage: "plus.circle")
                            }
                            .tint(Color(uiColor: ThemeKit.baseColor()))
                        }
                    }
                    .onDelete { indexSet in
                        delete(foods: sectionItems.map({$0}), at: indexSet)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .listStyle(.plain)
    }
    
    var lastAddedFood: Food? {
        guard let lastAddedID = addedFoodIDs.last else {return nil}
        return try? managedObjectContext.existingObject(with: lastAddedID) as? Food
    }
    
    var actionTitle: String {
        switch inputContext {
        case .editContext:
            return "Update"
        case .createContext:
            return "Add"
        }
    }
    
    var buttonText: String {
        return actionTitle
    }
    
    func updateFetchRequest() {
        let trimmedFoodName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedFoodName.isEmpty {
            sectionedFoodResults.nsPredicate = PersistenceManager.recentFetchPredicateFiltered(foodName: trimmedFoodName)
        } else {
            sectionedFoodResults.nsPredicate = PersistenceManager.recentFetchPredicate()
        }
    }
    
    var namePlaceholderText: String {
        switch foodType {
        case .foodEntry:
            return "Name"
        case .exerciseEntry:
            return "Name"
        }
    }
    
    var caloriesPlaceholderText: String {
        return "Calories"
    }
    
    var isFormReadyForSubmission: Bool {
        switch inputContext {
        case .editContext:
            return fieldsChanged && !foodName.isEmpty && !calories.isEmpty
        case .createContext:
            return !foodName.isEmpty && !calories.isEmpty
        }
    }
    
    var fieldsChanged: Bool {
        switch inputContext {
        case .editContext(let food):
            return food.name != foodName || food.calories.stringValue != calories
        case .createContext:
            return !foodName.isEmpty && !calories.isEmpty
        }
    }
    
    func resetInputFieldsAndDismissKeyboard() {
        hideKeyboard()
        resetInputFields()
    }
    
    func resetInputFieldsAndFocusFoodTextField() {
        self.foodName = ""
        self.calories = ""
        foodTextFieldFocused = true
    }
    
    func resetInputFields() {
        self.foodName = ""
        self.calories = ""
    }
    
    func saveFoodEntry() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedObjectContext)
        let food: Food
        switch inputContext {
        case .editContext(let foodToEdit):
            food = foodToEdit
        case .createContext:
            food = Food(entity:entityDescription!, insertInto:managedObjectContext)
            food.created = Date()
        }
        
        food.name = foodName
        
        var calNum = NSNumber(integerLiteral: 0)
        if let calsInt = Int(calories) {
            calNum = NSNumber(integerLiteral: calsInt)
        }
        
        switch foodType {
        case .foodEntry:
            food.calories =  calNum
        case .exerciseEntry:
            food.calories =  calNum.intValue < 0 ? calNum : NSNumber(value: -calNum.intValue)
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving food: \(error)")
        }
        
        switch inputContext {
        case .editContext:
            path.removeLast()
        case .createContext:
            animateFoodAddition(food)
        }
    }
    
    func animateFoodAddition(_ food: Food) {
        //TODO: Probably a better way to sequence animations using combine
        addedFoodIDs.append(food.objectID)
        let shouldInterruptLastAnimation = shouldShowAddLabel
        if shouldInterruptLastAnimation {
            //Will restart animation to make visual seperation when the
            //same entry added in quick succession.
            shouldShowAddLabel = false
        }

        withAnimation(.easeOut) {
            shouldShowAddLabel = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let thisAnimationInterrupted = food.objectID != addedFoodIDs.last
            guard !thisAnimationInterrupted else {return}
            withAnimation(.easeOut) {
                shouldShowAddLabel = false
            }
        }
    }
    
    func cloneFood(_ foodToClone: Food) {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Food", in: managedObjectContext)
        let food = Food(entity:entityDescription!, insertInto:managedObjectContext)
        food.created = Date()
        food.name = foodToClone.name
        food.calories = foodToClone.calories
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Error cloning food: \(error)")
        }
        
        resetInputFields()
        animateFoodAddition(food)
    }
    
    
    func delete(foods: [Food], at offsets:IndexSet){
        offsets.map { foods[$0]}.forEach { food in
            delete(food: food)
        }
    }
    
    func delete(food: Food) {
        managedObjectContext.delete(food)
        do {
            try managedObjectContext.save()
        } catch {
            print("Error deleting food \(food), \(error)")
        }
    }
    
    var foodImage: Image {
        Image(systemName: "fork.knife")
    }
    
    var runImage: Image {
        return Image(systemName: "figure.run")
    }
    
    static func sectionTitleForFoods(foods: [Food], formattedDateName: String) -> String {
        var sectionCalorieCount = 0
        var allFromToday = true
            for food in foods {
                sectionCalorieCount += food.calories.intValue
                if !food.created.includedInTodaysLog() {
                    allFromToday = false
                }
            }
        
        var dateName = formattedDateName
        if allFromToday == true {
            dateName = "Today"
        }
        
        return dateName + "   (\(sectionCalorieCount) cals)"
    }
}

enum CalorieEntryFoodType {
    case foodEntry
    case exerciseEntry
}

enum CalorieEntryViewInputContext {
    case editContext(food: Food)
    case createContext
}

struct CalorieEntryView_Previews: PreviewProvider {
    static var previews: some View {
        
        var path = NavigationPath()
        let pathBinding: Binding<NavigationPath> = Binding {
            return path
        } set: { updatedPath in
            path = updatedPath
        }
        
        CalorieEntryView(path: pathBinding, inputContext: .createContext)
    }
}
