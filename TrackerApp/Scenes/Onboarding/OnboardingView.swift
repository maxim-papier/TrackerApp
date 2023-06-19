import UIKit

class OnboardingView: UIPageViewController {
    
    private var viewModel: OnboardingViewModel
    private var currentPageView: OnboardingPageView?
    
    private var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .mainColorYP(.blackYP)
        control.pageIndicatorTintColor = .mainColorYP(.grayYP)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstPageData = viewModel.pages.first {
            currentPageView = OnboardingPageView(
                pageData: firstPageData,
                closeButtonAction: { [weak self] in
                    self?.viewModel.onboardingComplete()
                })
            
            if let currentPageView {
                setViewControllers(
                    [currentPageView],
                    direction: .forward,
                    animated: true)
            }
        }
        
        dataSource = self
        delegate = self
        
        pageControl.numberOfPages = viewModel.numberOfPages()
        view.addSubview(pageControl)
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        ])
    }
}

extension OnboardingView: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let pageData = currentPageView?.pageData else { return nil }
        return viewModel.getPreviousPageData(after: pageData).map { OnboardingPageView(pageData: $0, closeButtonAction: { [weak self] in
            guard let self else { return }
            self.viewModel.onboardingComplete() }
        ) }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let pageData = currentPageView?.pageData else { return nil }
        return viewModel.getNextPageData(before: pageData).map { OnboardingPageView(pageData: $0, closeButtonAction: { [weak self] in
            guard let self else { return }
            self.viewModel.onboardingComplete() }
        ) }
    }
}

// MARK: - Delegate Methods

extension OnboardingView: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentPageView = pageViewController.viewControllers?.first as? OnboardingPageView
            
            guard let currentPageView else { return }
            pageControl.currentPage = viewModel.pages.firstIndex(of: currentPageView.pageData) ?? 0
        }
    }
}

