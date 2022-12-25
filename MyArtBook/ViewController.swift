//
//  ViewController.swift
//  MyArtBook
//
//  Created by Tugra Zeyrek on 14.12.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    var dataList:[String]=[];
    var imageList:[UIImage?]=[];
    var uIdList:[UUID?]=[];
    let table:UITableView = UITableView();
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        var content = cell.defaultContentConfiguration();
        content.text = dataList[indexPath.row];
        cell.contentConfiguration = content;
        return cell;
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = DetailBookViewController(name: dataList[indexPath.row], image:imageList[indexPath.row] )
        navigationController?.pushViewController(viewController, animated: true);
        //self.present(viewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appdeleage = UIApplication.shared.delegate as! AppDelegate ;
            let context = appdeleage.persistentContainer.viewContext;
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings");
            let id = uIdList[indexPath.row]!.uuidString;
            fetchRequest.predicate = NSPredicate(format: "id == %@", id);
            fetchRequest.returnsObjectsAsFaults = false;
            do {
                let results = try context.fetch(fetchRequest);
                if results.count > 0 {
                    print(results);
                    for result in results as! [NSManagedObject]{
                        if let uid = result.value(forKey: "id") as? UUID{
                            if uid == uIdList[indexPath.row]{
                                context.delete(result)
                                uIdList.remove(at: indexPath.row);
                                dataList.remove(at: indexPath.row);
                                self.table.reloadData();
                                try context.save();
                                break ;
                            }
                        }
                    }
                }
            }catch{
                
                print("Silme işleminde hata çıktı");
                
            }
        }
    }
    
    override func viewDidLoad() {
        //self.navigationController?.isToolbarHidden = false
        view.backgroundColor = .systemTeal;
        //UINavigationBar.appearance().backgroundColor = UIColor.gray;
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        navigationItem.title = "Art Book";
        table.delegate = self;
        table.dataSource = self;
        table.addGestureRecognizer(longPress);
        //table.isEditing = true;
        let width:Double = view.frame.size.width;
        let height:Double = view.frame.size.height;
        table.frame = CGRect(x: 0, y: 0, width: width, height: height);
        view.addSubview(table);
        getCoreData();
        NotificationCenter.default.addObserver(self, selector: #selector(getCoreData), name: NSNotification.Name("newData"), object: nil)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        print("----viewWillAppear----")
        
    }
    @objc func addTapped(){
        let viewController = AddPicViewController(uID: nil);
        navigationController?.pushViewController(viewController, animated: true);
    }
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        print("ROW HANDLE LONG PRESS")
        if sender.state == .began {
            let touchPoint = sender.location(in: table)
            if let indexPath = table.indexPathForRow(at: touchPoint) {
                let viewController = AddPicViewController(uID: uIdList[indexPath.row]);
                navigationController?.pushViewController(viewController, animated: true);
            }
        }
    }
    @objc func getCoreData(){
        print("--getCoreData Tetiklendi--")
        dataList.removeAll(keepingCapacity: false);
        imageList.removeAll(keepingCapacity: false);
        uIdList.removeAll(keepingCapacity: false);
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext;
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings");
        fetchRequest.returnsObjectsAsFaults = false;
        do {
            let results = try context.fetch(fetchRequest);
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey: "artist") as? String{
                    self.dataList.append(name);
                }
                if let uid = result.value(forKey: "id") as? UUID{
                    self.uIdList.append(uid);
                }
                if let imageData = result.value(forKey:"image") as? Data {
                    let image = UIImage(data: imageData)
                    self.imageList.append(image);
                }
                self.table.reloadData();
            }
        }catch{}
        

    }
}

