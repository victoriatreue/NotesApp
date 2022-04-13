//
//  TableViewCell.swift
//  Challenge7_iOSNotesApp
//
//  Created by Victoria Treue on 6/9/21.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        title.textColor = Colors.mainTextColor
        body.textColor = Colors.secondaryTextColor
        date.textColor = Colors.tertiaryTextColor
        
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 0.25
        self.layer.borderColor = UIColor.darkGray.cgColor
    }
}
