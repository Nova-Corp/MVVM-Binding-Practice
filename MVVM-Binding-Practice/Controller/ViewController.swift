//
//  ViewController.swift
//  MVVM-Binding-Practice
//
//  Created by ADMIN on 27/06/21.
//  Copyright © 2021 Success Resource Pte Ltd. All rights reserved.
//

import UIKit

// Observable
class Observable<T> {
    typealias ListenerType = (T?) -> Void
    var value: T?{
        didSet{
            listener?(value)
        }
    }
    init(_ value: T?) {
        self.value = value
    }
    private var listener: ListenerType?
    
    func bind(_ listener: @escaping ListenerType) {
        listener(value)
        self.listener = listener
    }
}


// Model
struct User: Codable {
    let name: String
}

// ViewModel
struct UserListViewModel {
    var users: Observable<[UserTableViewCellViewModel]> = Observable([])
    
}

struct UserTableViewCellViewModel {
    let name: String
}

// Controller
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = UserListViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }
    
    func fetchUser() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        let task = URLSession.shared.dataTask(with: url){[weak self] (data,_,_) in
            guard let data = data else { return }
            
            do{
                let userModels = try JSONDecoder().decode([User].self, from: data)
                
                self?.viewModel.users.value = userModels.compactMap({
                    UserTableViewCellViewModel(name: $0.name)
                })
                
                DispatchQueue.main.async { self?.tableView.reloadData() }
                
            }catch let error{
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
