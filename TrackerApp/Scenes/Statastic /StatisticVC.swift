import UIKit

final class StatisticVC: UITableViewController {
    
    private let placeholder = PlaceholderType.noStats.placeholder
    
    private let stores: DependencyContainer
    private let viewModel: StatisticsViewModel
    
    // Так как кол-во завершённый трекеров — основа статистики
    // то как только оно становится выше нуля, я показываю данные,
    // если же равно нулю — плейсхолдер
    private var totalCompletedTrackers: Int = 0 { didSet { updateView() } }
    
    init(stores: DependencyContainer) {
        self.stores = stores
        self.viewModel = StatisticsViewModel(stores: stores)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.mainColorYP(.whiteYP)
        tableView.backgroundColor = UIColor.mainColorYP(.whiteYP)
        setupNavBar()
        setupTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        totalCompletedTrackers = viewModel.completedTrackersAmount
        tableView.reloadData()
    }
    
    private func updateView() {
        if totalCompletedTrackers == 0 {
            tableView.backgroundView = placeholder
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
    
    private func setupTable() {
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.identifier)
        
        tableView.contentInset = .init(top: 77, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        
        tableView.backgroundView = placeholder
    }
    
    private func setupNavBar() {
        title = "Статистика"
    }
}

// MARK: -  Delegates

extension StatisticVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return totalCompletedTrackers > 0 ? 4 : 0 // решаю показывать ли таблицу или плейсхолдер
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCompletedTrackers > 0 ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: StatisticCell.identifier,
                for: indexPath
            ) as? StatisticCell
        else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = UIColor.mainColorYP(.whiteYP)
        
        let description: String
        let fact: String
        
        switch indexPath.section {
        case 0:
            description = "Лучший период"
            let bestStreak = viewModel.calculateLongestPerfectDayStreak()
            fact = "\(bestStreak)"
        case 1:
            description = "Идеальные дни"
            let perfectDays = viewModel.numberOfPerfectDays()
            fact = "\(perfectDays)"
        case 2:
            description = "Трекеров завершено"
            let completedTrackers = viewModel.totalCompletedTrackers()
            fact = "\(completedTrackers)"
        case 3:
            description = "Среднее значение"
            let averageCompletedTrackers = viewModel.averageCompletedTrackers()
            fact = String(format: "%.1f", averageCompletedTrackers)
        default:
            description = "Неизвестно"
            fact = "0"
        }
        
        cell.factView.update(fact: fact, description: description)
        
        return cell
    }
}

