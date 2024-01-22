
// SpotifyService.swift
// Moodify
// Created by Chisom on 1/7/24.

import Foundation

// MARK: - Spotify API Response Models

// Codable struct representing the overall structure of the Spotify API response.
struct SpotifyAPIResponse: Codable {
    let tracks: SpotifyTracks
}

// Codable struct representing the tracks section of the Spotify API response.
struct SpotifyTracks: Codable {
    let items: [SpotifyTrack]
}

// Codable struct representing an individual track in the Spotify API response.
struct SpotifyTrack: Codable {
    let album: SpotifyAlbum
    let external_urls: ExternalURLs

    // Codable struct representing external URLs associated with a Spotify track.
    struct ExternalURLs: Codable {
        let spotify: String
    }
}

// Codable struct representing album information in the Spotify API response.
struct SpotifyAlbum: Codable {
    let images: [SpotifyImage]
}

// Codable struct representing image information in the Spotify API response.
struct SpotifyImage: Codable {
    let url: String
}

// MARK: - Spotify Service

// A class responsible for interacting with the Spotify API to fetch track information.
class SpotifyService {
    
    // MARK: - Properties
    
    static var token = "" // Static property to store the Spotify API token.
    
    // MARK: - Fetch Spotify Info
    
    // Static function to fetch Spotify track information for a given query.
    static func fetchSpotifyInfo(for query: String, completion: @escaping (Result<SpotifyTrack, Error>) -> Void) {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "%20")

        guard let url = URL(string: "https://api.spotify.com/v1/search?q=\(formattedQuery)&type=track") else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
            }

            do {
                // Uncomment the line below to print the raw JSON data for debugging.
                // print(String(data: data, encoding: .utf8) ?? "Invalid data")
                
                let decodedResponse = try JSONDecoder().decode(SpotifyAPIResponse.self, from: data)
                if let track = decodedResponse.tracks.items.first {
                    completion(.success(track))
                } else {
                    return completion(.failure(NSError(domain: "No track found", code: 0, userInfo: nil)))
                }
            } catch {
                return completion(.failure(error))
            }
        }.resume()
    }
}
