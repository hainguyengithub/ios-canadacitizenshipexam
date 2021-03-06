//
//  String+Ext.swift
//  canadacitizenshipexam
//
//  Created by hainguyen on 2022-06-19.
//

import Foundation

extension String {

  func split(usingRegex pattern: String) -> [String] {
    // ### Crashes when you pass invalid `pattern`
    let regex = try! NSRegularExpression(pattern: pattern)
    let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
    let ranges = [startIndex..<startIndex] + matches.map{Range($0.range, in: self)!} + [endIndex..<endIndex]
    return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
  }

}
