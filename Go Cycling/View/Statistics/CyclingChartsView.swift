//
//  CyclingChartsView.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-08-31.
//

import SwiftUI
import CoreData

struct CyclingChartsView: View {
    var invalidData: Bool
    @FetchRequest var bikeRidesIn1Week: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn1WeekBefore: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn5Weeks: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn5WeeksBefore: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn26Weeks: FetchedResults<BikeRide>
    @FetchRequest var bikeRidesIn26WeeksBefore: FetchedResults<BikeRide>

    init() {
        self.invalidData = false
        
        let requests: [NSFetchRequest<BikeRide>?] = BikeRide.fetchRequestsWithDateRanges()
        let countNils = requests.filter({ $0 == nil }).count
        // Use default fetch requests if any of the date range requests failed
        if (countNils > 0 && requests.count == 6) {
            self.invalidData = true
            let request: NSFetchRequest<BikeRide> = BikeRide.fetchRequest()
            request.sortDescriptors = []
            self._bikeRidesIn1Week = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn1WeekBefore = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn5Weeks = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn5WeeksBefore = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn26Weeks = FetchRequest<BikeRide>(fetchRequest: request)
            self._bikeRidesIn26WeeksBefore = FetchRequest<BikeRide>(fetchRequest: request)
        }
        // Otherwise, use the correct date range requests - it is safe to force unwrap here
        else {
            self._bikeRidesIn1Week = FetchRequest<BikeRide>(fetchRequest: requests[0]!)
            self._bikeRidesIn1WeekBefore = FetchRequest<BikeRide>(fetchRequest: requests[1]!)
            self._bikeRidesIn5Weeks = FetchRequest<BikeRide>(fetchRequest: requests[2]!)
            self._bikeRidesIn5WeeksBefore = FetchRequest<BikeRide>(fetchRequest: requests[3]!)
            self._bikeRidesIn26Weeks = FetchRequest<BikeRide>(fetchRequest: requests[4]!)
            self._bikeRidesIn26WeeksBefore = FetchRequest<BikeRide>(fetchRequest: requests[5]!)
        }
    }
    
    var body: some View {
        Section (header: Text(RecordsFormatting.headerStrings[1]), footer: Text(RecordsFormatting.footerStrings[0])) {
            if (!self.invalidData) {
                List {
                    ForEach (0..<3) { index in
                        NavigationLink(destination: BarChartView(index: index)) {
                            SingleChartListCellView(distances: self.getDistanceData(index: index), times: self.getTimeData(index: index), numberOfRoutes: self.getNumberOfRoutes(index: index), index: index)
                        }
                    }
                }
            }
            else {
                Text("Unable to retrieve cycling data at this time.")
            }
        }
    }
    
    // Functions to extract important data from the fetched data
    func getDistanceData(index: Int) -> [Double] {
        var result: [Double] = [0.0, 0.0]
        if (index == 0) {
            for entry in bikeRidesIn1WeekBefore {
                result[0] += entry.cyclingDistance
            }
            for entry in bikeRidesIn1Week {
                result[1] += entry.cyclingDistance
            }
        }
        if (index == 1) {
            for entry in bikeRidesIn5WeeksBefore {
                result[0] += entry.cyclingDistance
            }
            for entry in bikeRidesIn5Weeks {
                result[1] += entry.cyclingDistance
            }
        }
        if (index == 2) {
            for entry in bikeRidesIn26WeeksBefore {
                result[0] += entry.cyclingDistance
            }
            for entry in bikeRidesIn26Weeks {
                result[1] += entry.cyclingDistance
            }
        }
        return result
    }
    
    func getTimeData(index: Int) -> [Double] {
        var result: [Double] = [0.0, 0.0]
        if (index == 0) {
            for entry in bikeRidesIn1WeekBefore {
                result[0] += entry.cyclingTime
            }
            for entry in bikeRidesIn1Week {
                result[1] += entry.cyclingTime
            }
        }
        if (index == 1) {
            for entry in bikeRidesIn5WeeksBefore {
                result[0] += entry.cyclingTime
            }
            for entry in bikeRidesIn5Weeks {
                result[1] += entry.cyclingTime
            }
        }
        if (index == 2) {
            for entry in bikeRidesIn26WeeksBefore {
                result[0] += entry.cyclingTime
            }
            for entry in bikeRidesIn26Weeks {
                result[1] += entry.cyclingTime
            }
        }
        return result
    }
    
    func getNumberOfRoutes(index: Int) -> [Int] {
        if (index == 0) {
            return [bikeRidesIn1WeekBefore.count, bikeRidesIn1Week.count]
        }
        if (index == 1) {
            return [bikeRidesIn5WeeksBefore.count, bikeRidesIn5Weeks.count]
        }
        if (index == 2) {
            return [bikeRidesIn26WeeksBefore.count, bikeRidesIn26Weeks.count]
        }
        return [0, 0]
    }
}

//struct CyclingChartsView_Previews: PreviewProvider {
//    static var previews: some View {
//        CyclingChartsView()
//    }
//}
