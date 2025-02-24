//
//  CalendarDateRangePickerViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

public protocol CalendarDateRangePickerViewControllerDelegate {
  func didCancelPickingDateRange()
  func didPickDateRange(startDate: Date!, endDate: Date!)
}

public class CalendarDateRangePickerViewController: UICollectionViewController {
  
  let cellReuseIdentifier = "CalendarDateRangePickerCell"
  let headerReuseIdentifier = "CalendarDateRangePickerHeaderView"
  
  public var delegate: CalendarDateRangePickerViewControllerDelegate!
  
  let itemsPerRow = 7
  let itemHeight: CGFloat = 40
  let collectionViewInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
  
  public var minimumDate: Date!
  public var maximumDate: Date!
  
  public var selectedStartDate: Date?
  public var selectedEndDate: Date?
  
  public var selectedColor = UIColor(red: 66/255.0, green: 150/255.0, blue: 240/255.0, alpha: 1.0)
  public var titleText = "Select Dates"
  
  public var weekDayLabelTintColor = UIColor.red
  public var dayLabelTintColor = UIColor.darkGray
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = self.titleText
    
    collectionView?.dataSource = self
    collectionView?.delegate = self
    collectionView?.backgroundColor = UIColor.white
    
    collectionView?.register(CalendarDateRangePickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    collectionView?.register(CalendarDateRangePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
    collectionView?.contentInset = collectionViewInsets
    
    if minimumDate == nil {
      minimumDate = Date()
    }
    if maximumDate == nil {
      maximumDate = Calendar.current.date(byAdding: .year, value: 3, to: minimumDate)
    }
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CalendarDateRangePickerViewController.didTapCancel))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CalendarDateRangePickerViewController.didTapDone))
    self.navigationItem.rightBarButtonItem?.isEnabled = selectedStartDate != nil && selectedEndDate != nil
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.collectionView.scrollRectToVisible(CGRect(x: 0, y: self.collectionView.contentSize.height - 1, width: 10, height: 10), animated: false)
    }
    
  }
  
  @objc func didTapCancel() {
    delegate.didCancelPickingDateRange()
  }
  
  @objc func didTapDone() {
    if selectedStartDate == nil || selectedEndDate == nil {
      return
    }
    delegate.didPickDateRange(startDate: selectedStartDate!, endDate: selectedEndDate!)
  }
  
}

extension CalendarDateRangePickerViewController {
  
  // UICollectionViewDataSource
  
  override public func numberOfSections(in collectionView: UICollectionView) -> Int {
    let difference = Calendar.current.dateComponents([.month], from: minimumDate, to: maximumDate)
    return difference.month! + 1
  }
  
  override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let firstDateForSection = getFirstDateForSection(section: section)
    let weekdayRowItems = 7
    let blankItems = getWeekday(date: firstDateForSection) - 1
    let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
    return weekdayRowItems + blankItems + daysInMonth
  }
  
  override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDateRangePickerCell
    cell.selectedColor = self.selectedColor
    cell.reset()
    cell.label.textColor = weekDayLabelTintColor
    let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
    if indexPath.item < 7 {
      cell.label.text = getWeekdayLabel(weekday: indexPath.item + 1)
    } else if indexPath.item < 7 + blankItems {
      cell.label.text = ""
    } else {
      let dayOfMonth = indexPath.item - (7 + blankItems) + 1
      let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
      cell.date = date
      cell.label.textColor = dayLabelTintColor
      cell.label.text = "\(dayOfMonth)"
      
      if date.isBefore(date: minimumDate) {
        cell.disable()
      }
      
      if selectedStartDate != nil && selectedEndDate != nil && selectedStartDate!.isBefore(date: date) && date.isBefore(date: selectedEndDate!) {
        // Cell falls within selected range
        if dayOfMonth == 1 {
          cell.highlightRight()
        } else if dayOfMonth == getNumberOfDaysInMonth(date: date) {
          cell.highlightLeft()
        } else {
          cell.highlight()
        }
      } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
        // Cell is selected start date
        cell.select()
        if selectedEndDate != nil && !areSameDay(dateA: selectedStartDate!, dateB: selectedEndDate!) {
          cell.highlightRight()
        }
      } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
        cell.select()
        cell.highlightLeft()
      }
    }
    return cell
  }
  
  override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CalendarDateRangePickerHeaderView
      headerView.label.text = getMonthLabel(date: getFirstDateForSection(section: indexPath.section))
      return headerView
    default:
      fatalError("Unexpected element kind")
    }
  }
  
}

extension CalendarDateRangePickerViewController : UICollectionViewDelegateFlowLayout {
  
  override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateRangePickerCell
    guard let date = cell.date else { return }

    if date.isBefore(date: minimumDate) {
      return
    }
    if selectedStartDate == nil {
      selectedStartDate = date
    } else if selectedEndDate == nil {
      if selectedStartDate!.isBefore(date: date) {
        selectedEndDate = date
        self.navigationItem.rightBarButtonItem?.isEnabled = true
      } else {
        // If a cell before the currently selected start date switch start and end
        selectedEndDate = selectedStartDate
        selectedStartDate = date
      }
    } else {
      selectedStartDate = date
      selectedEndDate = nil
    }
    collectionView.reloadData()
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let padding = collectionViewInsets.left + collectionViewInsets.right
    let availableWidth = view.frame.width - padding
    let itemWidth = availableWidth / CGFloat(itemsPerRow)
    return CGSize(width: itemWidth, height: itemHeight)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: view.frame.size.width, height: 50)
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 5
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
}

extension CalendarDateRangePickerViewController {
  
  // Helper functions
  
  func getFirstDate() -> Date {
    var components = Calendar.current.dateComponents([.month, .year], from: minimumDate)
    components.day = 1
    return Calendar.current.date(from: components)!
  }
  
  func getFirstDateForSection(section: Int) -> Date {
    return Calendar.current.date(byAdding: .month, value: section, to: getFirstDate())!
  }
  
  func getMonthLabel(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: date)
  }
  
  func getWeekdayLabel(weekday: Int) -> String {
    var components = DateComponents()
    components.calendar = Calendar.current
    components.weekday = weekday
    let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.MatchingPolicy.strict)
    if date == nil {
      return "E"
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEEE"
    return dateFormatter.string(from: date!)
  }
  
  func getWeekday(date: Date) -> Int {
    return Calendar.current.dateComponents([.weekday], from: date).weekday!
  }
  
  func getNumberOfDaysInMonth(date: Date) -> Int {
    return Calendar.current.range(of: .day, in: .month, for: date)!.count
  }
  
  func getDate(dayOfMonth: Int, section: Int) -> Date {
    var components = Calendar.current.dateComponents([.month, .year], from: getFirstDateForSection(section: section))
    components.day = dayOfMonth
    return Calendar.current.date(from: components)!
  }
  
  func areSameDay(dateA: Date, dateB: Date) -> Bool {
    return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedSame
  }
}

extension Date {
  func isBefore(date other: Date) -> Bool {
    return Calendar.current.compare(self, to: other, toGranularity: .day) == ComparisonResult.orderedAscending
  }
}
