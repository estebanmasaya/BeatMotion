//
//  PlayView.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-09.
//

import SwiftUI

struct OperationIconView: View {
    @EnvironmentObject var theViewModel : ViewModelBM
    let operation : SpotifyApi.Operation
    
    var body: some View {
        Button{
            
            
                switch operation{
                case SpotifyApi.Operation.PLAY: Task{
                    await theViewModel.startPlayback()
                }
                    case SpotifyApi.Operation.PAUSE:
                    Task{
                        await theViewModel.startPlayback()
                    }
                    case SpotifyApi.Operation.FORWARD:
                    Task{
                        await theViewModel.forwardPlayback()
                    }
                }

        }label:{
            ZStack{
                switch operation{
                    case SpotifyApi.Operation.PLAY: Image(systemName:"play.fill")
                    case SpotifyApi.Operation.PAUSE: Image(systemName:"pause.fill")
                    case SpotifyApi.Operation.FORWARD: Image(systemName:"forward.fill")
                }
            }
        }
        .foregroundColor(Color.white)
        .padding(15)
        .imageScale(.large)
        .background(Color(red: 66/255, green: 139/255, blue: 221/255))
        .cornerRadius(200)
        
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        OperationIconView(operation: SpotifyApi.Operation.FORWARD)
            .environmentObject(ViewModelBM())
    }
}
