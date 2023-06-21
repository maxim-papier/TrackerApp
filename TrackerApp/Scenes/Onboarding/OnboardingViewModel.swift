import Foundation

class OnboardingViewModel {
    
    let pages: [OnboardingPage]
    
    private let onboardingPersistenceService: OnboardingPersistence

    init(onboardingPersistenceService: OnboardingPersistence) {
        self.onboardingPersistenceService = onboardingPersistenceService
        let firstPageData = OnboardingPage(backgroundImageName: "onboarding1",
                                               title: "Отслеживайте только то, что хотите!",
                                               buttonLabel: "Вот это технологии!")
        let secondPageData = OnboardingPage(backgroundImageName: "onboarding2",
                                                title: "Даже если это не литры воды и йога",
                                                buttonLabel: "Вот это технологии!")
        pages = [firstPageData, secondPageData]
    }
    
    func getNextPageData(before pageData: OnboardingPage) -> OnboardingPage? {
        if let index = pages.firstIndex(of: pageData), index + 1 < pages.count {
            return pages[index + 1]
        }
        return nil
    }

    func getPreviousPageData(after pageData: OnboardingPage) -> OnboardingPage? {
        if let index = pages.firstIndex(of: pageData), index - 1 >= 0 {
            return pages[index - 1]
        }
        return nil
    }
    
    func numberOfPages() -> Int {
        return pages.count
    }
    
    func onboardingComplete() {
        onboardingPersistenceService.saveOnboardingCompletion()
    }
}
