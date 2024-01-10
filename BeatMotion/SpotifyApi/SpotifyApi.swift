//
//  SpotifyApi.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-04.
//

import Foundation


class SpotifyApi{
    
    static func startPlayback(tokenString: String, deviceId: String, isPlaying: Bool) async throws{
        guard let urlRequest = createURLRequestPlayback(tokenString: tokenString, deviceId: deviceId, isPlaying: isPlaying) else {throw NetworkError.invalidURL}
        print("URLREQUEST: \(urlRequest)")
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
             // Handle the response here
             if let error = error {
                 print("Error: \(error)")
                 return
             }

             if let data = data {
                 // Process the response data
                 print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
             }
         }
        task.resume()

    }


    static func addItemToPlaybackQueue(tokenString: String, trackUrl: String) async throws{
        guard let urlRequest = createURLRequestAddItemToPlaybackQueue(tokenString: tokenString, trackUrl: trackUrl) else {throw NetworkError.invalidURL}
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
             // Handle the response here
             if let error = error {
                 print("Error: \(error)")
                 return
             }

             if let data = data {
                 // Process the response data
                 print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
             }
         }
        task.resume()

    }
    static func forward(tokenString: String) async throws {
        guard let urlRequest = createURLRequestForward(tokenString: tokenString) else {
            throw NetworkError.invalidURL
        }

        // Use Task or Task.withGroup to await the completion of the data task
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                // Handle the response here
                if let error = error {
                    print("Error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }

                if let data = data {
                    // Process the response data
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                    continuation.resume()
                }
            }
            task.resume()
        }
    }


    
   
    
    


    static private func createURLRequestDevices(tokenString: String) -> URLRequest? {
        let endpoint = "/v1/me/player/devices"
        guard let url = URL(string: "https://\(SpotifyConstants.apiHost)\(endpoint)") else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer " + tokenString, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }
    
    
    static private func createURLRequestPlayback(tokenString: String, deviceId: String, isPlaying: Bool) -> URLRequest? {
        var endpoint = ""
        if(isPlaying){
            endpoint = "/v1/me/player/pause"
        } else{
            endpoint = "/v1/me/player/play"
        }
        
        guard var components = URLComponents(string: "https://\(SpotifyConstants.apiHost)\(endpoint)") else {
            return nil
        }
        
        if deviceId != ""{
            components.queryItems = [URLQueryItem(name: "device_id", value: deviceId)]
        }
        
        guard let url = components.url else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("Bearer " + tokenString, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }


    static private func createURLRequestRecommendations(tokenString: String, bpm: Int) -> URLRequest?{
        var components = URLComponents()
        components.scheme = "https"
        components.host = SpotifyConstants.apiHost
        components.path = "/v1/recommendations"
        
        components.queryItems = [
        URLQueryItem(name: "min_tempo", value: String(bpm - 5)),
        URLQueryItem(name: "max_tempo", value: String(bpm + 5)),
        URLQueryItem(name: "seed_genres", value: "work-out,groove,house,pop"),
        URLQueryItem(name: "limit", value: "1")
        ]
        
        guard let url = components.url else {return nil}
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue("Bearer " + tokenString, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpMethod = "GET"
        
        return urlRequest
        
    }

    static private func createURLGetCurrentlyPlayingTrack(tokenString: String) -> URLRequest?{
        var components = URLComponents()
        components.scheme = "https"
        components.host = SpotifyConstants.apiHost
        components.path = "/v1/me/player/currently-playing"
        
        guard let url = components.url else {return nil}
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue("Bearer " + tokenString, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpMethod = "GET"
        
        return urlRequest
        
    }


    
    
    
    static private func createURLRequestAddItemToPlaybackQueue(tokenString: String, trackUrl: String) -> URLRequest? {
        let endpoint = "/v1/me/player/queue"
        guard var urlComponents = URLComponents(string: "https://\(SpotifyConstants.apiHost)\(endpoint)") else {
            return nil
        }

        // Add the uri parameter to the URL
        let uri = trackUrl
        urlComponents.queryItems = [URLQueryItem(name: "uri", value: uri)]

        guard let url = urlComponents.url else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer " + tokenString, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }

    
    static private func createURLRequestForward(tokenString: String) -> URLRequest? {
        let endpoint = "/v1/me/player/next"
        guard var urlComponents = URLComponents(string: "https://\(SpotifyConstants.apiHost)\(endpoint)") else {
            return nil
        }

        guard let url = urlComponents.url else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer " + tokenString, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }
    
    static func getCurrentlyPlayingTrack(tokenString: String) async throws -> Currently{
        guard let urlRequest = createURLGetCurrentlyPlayingTrack(tokenString: tokenString) else {throw NetworkError.invalidURL}
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        let decoder = JSONDecoder()
        //let results = try decoder.decode(Response.self, from: data)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON Response: \(jsonString)")
        }
        
        let currentlyPlaying = try decoder.decode(Currently.self, from: data)
        print("duration: \(currentlyPlaying.item.duration_ms) artist: \(currentlyPlaying.item.artists.map{$0.name}), name: \(currentlyPlaying.item.name), image: \(String(describing: currentlyPlaying.item.album.images.first?.url)) isPlaying: \(currentlyPlaying.is_playing)")
        return currentlyPlaying
    }


    static func getDevices(tokenString: String) async throws -> DevicesResponse{
        guard let urlRequest = createURLRequestDevices(tokenString: tokenString) else {throw NetworkError.invalidURL}
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        let decoder = JSONDecoder()
        let results = try decoder.decode(DevicesResponse.self, from: data)

        print(results)
        return results
    }

    
    static func getRecommendations(tokenString: String, bpm: Int) async throws -> String{
        guard let urlRequest = createURLRequestRecommendations(tokenString: tokenString, bpm: bpm) else {throw NetworkError.invalidURL}
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        /*if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON Response: \(jsonString)")
        }
         */
        
        let decoder = JSONDecoder()
        let results = try decoder.decode(Response.self, from: data)
        
        let trackUrl = results.tracks[0].external_urls.spotify
        print(trackUrl)
        return trackUrl
    }
    
    struct Response: Codable {
        let tracks: [Track]
    }
    
    struct Track: Codable{
        let external_urls: External_urls
    }
    
    struct External_urls: Codable{
        let spotify: String
    }
    
    struct Currently: Codable {
        let progress_ms: Int
        let item: Item
        let is_playing: Bool
        init() {
            self.item = Item()
            self.progress_ms = 0
            self.is_playing = false
        }
    }
    
    struct Item: Codable{
        let duration_ms: Int
        let artists: [Artist]
        let name: String
        var album: Album
        
        init() {
            self.duration_ms = 0
            self.artists = [Artist(name: "")]
            self.name = ""
            self.album = Album(images: [Image(url: "https://en.m.wikipedia.org/wiki/File:Cat03.jpg")])
        }
    }
    
    struct Artist: Codable{
        let name: String
        init(name: String) {
            self.name = name
        }
    }
    
    struct Album: Codable{
        var images: [Image]
        
        init(images: [Image]) {
            self.images = images
        }
    }
    
    struct Image: Codable{
        var url: String
        
        init(url: String) {
            self.url = url
        }
    }
    
    struct DevicesResponse: Codable{
        let devices: [Device]
    }
    
    struct Device: Codable{
        let id: String
        let name: String
    }
    
    enum Operation{
        case PLAY
        case PAUSE
        case FORWARD
    }
}
