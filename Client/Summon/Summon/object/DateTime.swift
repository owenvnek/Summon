//
//  DateTime.swift
//  Summon
//
//  Created by Owen Vnek on 1/4/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation

class DateTime {
    
    private var year: Int
    private var month: Int
    private var day: Int
    private var hour: Int
    private var minute: Int
    
    init() {
        year = 0
        month = 0
        day = 0
        hour = 0
        minute = 0
    }
    
    func get_year() -> Int {
        return year
    }
    
    func get_month() -> Int {
        return month
    }
    
    func get_day() -> Int {
        return day
    }
    
    func get_hour() -> Int {
        return hour
    }
    
    func get_minute() -> Int {
        return minute
    }
    
    func set(year: Int) {
        self.year = year
    }
    
    func set(month: Int) {
        self.month = month
    }
    
    func set(day: Int) {
        self.day = day
    }
    
    func set(hour: Int) {
        self.hour = hour
    }
    
    func set(minute: Int) {
        self.minute = minute
    }
    
    func get_month_text() -> String {
        switch month {
        case 1: return "Jan"
        case 2: return "Feb"
        case 3: return "Mar"
        case 4: return "Apr"
        case 5: return "May"
        case 6: return "Jun"
        case 7: return "Jul"
        case 8: return "Aug"
        case 9: return "Sep"
        case 10: return "Oct"
        case 11: return "Nov"
        case 12: return "Dec"
        default:
            return "Invalid date"
        }
    }
    
    func constrain_digits(number: Int, digits: Int) -> String {
        let test = "\(number)"
        if (test.count < digits) {
            let diff = digits - test.count
            var result = test
            for _ in 0..<diff {
                result = "0\(result)"
            }
            return result
        }
        return test
    }
    
    func to_string() -> String {
        if hour > 12 {
            return "\(day) \(get_month_text()) \(hour - 12):\(constrain_digits(number: minute, digits: 2)) PM"
        } else {
            return "\(day) \(get_month_text()) \(hour):\(constrain_digits(number: minute, digits: 2)) AM"
        }
    }
    
    func to_string_date_only() -> String {
        return "\(day) \(get_month_text()) \(year)"
    }
    
    static func from(data: NSDictionary) -> DateTime {
        if (data.count > 0) {
            let datetime = DateTime()
            datetime.set(year: data["year"] as! Int)
            datetime.set(month: data["month"] as! Int)
            datetime.set(day: data["day"] as! Int)
            datetime.set(hour: data["hour"] as! Int)
            datetime.set(minute: data["minute"] as! Int)
            return datetime
        } else {
            return DateTime()
        }
    }
    
}
