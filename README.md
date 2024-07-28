# ETtoday_CodingExercies

## Introduction

This project is for ETtoday's coding exercise. Calling only one endpoint. There's also comments in the code.

https://itunes.apple.com/search

Structure: MVVM

### To start 

Type in the term to search for related tracks in iTunes.

### Play audio(musics, audiobooks, podcast), Play video(movies, tv-episodes, short film)

Tap on any cell that's visible on the screen.

### Pause

For audio just tap the cell that is selected to play at first again.

For video tap the pause button on screen or dismiss the player, it will set as paused in background.

**If different cell is selected, current playing will be cut off and start playing the track according to the cell that's been selected.**

### Restart

When audio or video reach the end and stop playing, the status of the track will be set to restart, tap it again to start from the begining.

## Data fetching (25 tracks per request)

Data fetching is done by calling the iTunes endpoint. At most 25 tracks will be returned per request(batch). 

The initial request is triggered by the searchBar. 
Futher requests are triggered by user scrolling. 
When user scrolls to nearly the end of the view, the system will automatically trigger a request then load in the next 25 tracks and so on. 
This process will continue until there's no more tracks to request from the endpoint.

The intial tracks load in will be using reload.
However to avoid the collectionView flickering to enhance user experience, latter tracks load in process is done by using insertion rather than reload.

## Connection monitor

### Import Network Framework

    import Network

### Initialize NWPathMonitor

    private let pathMonitor = NWPathMonitor()

### Read path from pathMonitor

    pathMonitor.pathUpdateHandler

**.satisfied**: The network path is available, and the network connection is established

**.unsatisfied**: The network path is not available, and the network connection cannot be established

**.requiresConnection**: The network path requires additional steps to establish the connection


## CollectionView with auto resizing cells

This is done by 2 steps.

### Set estimated item size in UICollectionView

    UICollectionViewFlowLayout().estimatedItemSize = CGSize()

### Override preferredLayoutAttributesFitting in UICollectionViewCell

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }

## TrackCollectionViewCell

**Support audiobook, music, music video, movie, podcast, tv-episode, short film**

Only one collectionViewCell file is created in this project.

By activating and deactivating **trackDescriptionHeightConstraint** to support tracks with long description and tracks without description.

## ObservableObject

A generic class for setting up bindings between view models and views.

## Networking Manager

### NetworkService

Networking logics such as fetch and decode are being held by the network service class. 

### URLSafeConstruct
In order to safely construct the URL and to reduce human errors, the urlComponents is implemented in here.

    class URLSafeConstruct: NSObject {
        public func constructURL(searchTerm: String, startFrom: Int, limitTo: Int) -> URL? {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "itunes.apple.com"
            urlComponents.path = "/search"
            let termQueryItem = URLQueryItem(name: "term", value: searchTerm)
            let startFromQueryItem = URLQueryItem(name: "offset", value: "\(startFrom)")
            let limitToQueryItem = URLQueryItem(name: "limit", value: "\(limitTo)")
            urlComponents.queryItems = [termQueryItem, startFromQueryItem, limitToQueryItem]
            return urlComponents.url?.absoluteURL
        }
    }
**termQueryItem**: Text typed in the searchbar

**startFromQueryItem**: Starting point for the returned track list

**limitToQueryItem**: Limitation for the returned tracks

## ImageCache

This exercise utilize the URLCache to achieve caching data.

By checking if the image data has already been loaded to the cache, if the image existed we load the image directly from the cahce, if not we download it and cache it.

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
    
 An extension is also created for UIImageView.
 
     extension UIImageView {
        func loadImage(cache: ImageCache, imageURL: URL) {
            cache.getImage(imageURL: imageURL, completionHandler: { image in
                DispatchQueue.main.async {
                    self.image = image
                }
            })
        }

        func cancelLoadImage(in imageCache: ImageCache) {
            imageCache.cancelLoadImage()
        }
    }

**loadImage**: Call imageCache getImage function

**cancelLoadImage**: Cancel fetch from imageCache if fetch is still in progress

## AudioManager

This part utilize AVKit and AVFoundation to achieve playing audio and video.

### AVPlayer status
An enum class called PlayerStatus is used in this AudioManager to showcase the current state of the AVPlayer.

    enum PlayerStatus {
        case finished
        case paused
        case playing
        case buffering
        case initial
    }

### Set four observers
**playToEndCancellable**: Signal when track ends

**bufferingCancellable**: Signal when track stops playing because need more buffering

**onIsPlaybackLikelyToKeepUpObserver**: Determine if finished buffering and ready to play

**onRateObserver**: Determine states using rate changes

### Play and Pause Track
With the help of four observers, the function below will determine either to play or pause the AVPlayer according to the AVPlayer status.

    public func playAndPauseAudio(with url: URL)

Usecase in collectionViewCell didSelectItemAt.

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let previewURL = viewModel.trackListData.value.results[indexPath.row].previewUrl {
            audioManager.playAndPauseAudio(with: previewURL)
        }
    }

 
 ## Libraries
 
 Only one library is used in this project.
 
 https://github.com/SnapKit/SnapKitOne 
 
 SnapKit is used in this project to helped setting the constraints.
