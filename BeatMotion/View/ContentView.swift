//
//  ContentView.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2023-12-20.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @EnvironmentObject var theViewModel : ViewModelBM


    var body: some View {
        VStack {
            Button("Open Web View") {
                theViewModel.updateLoginUrl()
                theViewModel.userAgreed.toggle()
            }
            .padding()
            .sheet(isPresented: $theViewModel.userAgreed) {
                WebView(theViewModel: theViewModel, url:  (theViewModel.loginURL?.url)!)
            }.padding()
            
            Button("Fetch recommendations") {
                Task{
                    await theViewModel.fetchRecommendations()
                }
                
            }
            Button("Play") {
                Task{
                    await theViewModel.startPlaybackInFirstAvailableDevice()
                }
                
            }
            
            Button("Get Currently Playing") {
                Task{
                    await theViewModel.fetchCurrentlyPlayingTrack()
                }
                
            }
            
            Button("Choose next song") {
                Task{
                    await theViewModel.chooseNextTrack()
                }
            }.padding()
            Text("steps per minute: \(theViewModel.bpm)")
            
        }
        .padding()
        
        if let imageUrlString = theViewModel.currentlyPlayingTrack.item.album.images.first?.url,
           let imageUrl = URL(string: imageUrlString) {
            // Code inside this block will execute if both optionals are successfully unwrapped
            // imageUrlString and imageUrl are non-nil within this block
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            // Provide a default value for imageUrlString if it's nil
            let defaultImageUrlString = "https://example.com/defaultImage.jpg"
            
            // Use the defaultImageUrlString to create a URL
            if let defaultImageUrl = URL(string: defaultImageUrlString) {
                // Handle the case where imageUrlString is nil, using the defaultImageUrl
                AsyncImage(url: defaultImageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Handle the case where both imageUrlString and defaultImageUrlString are invalid
                // Provide a fallback or handle the error as needed
            }
        }

        
    }
    
}

struct WebView: UIViewRepresentable{
    @ObservedObject var theViewModel: ViewModelBM
    

    var url: URL
    func makeUIView(context: Context) -> WKWebView{
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(theViewModel: theViewModel, parent:self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var theViewModel: ViewModelBM
        var parent: WebView

        init(theViewModel: ViewModelBM, parent: WebView) {
            self.theViewModel = theViewModel
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("DIDFINISHED!")
            guard let urlString = webView.url?.absoluteString else {return}
            if urlString.contains("https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_CMYK_Green.png#access_token="){
                print("SIII")
                theViewModel.userAgreed = false
                theViewModel.extractTokenfronUrl(urlString: urlString)


            }
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View{
        ContentView().environmentObject(ViewModelBM())
    }
}
