//
//  ImageCache.swift
//  ETtoday_CodingExercise
//
//  Created by Arnold on 7/22/24.
//

import UIKit
import Foundation

protocol ImageCacheType {
    func getImage(imageURL: URL, completionHandler: ((UIImage) -> Void)?)
    func downloadImage(imageURL: URL, completionHandler: ((UIImage) -> Void)?)
    func loadImageFromCache(imageURL: URL, completionHandler: ((UIImage) -> Void)?)
    func cancelLoadImage()
}

public class ImageCache: ImageCacheType {
    private let cache = URLCache.shared
    private var dataTask: URLSessionDataTask? = nil
           
    public func getImage(imageURL: URL, completionHandler: ((UIImage) -> Void)?) {
        let request = URLRequest(url: imageURL)
        
        if cache.cachedResponse(for: request) != nil {
            loadImageFromCache(imageURL: imageURL) { image in
                completionHandler?(image)
            }
        } else {
            downloadImage(imageURL: imageURL) { image in
                completionHandler?(image)
            }
        }
    }
    
    internal func downloadImage(imageURL: URL, completionHandler: ((UIImage) -> Void)?) {
        let request = URLRequest(url: imageURL)

        DispatchQueue.global(qos: .utility).async {
            self.dataTask = URLSession.shared.dataTask(with: imageURL) {data, response, _ in
                if let data = data {
                    let cachedData = CachedURLResponse(response: response!, data: data)
                    self.cache.storeCachedResponse(cachedData, for: request)
                    completionHandler?(UIImage(data: data) ?? UIImage())
                }
            }
            self.dataTask?.resume()
        }
    }
    
    internal func loadImageFromCache(imageURL: URL, completionHandler: ((UIImage) -> Void)?) {
        let request = URLRequest(url: imageURL)
        DispatchQueue.global(qos: .utility).async {
            if let data = self.cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completionHandler?(image)
                }
            }
        }
    }
    
    internal func cancelLoadImage() {
        dataTask?.cancel()
    }
}

extension UIImageView {
    func loadImage(in imageCache: ImageCache, imageURL: URL) {
        imageCache.getImage(imageURL: imageURL, completionHandler: { image in
            DispatchQueue.main.async {
                self.image = image
            }
        })
    }
    
    func cancelLoadImage(in imageCache: ImageCache) {
        imageCache.cancelLoadImage()
    }
}
