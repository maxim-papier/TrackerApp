import UIKit

final class StatisticVC: UIViewController {
    
    let placeholder = PlaceholderType.noStats.placeholder
    
    private let table = UITableView()
    
    
    //MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.mainColorYP(.whiteYP)
        setupNavBar()
        setupTable()
        setupPageLayout()
    }
    
    private func setupTable() {
        
        table.dataSource = self
        table.delegate = self
        
        table.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func setupPageLayout() {
        
    
        //view.addSubview(placeholder)
        view.addSubview(table)
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        let hInset: CGFloat = 16
        
        NSLayoutConstraint.activate([
            //placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            table.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: hInset),
            table.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -hInset),
            table.topAnchor.constraint(equalTo: guide.topAnchor, constant: 77),
            table.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
    }
    
    private func setupNavBar() {
        title = "Статистика"
    }
}

// MARK: -  Delegates

extension StatisticVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 4 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = table.dequeueReusableCell(
                withIdentifier: StatisticCell.identifier,
                for: indexPath
            ) as? StatisticCell
        else {
            return UITableViewCell()
        }
        
        cell.factLabel.text = "69"
        cell.descriptionLabel.text = "PENISES"
        
        return cell
    }
    
    
}

extension StatisticVC: UITableViewDelegate {
    
}
