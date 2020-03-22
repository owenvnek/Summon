//
//  SummonSorting.swift
//  Summon
//
//  Created by Owen Vnek on 2/3/20.
//  Copyright © 2020 Nio. All rights reserved.
//

import Foundation

class SummonSorting {
    
    func get_comparator() -> (Summon, Summon) -> Bool {
        return {
            lhs, rhs in
            let datetime1 = lhs.get_datetime()
            let datetime2 = rhs.get_datetime()
            if datetime1.get_year() > datetime2.get_year() {
                return false
            } else if datetime1.get_year() < datetime2.get_year() {
                return true
            } else {
                if datetime1.get_month() > datetime2.get_month() {
                    return false
                } else if datetime1.get_month() < datetime2.get_month() {
                    return true
                } else {
                    if datetime1.get_day() > datetime2.get_day() {
                        return false
                    } else if datetime1.get_day() < datetime2.get_day() {
                        return true
                    } else {
                        if datetime1.get_hour() > datetime2.get_hour() {
                            return false
                        } else if datetime1.get_hour() < datetime2.get_hour() {
                            return true
                        } else {
                            return !(datetime1.get_minute() > datetime2.get_minute())
                        }
                    }
                }
            }
        }
    }
    
}
