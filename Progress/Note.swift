//
//  Note.swift
//  Progress
//
//  Created by Rohan Deshpande on 7/30/25.
//

import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var dateKey: String // ISO8601 date format (YYYY-MM-DD)
    var content: String
    var lastModified: Date
    var taskSummary: String = ""
    
    init(dateKey: String, content: String = "") {
        self.dateKey = dateKey
        self.content = content
        self.lastModified = Date()
    }
    
    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    static func displayDate(for dateKey: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateKey) else { return dateKey }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "E, MMM d, yyyy" // Abbreviated day format
        return displayFormatter.string(from: date)
    }
}
