//
//  CustomImageView.swift
//  Stocks
//
//  Created by tomtung on 2022/8/20.
//

import UIKit

class CustomImageView: UIImageView {
    
    // MARK: - Properties
    
    private let loadingView = UIActivityIndicatorView()

    static var cache = NSCache<AnyObject, UIImage>()
    //判斷圖片 url 是否相同
    var url: URL?
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setUpLoadingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func loadingImage(_ urlString: String){
        guard let url = URL(string: urlString) else { print("Invalid url"); return }
        self.url = url
        
        //如果 cache，不網路請求
        if let cachedImage = CustomImageView.cache.object(forKey: self.url as AnyObject) {
            self.image = cachedImage
            print("You get image from cache")
            
        } else {
            //如果沒有 cache，網路請求
            self.loadingView.startAnimating()
            
            DispatchQueue.global(qos: .userInteractive).async {
                URLSession.shared.dataTask(with: url){ [weak self] (data,response,error) in
                    self?.parse(data: data, response: response, error: error)
                }.resume()
            }
        }
    }
    
    // MARK: - Private
    
    private func setUpView() {
        backgroundColor = .tertiarySystemBackground
        clipsToBounds = true
        contentMode = .scaleAspectFill
        layer.cornerRadius = 6
    }
    
    private func parse(data: Data?, response: URLResponse?, error: Error?) {
        guard let data = data, error == nil else {
            print("Error: \(String(describing: error?.localizedDescription))")
            return
        }
        
        let group = DispatchGroup()
        
        DispatchQueue.main.async(group: group) {
            //判斷式 - 是否為此 image 的 url
            if response?.url == self.url {
                guard let cachedImage = UIImage(data: data) else {
                    print("Invalid image")
                    return
                }
                self.image = cachedImage
                CustomImageView.cache.setObject(cachedImage, forKey: response?.url as AnyObject)
                print("You get image from \(String(describing: self.url))")
            }
        }
        
        group.notify(queue: .main) {
            self.loadingView.stopAnimating()
        }
    }
}

extension CustomImageView {
    
    private func setUpLoadingView() {
        loadingView.color = .black
        loadingView.hidesWhenStopped = true
        addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
}
