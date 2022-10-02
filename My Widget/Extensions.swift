//
//  Extensions.swift
//  Widget Demo App
//
//  Created by Abdullah Kardas on 18.09.2022.
//

import Foundation
import SwiftUI

extension DateFormatter {
  static let yyyyMMdd: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

extension Date {
    init?(yyyyMMdd: String) {
        guard let date = DateFormatter.yyyyMMdd.date(from: yyyyMMdd) else { return nil }
        self.init(timeInterval: 0, since: date)
    }

    init(yourDate yyyyMMdd: String) {
        let date = DateFormatter.yyyyMMdd.date(from: yyyyMMdd)!
        self.init(timeInterval: 0, since: date)
    }
}
extension Color {
    static let paleYellow   = Color(red: 252/255, green: 225/255, blue: 121/255)
    static let palePink     = Color(red: 254/255, green: 138/255, blue: 138/255)
    static let darkGreen    = Color(red: 0/255, green: 67/255, blue: 13/255)
    static let paleGreen    = Color(red: 163/255, green: 230/255, blue: 127/255)
    static let paleBlue     = Color(red: 139/255, green: 229/255, blue: 233/255)
    static let skyBlue      = Color(red: 103/255, green: 155/255, blue: 197/255)
    static let paleOrange   = Color(red: 197/255, green: 161/255, blue: 103/255)
    static let darkOrange   = Color(red: 172/255, green: 110/255, blue: 16/255)
    static let paleRed      = Color(red: 174/255, green: 80/255, blue: 80/255)
    static let paleBrown    = Color(red: 124/255, green: 102/255, blue: 85/255)
}

