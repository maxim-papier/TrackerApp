import Foundation

protocol OnboardingPersistence {
    func saveOnboardingCompletion()
    func hasCompletedOnboarding() -> Bool
}

class OnboardingPersistenceService: OnboardingPersistence {
    
    private let onboardingKey = "didCompleteOnboarding"
        
    func saveOnboardingCompletion() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingKey)
    }
}
