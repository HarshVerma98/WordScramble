//
//  ViewController.swift
//  Project5
//
//  Created by Harsh Verma on 04/08/21.
//

import UIKit

class ViewController: UIViewController {

    var table: UITableView!
    var words = [String]()
    var usedWords = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(reboot))
        createTables()
        loadFiles()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(table)
        table.frame = view.bounds
    }

    func createTables() {
        table = UITableView()
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ids")
        table.rowHeight = 80
    }
    
    func loadFiles() {
        if let startUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startwords = try? String(contentsOf: startUrl) {
                words = startwords.components(separatedBy: "\n")
            }
        }
        if words.isEmpty {
            words = ["silkworm"]
        }
        startGame()
    }
    
    func startGame() {
        title = words.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        table.reloadData()
    }
    
    func submit(_ answer: String) {
        let lowerCase = answer.lowercased()
//        let errortitle: String
//        let errormessage: String
//        if isPOssible(word: lowerCase) {
//            if isOrginal(word: lowerCase) {
//                if isReal(word: lowerCase) {
//                    usedWords.insert(answer, at: 0)
//
//                    let index = IndexPath(row: 0, section: 0)
//                    table.insertRows(at: [index], with: .fade)
//                    return
//                }else {
//                    errortitle = "Word Not recognized"
//                    errormessage = "You can't just make them up!!"
//                }
//            }else {
//                errortitle = "Word Already Used"
//                errormessage = "Be more Original"
//            }
//        }else {
//            guard let title = title?.lowercased() else {
//                return
//            }
//            errortitle = "Not Possible"
//            errormessage = "You can't spell that word from \(title)"
//        }
//
//        let alert = UIAlertController(title: errortitle, message: errormessage, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true)
        
        if !isPOssible(word: lowerCase) {
            guard let title = title else {
                return
            }
            showErrorMessage(title: "Word Bit Recognized", message: "You can't spell that word from \(title.lowercased())")
            return
        }
        
        if !isOrginal(word: lowerCase) {
            showErrorMessage(title: "Word Not Possible", message: "Be more Original!")
            return
        }
        if !isReal(word: lowerCase) {
            showErrorMessage(title: "Word not Recognized", message: """
                A word must exist, \
                Must be a 3 letter word atleast, \
                Must be different from original word
                """
                )
            return
        }
        
        usedWords.insert(lowerCase, at: 0)
        let index = IndexPath(row: 0, section: 0)
        table.insertRows(at: [index], with: .fade)
    }
    
    func isPOssible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {
            return false
        }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            }else {
                return false
            }
        }
        return true
    }
    
    func isOrginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        guard word.count >= 3 else {
            return false
        }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelled = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelled.location == NSNotFound
    }
    
    func showErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func promptAnswer() {
        let alert = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        let ok = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] action in
            guard let answer = alert?.textFields?[0].text else {
                return
            }
            self?.submit(answer)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func reboot() {
        startGame()
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "ids", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    
}
