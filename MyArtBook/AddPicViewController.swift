//
//  AddPicViewController.swift
//  MyArtBook
//
//  Created by Tugra Zeyrek on 18.12.2022.
//

import UIKit
import CoreData

class AddPicViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    let uID:UUID?;
    var choosenData:String? = nil;
    private var image:UIImage?=nil;
    private var imageView=UIImageView();
    private var name:String="";
    private var year:Int?=nil;
    private var artistInput: UITextField = UITextField();
    private var yearInput: UITextField = UITextField();
    private let stackView = UIStackView()
    private let box = UIView()
    let button = UIButton();
    let saveButton = UIButton();
    //private var imageData = BinaryInteger();
    init(uID: UUID?) {
        self.uID = uID
        self.choosenData = uID?.uuidString;
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = choosenData != nil ? "Düzenle" : "Ekle";
        view.backgroundColor = .white;
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeKey)))
        configInputs();
        configBox();
        if(choosenData != nil){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate ;
            let context = appDelegate.persistentContainer.viewContext;
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings");
            fetchRequest.predicate = NSPredicate(format: "id = %@", choosenData!)
            fetchRequest.returnsObjectsAsFaults = false ;
            do {
                let results = try context.fetch(fetchRequest);
                if(results.count > 0){
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "artist") as? String{
                            artistInput.text = name ;
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearInput.text = String(year) ;
                        }
                        if let image = result.value(forKey: "image") as? Data{
                            self.image = UIImage(data: image)
                            self.imageView.image = self.image;
                        }
                    }
                }
                try context.save();
            }catch{
                print("HATA OLUSTU")
            }
        }
        // Do any additional setup after loading the view.
    }
    @objc func closeKey(){
        self.view.endEditing(true);
    }
    
    @objc func selectButton(){
        let picker = UIImagePickerController()
        picker.delegate = self;
        picker.sourceType = .photoLibrary;
        picker.allowsEditing = true;
        present(picker, animated: true,completion: nil);
    }
    @objc func saveButtonTab(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.persistentContainer.viewContext;
        if(choosenData != nil){
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings");
            fetchRequest.predicate = NSPredicate(format: "id = %@", choosenData!)
            fetchRequest.returnsObjectsAsFaults = false ;
            
            do {
                let results = try context.fetch(fetchRequest);
                if(results.count > 0){
                    for result in results as! [NSManagedObject] {
                        result.setValue(artistInput.text!, forKey: "artist");
                        result.setValue(Int(yearInput.text!), forKey: "year");
                        result.setValue(image?.jpegData(compressionQuality: 0.5), forKey: "image")
                    }
                }
                try context.save();
                print("Güncelleme Başarılı");
            }catch{
                print("HATA OLUSTU GUNCELLEMEDE")
            }
            
        }else {
            
            let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context);
            newPainting.setValue(artistInput.text!, forKey: "artist");
            newPainting.setValue(Int(yearInput.text!), forKey: "year");
            newPainting.setValue(UUID(), forKey: "id");
            newPainting.setValue(image?.jpegData(compressionQuality: 0.5), forKey: "image")
            
            
            do{
                try context.save();
                print("Kaydetme Başarılı");
            
            }catch{
                print("Kaydetme Başarısız");
            }
            
        }
       
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
    }
    
    @objc func saveButtonState(_ textField: UITextField){
        if(textField.text != "")
        {
            saveButton.isHidden = false;
        }else{
            saveButton.isHidden = true;
        }
    }

    func configInputs(){
        let width=view.frame.size.width;
        let height=view.frame.size.height;
        artistInput.placeholder = "İsim giriniz...";
        yearInput.placeholder = "Yıl giriniz...";
        artistInput.borderStyle = .roundedRect;
        yearInput.borderStyle = .roundedRect;
        yearInput.keyboardType = .numberPad;
        artistInput.addTarget(self, action: #selector(saveButtonState(_:)), for: .editingChanged)
        saveButton.addTarget(self, action: #selector(saveButtonTab), for: UIControl.Event.touchUpInside )
        saveButton.setTitle(choosenData == nil ? "Kaydet":"Güncelle", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(selectButton), for: UIControl.Event.touchUpInside )
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: UIControl.State.normal)
        button.layer.borderWidth = 8
        button.layer.borderColor = CGColor(gray: 1, alpha: 1)
        button.backgroundColor = .black;
        button.layer.cornerRadius = CGFloat(10);
        button.frame = CGRect(x:width * 0.5 - 50, y: 50, width: 100, height: 100);
        artistInput.frame = CGRect(x: 25, y: 170, width: width-50, height: 40);
        yearInput.frame = CGRect(x: 25, y: 230, width: width-50, height: 40);
        saveButton.frame = CGRect(x:width * 0.5 - 50, y: 260, width: 100, height: 100);
        imageView.frame = CGRect(x:0, y: height * 0.3 + 50 , width: width, height: width);
        imageView.contentMode = .scaleAspectFit;
        imageView.image = image;
        saveButton.setTitleColor(.blue, for: .normal);
        saveButton.isHidden = choosenData == nil ? true : false;
        
        box.addSubview(button);
        box.addSubview(saveButton);
        box.addSubview(artistInput);
        box.addSubview(yearInput);
        box.addSubview(imageView);
        
        
        //view.addSubview(yearInput);
        view.addSubview(box);
        //view.addSubview(artistInput);
        //view.addSubview(imageView);
    }
    func configBox() {
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = .white;
        var constraints = [NSLayoutConstraint]();
        constraints.append(box.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor))
        constraints.append(box.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor))
        constraints.append(box.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(box.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        NSLayoutConstraint.activate(constraints);
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Resim seçildi mi");
        image = info[.originalImage] as? UIImage;
        imageView.image = image;
        if(imageView.image != nil){
            button.setImage(UIImage(systemName:"pencil"), for: .normal)
        }
        self.dismiss(animated: true,completion:{()->Void in print("image picker completion")
            print("image picker completion2")
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
/*
 let stackView = UIStackView()
     let button1 = UIButton()
     let button2 = UIButton()
     let button3 = UIButton()

     override func viewDidLoad() {
         super.viewDidLoad()

         // Stack view'ı oluşturun ve eksenini ayarlayın
         stackView.axis = .horizontal
         stackView.alignment = .center
         stackView.distribution = .fillEqually

         // Butonları stack view'ına ekleyin
         stackView.addArrangedSubview(button1)
         stackView.addArrangedSubview(button2)
         stackView.addArrangedSubview(button3)

         // Stack view'ı ekrana ekleyin
         view.addSubview(stackView)

         // Stack view'ın konumunu ve boyutunu ayarlayın
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
         stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
         stackView.widthAnchor.constraint(equalToConstant: 300).isActive = true
         stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
     }
 }
 Bu örnek kod bloğunda, üç tane "UIButton" nesnesi oluşturulur ve bunlar bir "UIStackView" nesnesine eklenir. Daha sonra, stack view'ı ekrana eklenir ve konumu ve boyutu ayarlanır. Bu sayede, butonlar ekranın ortasında yatay olarak sıralanmış olur.

 Bu örnek kod bloğu, "UIStackView" nesnesinin nasıl oluşturulacağını ve kullanılacağını gösterir. Swift ve UIKit kullanarak stack view kullanarak, bir dizi nesnenin alt alta veya yanyana sıralanmasını sağlayabilirsiniz.





 */
