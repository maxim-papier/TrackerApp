import Foundation

class OnboardingViewModel {
    
    private let pages: [OnboardingPageData]
    var currentPageIndex: Int = 0

    init() {
        let firstPageData = OnboardingPageData(backgroundImageName: "onboarding1",
                                               title: "Отслеживайте только то, что хотите!",
                                               buttonLabel: "Вот это технологии!")
        let secondPageData = OnboardingPageData(backgroundImageName: "onboarding2",
                                                title: "Даже если это не литры воды и йога",
                                                buttonLabel: "Вот это технологии!")
        pages = [firstPageData, secondPageData]
    }

    func getCurrentPage() -> OnboardingPageData {
        return pages[currentPageIndex]
    }
    
    func getNextPageData(before pageData: OnboardingPageData) -> OnboardingPageData? {
        if let index = pages.firstIndex(of: pageData), index + 1 < pages.count {
            currentPageIndex = index + 1
            return pages[currentPageIndex]
        }
        return nil
    }

    func getPreviousPageData(after pageData: OnboardingPageData) -> OnboardingPageData? {
        if let index = pages.firstIndex(of: pageData), index - 1 >= 0 {
            currentPageIndex = index - 1
            return pages[currentPageIndex]
        }
        return nil
    }

    private func canMoveToNextPage() -> Bool {
        return currentPageIndex < pages.count - 1
    }
    
    private func canMoveToPreviousPage() -> Bool {
        return currentPageIndex > 0
    }
    
    func goToNextPage() {
        if canMoveToNextPage() {
            currentPageIndex += 1
        }
    }
    
    func goToPreviousPage() {
        if canMoveToPreviousPage() {
            currentPageIndex -= 1
        }
    }
    
    func didSwipeLeft() {
        if canMoveToNextPage() {
            currentPageIndex += 1
        }
    }
    
    func didSwipeRight() {
        if canMoveToPreviousPage() {
            currentPageIndex -= 1
        }
    }
    
    func isLastPage() -> Bool {
        return currentPageIndex == pages.count - 1
    }
    
    func isFirstPage() -> Bool {
        return currentPageIndex == 0
    }
    
    func numberOfPages() -> Int {
        return pages.count
    }
}
