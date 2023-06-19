import UIKit

class OnboardingPageView: UIViewController {
    var pageData: OnboardingPage
    var closeButtonAction: (() -> Void)
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainColorYP(.blackYP)
        label.font = FontYP.bold32
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mainColorYP(.blackYP)
        button.titleLabel?.font = FontYP.medium16
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    init(pageData: OnboardingPage,
         closeButtonAction: @escaping (() -> Void)) {
        self.pageData = pageData
        self.closeButtonAction = closeButtonAction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setData()
    }
    
    // MARK: Action
    @objc private func closeButtonTapped() {
        closeButtonAction()
        dismiss(animated: true)
    }
    
    // MARK: Private Methods
    
    private func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(button)
        
        let guide = view.safeAreaLayoutGuide
        let hInset: CGFloat = 16
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: hInset),
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -hInset),
            titleLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            
            button.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: hInset),
            button.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -hInset),
            button.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setData() {
        backgroundImageView.image = UIImage(named: pageData.backgroundImageName)
        titleLabel.text = pageData.title
        button.setTitle(pageData.buttonLabel, for: .normal)
        button.setTitleColor(.mainColorYP(.whiteYP), for: .normal)
    }
}
