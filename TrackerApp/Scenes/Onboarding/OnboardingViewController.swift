import UIKit

class OnboardingViewController: UIPageViewController {

    private var viewModel: OnboardingViewModel
    
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
        
        setViewControllers(
            [OnboardingPageView(pageData: viewModel.getCurrentPage())],
            direction: .forward,
            animated: true,
            completion: nil
        )
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

// MARK: -  Data Source Methods

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        
        let currentPageView = viewController as? OnboardingPageView
        guard let pageData = currentPageView?.pageData else { return nil }

        return viewModel.getPreviousPageData(after: pageData).map { OnboardingPageView(pageData: $0) }
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {

        let currentPageView = viewController as? OnboardingPageView
        guard let pageData = currentPageView?.pageData else { return nil }
        
        return viewModel.getNextPageData(before: pageData).map { OnboardingPageView(pageData: $0) }
    }
}

// MARK: - Delegate Methods

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageControl.currentPage = viewModel.currentPageIndex
        }
    }
}
