//
//  Note.swift
//  Challenge7_iOSNotesApp
//
//  Created by Victoria Treue on 6/9/21.
//

import Foundation

class Note: NSObject, NSCoding {
    
    var title: String
    var body: String
    var dateStr: String
    var date: Date
    
    init(title: String, body: String, dateStr: String, date: Date) {
        self.title = title
        self.body = body
        self.dateStr = dateStr
        self.date = date
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        body = aDecoder.decodeObject(forKey: "body") as? String ?? ""
        dateStr = aDecoder.decodeObject(forKey: "dateStr") as? String ?? ""
        date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "title")
        coder.encode(body, forKey: "body")
        coder.encode(date, forKey: "date")
        coder.encode(dateStr, forKey: "dateStr")
    }
    
    
}
