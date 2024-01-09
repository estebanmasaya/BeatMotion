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
                    await theViewModel.startPlayback()
                }
                
            }
            
            Button("Get Currently Playing") {
                Task{
                    await theViewModel.fetchRemainingTimeCurrentlyPlayingTrack()
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
