//
//  String+Helpers.swift
//  LanguageManager-iOS
//
//  Created by abedalkareem omreyh on 10/11/2020.
//

import Foundation

public extension String {

  ///
  /// Localize the current string to the selected language
  ///
  /// - returns: The localized string
  ///
  func localiz(comment: String = "") -> String {
    guard let  bundle = LanguageManager.shared.langBundle else {
        return NSLocalizedString(self, tableName: nil, comment: comment)
    }
    return NSLocalizedString(self, tableName: nil,bundle: bundle, comment: comment)
  }

}
