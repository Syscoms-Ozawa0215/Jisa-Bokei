//
//  DatePickerCell.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2020/10/10.
//  Copyright © 2020 Private. All rights reserved.
//

import UIKit

protocol DatePickerCellDelegate: AnyObject {
    func setDate(dt: Date) -> Void
}

class DatePickerCell: UITableViewCell {
    
    weak var datePickerCellDelegate: DatePickerCellDelegate?
    
    @IBOutlet weak var pickDatetime: UIDatePicker!
    
    @IBAction func dateChanged(_ sender: Any) {
        print("DatePickerCell:dateChanged call.")
        self.datePickerCellDelegate?.setDate(dt: pickDatetime.date)
    }
}
