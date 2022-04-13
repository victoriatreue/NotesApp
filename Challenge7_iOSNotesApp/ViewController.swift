//
//  ViewController.swift
//  Challenge7_iOSNotesApp
//
//  Created by Victoria Treue on 6/9/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var notesCountLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    
    var df = DateFormatter()
    var notes = [Note]()
    var notesCount = 0 {
        didSet { notesCountLabel.text = "\(notesCount) Notes" }
    }

    
    // MARK: - Lifecycle Hooks

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Views
        notesTableView.separatorStyle = .none
        
        notesTableView.separatorColor = Colors.secondaryColor
        notesCountLabel.textColor = Colors.mainColor
        notesCountLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        editBarButtonItem.tintColor = UIColor.darkGray

        // Table View
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        // Navigation Bar
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Load Data from User Defaults
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "notes") as? Data {
            if let decodedNotes = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? [Note] {
                notes = decodedNotes
                
                df.dateFormat = "dd MMM yyyy"
                let today = df.string(from: Date())
                
                for note in notes {
                    
                    df.dateFormat = "dd MMM yyyy"
                    let noteTodayDate = df.string(from: note.date)

                    if noteTodayDate == today {
                        df.dateFormat = "hh:mm a"
                        let noteTimeStr = df.string(from: note.date)
                        note.dateStr = noteTimeStr
                        
                    } else {
                        df.dateFormat = "dd MMM yyyy"
                        let noteDateStr = df.string(from: note.date)
                        note.dateStr = noteDateStr
                    }
                    

                }
                
                notesCount = notes.count
            }
        }
        
        updateNotesCountLabel()
        sortNotesByDate()
    }
    
    
    private func updateNotesCountLabel() {
        if notes.count == 1 {
            notesCountLabel.text = "\(notes.count) Note"
        } else {
            notesCountLabel.text = "\(notes.count) Notes"
        }
    }
    
    
    private func sortNotesByDate() {
        notes = notes.sorted(by: {$0.date > $1.date})
        notesTableView.reloadData()
    }


    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return notes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath) as? TableViewCell else { fatalError() }
        
        cell.title.text = notes[indexPath.section].title
        cell.body.text = notes[indexPath.section].body
        cell.date.text = notes[indexPath.section].dateStr
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(identifier: "showNote") as? DetailViewController else { fatalError() }
        vc.note = notes[indexPath.section]
        navigationController?.pushViewController(vc, animated: true)
        
        vc.existingNoteCompletion = {
            [weak self] (done) in
            self?.navigationController?.popToRootViewController(animated: true)
            self?.notes[indexPath.section] = vc.note!
            self?.saveToUserDefaults()
            self?.notesTableView.reloadData()
            self?.sortNotesByDate()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    
    // MARK: Edit Rows
    
    @IBAction func editTapped(_ sender: Any) {
                
        if !isEditing {
            self.notesTableView.isEditing = true
            isEditing = true
            editBarButtonItem.title = "Done"
            addButton.isEnabled = false
            
        } else if isEditing {
            self.notesTableView.isEditing = false
            isEditing = false
            editBarButtonItem.title = "Edit"
            addButton.isEnabled = true
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = notes[sourceIndexPath.section]
        notes.remove(at: sourceIndexPath.section)
        notes.insert(itemToMove, at: sourceIndexPath.section)
        saveToUserDefaults()
    }
    
    
    // MARK: Delete Rows
 
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.section)
            notesCount -= 1
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveToUserDefaults()
        }
    }
    
    
    // MARK: - IBAction
    
    @IBAction func addNoteTapped(_ sender: UIButton) {
        
        guard let vc = storyboard?.instantiateViewController(identifier: "showNote") as? DetailViewController else { fatalError() }
        
        vc.completion = {
            [weak self] (noteTitle, note, dateStr, date) in
            self?.navigationController?.popToRootViewController(animated: true)
            let note = Note(title: noteTitle, body: note, dateStr: Date().convertToString(), date: Date())
            self?.notesCount += 1
            self?.notes.append(note)
            self?.saveToUserDefaults()
            self?.notesTableView.reloadData()
            self?.updateNotesCountLabel()
            self?.sortNotesByDate()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - User Defaults
    
    func saveToUserDefaults() {
        if let savedDate = try? NSKeyedArchiver.archivedData(withRootObject: notes, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.setValue(savedDate, forKey: "notes")
        }
    }
    
}
