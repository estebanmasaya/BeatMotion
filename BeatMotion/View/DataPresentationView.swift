//
//  DataPresentationView.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-08.
//


import SwiftUI

struct DataPresentationView: View {
    @EnvironmentObject var theViewModel : ViewModelBM
    var body: some View {
        
        ZStack {
            Color(red: 134/255, green: 185/255, blue: 237/255) .edgesIgnoringSafeArea(.all)
            
            VStack{
                
                HStack{
                    Text("🎧")
                    Text("BeatMotion")
                    Text("🏃🏻‍♂️")
                }.font(.title)
                    .foregroundColor(.white)
                    .shadow(color: .blue, radius: 2, x: 1, y: 1)
                    .padding()
                
                
                
                VStack{
                    
                    Text(String(theViewModel.bpm)).font(Font.system(size: 60))
                    Text("BPM = Steps/min")
                    
                    Spacer()
                    if let imageUrlString = theViewModel.currentlyPlayingTrack.item.album.images.first?.url,
                       let imageUrl = URL(string: imageUrlString) {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()  // Apply resizable on the Image, not on AsyncImagePhase
                                    .scaledToFit()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()  // Apply resizable on the Image, not on AsyncImagePhase
                                    .scaledToFit()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 300, height: 300)
                    } else {
                        Text("No image URL available")
                    }
                    
                    Text(theViewModel.currentlyPlayingTrack.item.name)
                    Text(theViewModel.currentlyPlayingTrack.item.artists.map { $0.name }.joined(separator: ", "))
                    
                    HStack{
                        
                        OperationIconView(operation: theViewModel.isPlaying ? SpotifyApi.Operation.PAUSE : SpotifyApi.Operation.PLAY)
                        OperationIconView(operation: SpotifyApi.Operation.FORWARD)
                    }
  
                    Spacer()
                }
            }
        }
    }
}

struct DataPresentationView_Previews: PreviewProvider {
    static var previews: some View {
        DataPresentationView()
            .environmentObject(ViewModelBM())
    }
}
