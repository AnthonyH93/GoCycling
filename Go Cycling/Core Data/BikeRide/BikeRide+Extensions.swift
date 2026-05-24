//
//  BikeRide+Extensions.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-04-25.
//

import Foundation
import CoreData

extension BikeRide {
    
    static func allBikeRides() -> [BikeRide] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
    
    static func allBikeRidesSorted() -> [BikeRide] {
        let bikeRidesUnsorted = allBikeRides()
        var bikeRides: [BikeRide] = []
        switch Preferences.shared.sortingChoiceConverted {
        case .distanceAscending:
            bikeRides = BikeRide.sortByDistance(list: bikeRidesUnsorted, ascending: true)
        case .distanceDescending:
            bikeRides = BikeRide.sortByDistance(list: bikeRidesUnsorted, ascending: false)
        case .dateAscending:
            bikeRides = BikeRide.sortByDate(list: bikeRidesUnsorted, ascending: true)
        case .dateDescending:
            bikeRides = BikeRide.sortByDate(list: bikeRidesUnsorted, ascending: false)
        case .timeAscending:
            bikeRides = BikeRide.sortByTime(list: bikeRidesUnsorted, ascending: true)
        case .timeDescending:
            bikeRides = BikeRide.sortByTime(list: bikeRidesUnsorted, ascending: false)
        }
        return bikeRides
    }
    
    static func allRouteNames() -> [String] {
        let allBikeRides = allBikeRides()
        var uniqueNames: [String] = []

        for ride in allBikeRides {
            if (uniqueNames.firstIndex(of: ride.cyclingRouteName) == nil) {
                if (ride.cyclingRouteName != "Uncategorized") {
                    uniqueNames.append(ride.cyclingRouteName)
                }
            }
        }
        
        return uniqueNames.sorted { $0.lowercased() < $1.lowercased() }
    }
    
    static func allCategories() -> [Category] {
        let allBikeRides = allBikeRidesSorted()
        var categories: [Category] = []
        var names: [String] = []
        var numbers: [Int] = []
        var uncategorizedCounter = 0
        
        for ride in allBikeRides {
            if (names.firstIndex(of: ride.cyclingRouteName) == nil) {
                if (ride.cyclingRouteName != "Uncategorized") {
                    names.append(ride.cyclingRouteName)
                    numbers.append(1)
                }
                else {
                    uncategorizedCounter += 1
                }
            }
            else {
                numbers[names.firstIndex(of: ride.cyclingRouteName)!] += 1
            }
        }
        
        for (index, name) in names.enumerated() {
            categories.append(Category(name: name, number: numbers[index]))
        }
        
        // Sort the user created categories alphabeticaly
        categories = categories.sorted { $0.name.lowercased() < $1.name.lowercased() }
        
        if (uncategorizedCounter > 0) {
            categories.insert(Category(name: "Uncategorized", number: uncategorizedCounter), at: 0)
        }
        
        if (allBikeRides.count > 0) {
            categories.insert(Category(name: "All", number: allBikeRides.count), at: 0)
        }
        
        return categories
    }
    
    // Fetch current and previous period rides for the new SwiftCharts path
    static func fetchRidesForPeriod(_ period: ChartPeriod, calendar: Calendar = Calendar.current) -> (current: [BikeRide], previous: [BikeRide]) {
        let context = PersistenceController.shared.container.viewContext

        func fetch(from fromDate: Date, to toDate: Date) -> [BikeRide] {
            let request: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
            request.sortDescriptors = []
            let fromPred = NSPredicate(format: "%@ <= %K", fromDate as NSDate, #keyPath(BikeRide.cyclingStartTime))
            let toPred   = NSPredicate(format: "%K < %@",  #keyPath(BikeRide.cyclingStartTime), toDate as NSDate)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPred, toPred])
            return (try? context.fetch(request)) ?? []
        }

        var cal = calendar
        cal.timeZone = .current
        let today    = cal.startOfDay(for: Date())
        let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!

        switch period {
        case .oneWeek:
            let cFrom = cal.date(byAdding: .day, value: -6,  to: today)!
            let pFrom = cal.date(byAdding: .day, value: -13, to: today)!
            return (fetch(from: cFrom, to: tomorrow), fetch(from: pFrom, to: cFrom))

        case .oneMonth:
            let cFrom = cal.date(byAdding: .day, value: -29, to: today)!
            let pFrom = cal.date(byAdding: .day, value: -59, to: today)!
            return (fetch(from: cFrom, to: tomorrow), fetch(from: pFrom, to: cFrom))

        case .threeMonths:
            let cFrom = cal.date(byAdding: .day, value: -89,  to: today)!
            let pFrom = cal.date(byAdding: .day, value: -179, to: today)!
            return (fetch(from: cFrom, to: tomorrow), fetch(from: pFrom, to: cFrom))

        case .sixMonths:
            let cFrom = cal.date(byAdding: .day, value: -179, to: today)!
            let pFrom = cal.date(byAdding: .day, value: -359, to: today)!
            return (fetch(from: cFrom, to: tomorrow), fetch(from: pFrom, to: cFrom))

        case .yearToDate:
            let year = cal.component(.year, from: today)
            var ytdComps = DateComponents(); ytdComps.year = year; ytdComps.month = 1; ytdComps.day = 1
            let cFrom = cal.date(from: ytdComps) ?? today
            var prevComps = DateComponents(); prevComps.year = year - 1; prevComps.month = 1; prevComps.day = 1
            let pFrom = cal.date(from: prevComps) ?? today
            let pTo   = cal.date(byAdding: .year, value: -1, to: tomorrow) ?? today
            return (fetch(from: cFrom, to: tomorrow), fetch(from: pFrom, to: pTo))

        case .oneYear:
            let cFrom = cal.date(byAdding: .day, value: -364, to: today)!
            let pFrom = cal.date(byAdding: .day, value: -729, to: today)!
            return (fetch(from: cFrom, to: tomorrow), fetch(from: pFrom, to: cFrom))
        }
    }

    // Functions to get data for the charts on the statistics tab
    static func bikeRidesInPastWeek() -> [BikeRide] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequestsWithDateRanges()[0] ?? BikeRide.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
    
    static func bikeRidesInPast5Weeks() -> [BikeRide] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequestsWithDateRanges()[2] ?? BikeRide.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
    
    static func bikeRidesInPast30Weeks() -> [BikeRide] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<BikeRide> = BikeRide.fetchRequestsWithDateRanges()[4] ?? BikeRide.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting BikeRides: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BikeRide]()
    }
}
