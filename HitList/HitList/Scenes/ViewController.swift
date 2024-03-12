
import UIKit

final class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    private var coreDataManager: (any CoreDataManager)!
    
    private var names: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDB()
        fetch()
        
        navigationItem.title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    private func setupDB() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        coreDataManager = HLCoreDataManager(container: appDelegate.persistentContainer)
        
    }

    @IBAction private func handleAddPressed(_ sender: Any) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            
            let person = Person(name: nameToSave)
            self.save(person)
          }
        
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
          alert.addTextField()
          alert.addAction(saveAction)
          alert.addAction(cancelAction)
          present(alert, animated: true)
    }
    
    private func save(_ person: Person) {
        coreDataManager.save(entity: person) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.names.append(person.name)
                    self?.tableView.reloadData()
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetch() {
        coreDataManager.fetch(entityName: String(describing: Person.self)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self?.names = success.compactMap {
                        $0 as? PersonEntity
                    }.compactMap { $0.name }
                    self?.tableView.reloadData()
                case .failure(let failure):
                    debugPrint(failure.localizedDescription)
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = names[indexPath.row]
        return cell
    }
}

struct Person: Decodable {
    let name: String
}
