//
//  GalleryViewController.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 18.12.2020.
//

import UIKit
import Hero
import SDWebImage

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var heroView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var pencilView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewBottomView: UIView!
    @IBOutlet weak var buttonsViewTochkaView: UIView!
    @IBOutlet weak var buttonsViewPriceView: UIView!
    @IBOutlet weak var buttonsViewPPView: UIView!
    
    @IBOutlet weak var buttonsViewBottomViewLabel: UILabel!
    @IBOutlet weak var buttonsViewPointLabel: UILabel!
    @IBOutlet weak var buttonsViewPriceLabel: UILabel!
    @IBOutlet weak var buttonsViewPPLabel: UILabel!
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var buyButtonLabel: UILabel!
    @IBOutlet weak var pencilButton : UIButton!
    
    var images : [PostImage]  = []
    
    var sizes : [String] = []
    
    var key = ""
    
    var price : String?
    
    var point : String?
    
    var selectedImageIndex = 0
    
    private var viewHasShownSelectedImage = false
    
    private var selectedSize : String?
    
    var simplePreviewMode : Bool = false
    
    var isShownFromPhotoSearch = false
    
    var shouldShowButtonsView = UserDefaults.standard.bool(forKey: K.shouldShowButtonsViewInGallery)
    
    var forceClosed : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.isPagingEnabled = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        view.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        heroView.heroID = images[selectedImageIndex].image
        
        buttonView.layer.cornerRadius = 8
        searchView.layer.cornerRadius = 8
        pencilView.layer.cornerRadius = 8
        
        buttonsViewTochkaView.layer.cornerRadius = 8
        buttonsViewPriceView.layer.cornerRadius = 8
        buttonsViewPPView.layer.cornerRadius = 8
        
        buttonsViewBottomView.layer.cornerRadius = 8
        
        buyButtonLabel.text = "Купить"
        
        var menuSizeItems = [UIAction]()
        
        for size in sizes{
            
            let newMenuSizeItem = UIAction(title: size) { [self] (_) in
                
                selectedSize = size
                
                buyButtonPressed(self)
                
            }
            
            menuSizeItems.append(newMenuSizeItem)
            
        }
        
        let menu = UIMenu(title: "Размеры", children: menuSizeItems)
        
        buyButton.menu = menu
        
        //If there are sizes , menu shows up after tapping a button and if not , it just taps without menu
        buyButton.showsMenuAsPrimaryAction = sizes.isEmpty ? false : true

        if simplePreviewMode{
            
            buttonView.isHidden = true
            
        }
        
        if isShownFromPhotoSearch{
            searchView.isHidden = true
        }
        
        if let title = UserDefaults.standard.string(forKey: K.postTitle) , !title.isEmpty{
            buttonsViewBottomViewLabel.text = title
        }else{
            buttonsViewBottomViewLabel.text = "Укажите текст"
        }
        buttonsViewPointLabel.text = point ?? ""
        if let price = price {
            buttonsViewPriceLabel.text = price != "0" ? price + " руб" : ""
        }else{
            buttonsViewPriceLabel.text = "нет цены"
        }
        
        sizes.append("Другой размер")
        
        if !UserDefaults.standard.bool(forKey: K.notFirstTimeGalleryOpened){
            shouldShowButtonsView = true
            buttonsView.isHidden = !shouldShowButtonsView
            UserDefaults.standard.set(shouldShowButtonsView, forKey: K.shouldShowButtonsViewInGallery)
            UserDefaults.standard.set(true, forKey: K.notFirstTimeGalleryOpened)
        }else{
            buttonsView.isHidden = !shouldShowButtonsView
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewHasShownSelectedImage{
            
            self.collectionView.scrollToItem(at: IndexPath(row: selectedImageIndex, section: 0), at: .centeredHorizontally, animated: false)
            
            navigationItem.title = "Фото \(currentIndexPathOf(collectionView).row + 1) из \(images.count)"
            
            viewHasShownSelectedImage = true
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        if !simplePreviewMode{
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(downloadButtonPressed(_:)))
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(closeButtonPressed(_:)))
        
        enableHero()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disableHero()
        
    }
    
    //MARK: - Actions
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTap(_ sender: UIPanGestureRecognizer? = nil) {
        
        guard !simplePreviewMode else {return}
        
        UIView.transition(with: buttonView, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.buttonView.isHidden.toggle()
        })
        
        if !isShownFromPhotoSearch{
            UIView.transition(with: searchView, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.searchView.isHidden.toggle()
            })
        }
        
        UIView.transition(with: pencilView, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.pencilView.isHidden.toggle()
        })
        
        navigationController?.setNavigationBarHidden(navigationController?.isNavigationBarHidden == false, animated: true)
        
    }
    
    @IBAction func downloadButtonPressed(_ sender: Any) {
        
        let currentImageLink = images[(currentIndexPathOf(collectionView).row)].image
        
        guard let imageData = try? Data(contentsOf: URL(string: currentImageLink)!) else {return}
        
        // image to share
        let image = UIImage(data: imageData)
        
        // set up activity view controller
        let imageToShare = [ image! ]
        
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func buyButtonPressed(_ sender : Any){
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DobavlenieVZakupkuVC") as! DobavlenieVZakupkuViewController
        
        vc.thisImageId = images[(currentIndexPathOf(collectionView).row)].imageId
        
        vc.thisSize = selectedSize
        
        vc.sizes = sizes
        
        vc.dobavlenoVZakupku = { [self] in
            
            dismiss(animated: true, completion: nil)
            
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        
        navVC.modalPresentationStyle = .fullScreen
        
        present(navVC, animated: true, completion: nil)
        
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        
        let currentImageId = images[(currentIndexPathOf(collectionView).row)].imageId
        
        UtilsGetHashByImgIDDataManager().getUtilsGetHashByImgIDData(key: key, imgId: currentImageId) { data, error in
            
            DispatchQueue.main.async { [weak self] in
                
                if let error = error {
                    print("Error with UtilsGetHashByImgIDDataManager : \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if data!["result"].intValue == 1{
                        
                        let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
                        
                        searchVC.searchText = ""
                        
                        searchVC.imageHashText = (data!["no_crop"].stringValue + "-" + data!["crop"].stringValue)
                        
                        searchVC.isShownFromGallery = true
                        
                        searchVC.searchBarViewTapped = { [weak self] in
                            
                            searchVC.dismiss(animated: true, completion: nil)
                            self?.dismiss(animated: true, completion: nil)
                            self?.forceClosed?()
                            
                        }
                        
                        let navVC = UINavigationController(rootViewController: searchVC)
                        
                        navVC.modalPresentationStyle = .formSheet
                        
                        self!.present(navVC, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func pencilButtonPressed(_ sender: UIButton) {
        
        shouldShowButtonsView.toggle()
        
        UIView.transition(with: buttonsView, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self!.buttonsView.isHidden = !self!.shouldShowButtonsView
        })
        
        UserDefaults.standard.set(shouldShowButtonsView, forKey: K.shouldShowButtonsViewInGallery)
        
    }
    
    @IBAction func buttonsViewBottomViewButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Редактировать заголовок", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { [weak self] _ in
            
            guard let newTitle = alertController.textFields?[0].text , !newTitle.isEmpty else {return}
            
            self?.buttonsViewBottomViewLabel.text = newTitle
            
            UserDefaults.standard.set(newTitle, forKey: K.postTitle)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alertController.addTextField { field in
            
        }
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func buttonsViewPPViewButtonPressed(_ sender: UIButton) {
        
        let alertControlelr = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for size in sizes {
            
            let action = UIAlertAction(title: size, style: .default) { [self] _ in
                
                if size == "Другой размер"{
                    
                    let sizeAlertController = UIAlertController(title: "Введите размер", message: nil, preferredStyle: .alert)
                    
                    sizeAlertController.addTextField { textField in
                        textField.placeholder = "Размер"
                    }
                    
                    sizeAlertController.addAction(UIAlertAction(title: "Готово", style: .default, handler: { _ in
                        guard let newSize = sizeAlertController.textFields?[0].text else {return}
                        sizes.insert(newSize, at: sizes.count - 1)
                        buttonsViewPPLabel.text = "Размер: " + newSize
                    }))
                    
                    sizeAlertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
                        sizeAlertController.dismiss(animated: true, completion: nil)
                    }))
                    
                    present(sizeAlertController, animated: true, completion: nil)
                    
                }else{
                    buttonsViewPPLabel.text = "Размер: " + size
                }
            }
            
            alertControlelr.addAction(action)
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _IOFBF in
            alertControlelr.dismiss(animated: true, completion: nil)
        }
        
        alertControlelr.addAction(cancelAction)
        
        present(alertControlelr, animated: true, completion: nil)
        
    }
    
    @IBAction func buttonsViewPointViewButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Редактировать точку", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { [weak self] _ in
            
            guard let newPoint = alertController.textFields?[0].text , !newPoint.isEmpty else {return}
            
            self?.buttonsViewPointLabel.text = newPoint
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alertController.addTextField { field in
            
        }
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func buttonsViewPriceViewButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Редактировать цену", message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Изменить", style: .default, handler: { [weak self] _ in
            
            guard let newPrice = alertController.textFields?[0].text , !newPrice.isEmpty else {return}
            
            self?.buttonsViewPriceLabel.text = newPrice != "0" ? newPrice + " руб" : ""
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        alertController.addTextField { field in
            field.keyboardType = .numberPad
        }
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func closeButtonPressed(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UICollectionView stuff

extension GalleryViewController : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "galleryCell", for: indexPath)
        
        if let scrollView = cell.viewWithTag(1) as? UIScrollView ,
           let imageView = cell.viewWithTag(2) as? UIImageView{
            
            imageView.image = nil
            
            scrollView.maximumZoomScale = 4
            scrollView.minimumZoomScale = 1
            
            scrollView.delegate = self
            scrollView.zoomScale = 1
            
            imageView.contentMode = .scaleAspectFit
            
            imageView.clipsToBounds = true
            
            let originalUrlString = images[indexPath.row].image
            
            let indexOfLastSlash = originalUrlString.lastIndex(of: "/")
            let indexOfDot = originalUrlString.lastIndex(of: ".")
            let firstPartOfURL = String(originalUrlString[originalUrlString.startIndex ..< indexOfLastSlash!])
            let secondPartOfURL = "/550\(String(originalUrlString[indexOfDot! ..< originalUrlString.endIndex]))"
            let fullURL = "\(firstPartOfURL)\(secondPartOfURL)"
            
            imageView.sd_setImage(with: URL(string: fullURL), completed: nil)
            
        }
        
        return cell
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func currentIndexPathOf(_ collectionVeiw : UICollectionView) -> IndexPath{
        
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        let indexPath = collectionView.indexPathForItem(at: visiblePoint)!
        
        return indexPath
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        navigationItem.title = "Фото \(currentIndexPathOf(collectionView).row + 1) из \(images.count)"
        
        heroView.heroID = images[currentIndexPathOf(collectionView).row].image
        
    }
    
    
}
