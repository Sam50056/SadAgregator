//
//  HelpView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 09.01.2021.
//

import SwiftUI
import SwiftyJSON
import SafariServices

//MARK: - ViewController Representable

struct HelpView : UIViewControllerRepresentable{
    
    @EnvironmentObject var menuViewModel : MenuViewModel
    
    func makeUIViewController(context: Context) -> HelpViewController {
        
        let helpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpVC") as! HelpViewController
        
        helpVC.key = menuViewModel.getUserDataObject()?.key
        
        return helpVC
        
    }
    
    func updateUIViewController(_ uiViewController: HelpViewController, context: Context) {
        
    }
    
}

//MARK: - ViewController

class HelpViewController : UITableViewController, HelpPageDataManagerDelegate {
    
    var key : String?
    
    lazy var helpPageDataManager = HelpPageDataManager()
    
    lazy var helpArray = [HelpViewItem]()
    
    lazy var displayedRows = [HelpViewItem]()
    
    override func viewDidLoad() {
        
        helpPageDataManager.delegate = self
        
        tableView.separatorStyle = .none
        
        guard let key = key else {return}
        
        helpPageDataManager.getHelpPageData(key: key)
        
    }
    
    //MARK: - HelpPageDataManagerDelegate
    
    func didGetHelpPageData(data: JSON) {
        
        DispatchQueue.main.async { [self] in
            
            let helpArrayJson = data["help"].arrayValue
            
            var newHelpArray = [HelpViewItem]()
            
            helpArrayJson.forEach { (item) in
                
                newHelpArray.append(HelpViewItem(isTextViewCell: false, id: item["id"].stringValue, capt: item["capt"].stringValue, text: item["text"].stringValue, url: item["url"].stringValue))
                
            }
            
            helpArray = newHelpArray
            
            displayedRows = helpArray
            
            tableView.reloadData()
            
        }
        
    }
    
    func didFailGettingHelpPageData(error: String) {
        print("Eror with HelpPageDataManager : \(error)")
    }
    
    //MARK: - TableView Stuff
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if displayedRows[indexPath.row].isTextViewCell{
            cell = tableView.dequeueReusableCell(withIdentifier: "helpTextViewCell", for: indexPath)
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "helpCell", for: indexPath)
        }
        
        setUpHelpCell(cell: cell, data: displayedRows[indexPath.row])
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Chaning cell bg color to gray or back to white
        if !displayedRows[indexPath.row].isTextViewCell , displayedRows[indexPath.row].text != ""{
            
            displayedRows[indexPath.row].shouldBackgroundBeWhite.toggle()
                
            displayedRows[indexPath.row].shouldTextViewCellBeShown.toggle()
            
            tableView.reloadRows(at: [indexPath], with: .none)
            
        }
        
        if !displayedRows[indexPath.row].isTextViewCell , displayedRows[indexPath.row].text != ""{
            
            tableView.beginUpdates()
            
            if displayedRows[indexPath.row].shouldTextViewCellBeShown{
                
                displayedRows.insert(HelpViewItem(isTextViewCell: true, shouldBackgroundBeWhite : false, id: "", capt: "", text: displayedRows[indexPath.row].text, url: ""), at: (indexPath.row + 1))
                
                tableView.insertRows(at: [IndexPath(row: (indexPath.row + 1), section: 0)], with: .top)
                
            }else{
                
                displayedRows.remove(at: indexPath.row + 1)
                tableView.deleteRows(at: [IndexPath(row: (indexPath.row + 1), section: 0)], with: .top)
                
            }
            
            tableView.endUpdates()
            
        }else if !displayedRows[indexPath.row].isTextViewCell , displayedRows[indexPath.row].url != "" {
            
            if let url = URL(string: displayedRows[indexPath.row].url){
                
                self.present(SFSafariViewController(url: url), animated: true, completion: nil)
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Cells Setup
    
    func setUpHelpCell(cell : UITableViewCell, data : HelpViewItem){
        
        if data.isTextViewCell{
            //If cell is text cell , I just show text )
            if let textView = cell.viewWithTag(1) as? UITextView{
                
                textView.text = data.text
                
                //Chaning BG color
                if !data.shouldBackgroundBeWhite {
                    cell.backgroundColor = .systemGray5
                }
                
            }
            
        }else{
            
            if let captLabel = cell.viewWithTag(1) as? UILabel,
               let imageView = cell.viewWithTag(2) as? UIImageView{
                
                captLabel.text = data.capt
                
                //If there is some url , it means cell is not dropdown so imageView is not needed
                if data.url != ""{
                    
                    imageView.image = nil
                    
                }else if data.text != ""{
                    
                    imageView.image = data.shouldTextViewCellBeShown ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
                    
                }
                
                if data.shouldBackgroundBeWhite{
                    
                    cell.backgroundColor = UIColor(named: "whiteblack")
                    
                }else{
                    
                    cell.backgroundColor = .systemGray5
                    
                }
                
            }
            
        }
        
    }
    
    //MARK: - HomeViewItem
    
    struct HelpViewItem{
        
        let isTextViewCell : Bool
        var shouldTextViewCellBeShown = false
        
        var shouldBackgroundBeWhite = true
        
        let id : String
        let capt : String
        let text : String
        let url : String
        
    }
    
}
