//
//  SpotifyApi.swift
//  BeatMotion
//
//  Created by Esteban Masaya on 2024-01-04.
//

import Foundation


class SpotifyApi{
    
    static func startPlayback(tokenString: String) async throws{
        guard let urlRequest = createURLRequestPlayback(tokenString: tokenString) else {throw NetworkError.invalidURL}
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
    
   
    
    
    static private func createURLRequestPlayback(tokenString: String) -> URLRequest? {
        let endpoint = "/v1/me/player/play"
        guard let url = URL(string: "https://\(SpotifyConstants.apiHost)\(endpoint)") else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("Bearer " + tokenString, forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "context_uri": "spotify:album:5ht7ItJgpBH7W6vJ5BqpPr",
            "offset": [
                "position": 5
            ],
            "position_ms": 0
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            urlRequest.httpBody = jsonData
        } catch {
            print("Error encoding request body: \(error)")
            return nil
        }

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
        URLQueryItem(name: "seed_genres", value: "world-music"),
        URLQueryItem(name: "limit", value: "20")
        ]
        
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
    
    
}
