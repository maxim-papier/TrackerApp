//
//  Localization.swift
//  TrackerApp
//
//  Created by Maxim Brykov on 22.06.2023.
//

import Foundation

final class LocalizationService {
    
    func localized(_ key: String, comment: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: comment)
        return String(format: format, locale: Locale.current, arguments: args)
    }
    
    func pluralized(_ key: String, count: Int) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String.localizedStringWithFormat(format, count)
    }
}
