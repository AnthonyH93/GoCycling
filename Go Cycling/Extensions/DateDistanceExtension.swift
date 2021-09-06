//
//  DateDistanceExtension.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2021-09-02.
//  Found at https://stackoverflow.com/questions/40633139/swift-compare-date-by-days

import Foundation

extension Date {
    // Used to compare dates
    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }
}
