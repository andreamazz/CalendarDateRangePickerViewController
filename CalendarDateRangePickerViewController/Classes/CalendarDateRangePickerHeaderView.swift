//
//  CalendarDateRangePickerHeaderView.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

class CalendarDateRangePickerHeaderView: UICollectionReusableView {
  
  var label = UILabel(frame: .zero)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initLabel()
  }
  
  func initLabel() {
    label.frame = frame
    label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
    label.font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
    label.textColor = UIColor.lightGray
    label.textAlignment = NSTextAlignment.center
    self.addSubview(label)
  }
  
}
