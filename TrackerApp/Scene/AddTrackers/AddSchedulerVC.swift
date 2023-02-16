import UIKit

final class AddScheduler: UIViewController {


    let weekdays = WeekDay.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainColorYP(.whiteYP)
        configure()
    }

    private func configure() {

        let title: UILabel = {
            let label = UILabel()
            label.text = "Расписание"
            label.textColor = UIColor.mainColorYP(.blackYP)
            label.font = FontYP.medium16
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let tableView: UITableView = {
            let table = UITableView()
            table.register(SchedulerCell.self, forCellReuseIdentifier: SchedulerCell.identifier)
            table.delegate = self
            table.dataSource = self
            table.layer.masksToBounds = true
            table.translatesAutoresizingMaskIntoConstraints = false
            return table
        }()

        let doneButton = ButtonType.primary(isActive: true).button(withText: "Готово") { self.dismiss(animated: true) }

        view.addSubview(title)
        view.addSubview(tableView)
        view.addSubview(doneButton)


        let vInset: CGFloat = 38

        NSLayoutConstraint.activate([

            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            tableView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: vInset),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}



extension AddScheduler: UITableViewDelegate {

    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        <#code#>
    //    }

}


extension AddScheduler: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return weekdays.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let firstIndex = 0
        let lastIndex = weekdays.count - 1
        let cellID = SchedulerCell.identifier

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SchedulerCell else { fatalError("Unable to dequeue \(cellID)") }

        let weekday = weekdays[indexPath.row]
        cell.labelMenu.text = weekday.label

        switch (indexPath.row, weekdays.count) {

        case (firstIndex, 1): cell.buttonPosition = .single
        case (firstIndex, _): cell.buttonPosition = .first
        case (lastIndex, _): cell.buttonPosition = .last
        default: cell.buttonPosition = .middle

        }
        return cell
    }
}


// MARK: - SHOW PREVIEW

import SwiftUI
struct AddSchedulerVCProvider: PreviewProvider {
    static var previews: some View {
        AddScheduler().showPreview()
    }
}
