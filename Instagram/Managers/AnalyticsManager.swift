//
//  AnalyticsManager.swift
//  Instagram
//
//  Created by Ann Yank on 15.12.21.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {
        
    }
    
    func logEvent() {
        Analytics.logEvent("", parameters: [:])
    }
}
