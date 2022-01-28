//
//  APICaller.swift
//  SpotifyClone
//
//  Created by Victor Feitosa on 21/01/22.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constanst {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    private init(){}
    
    enum APIError: Error {
        case faileedToGetData
    }
    
    //MARK: - Albums
    public func getAlbumDetails(for album: Album, completion: @escaping(Result<AlbumDetailsResponse, Error>) -> Void){
        createRequest(with: URL(string: Constanst.baseAPIURL + "/albums/" + album.id), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }
                
                do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print(json)
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
                
            }
            
            task.resume()
        }
    }
    
    //MARK: - Playlists
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping(Result<PlaylistDetailsResponse, Error>) -> Void){
        createRequest(with: URL(string: Constanst.baseAPIURL + "/playlists/" + playlist.id), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }
                
                do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print(json)
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
                
            }
            
            task.resume()
        }
    }
    
    //MARK: - Profile
    public func getCurrentProfile(completion: @escaping (Result<UserProfile, Error>) -> Void){
        createRequest(
            with: URL(string: Constanst.baseAPIURL + "/me"), type: .GET) { baseRequest in
                let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                    guard let data = data, error == nil else {
                        completion(.failure(APIError.faileedToGetData))
                        return
                    }
                    
                    do {
                        //let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        //print(result)
                        let result = try JSONDecoder().decode(UserProfile.self, from: data)
                        completion(.success(result))
                    } catch {
                        print(error.localizedDescription)
                        completion(.failure(error))
                    }
                }
                
                task.resume()
            }
    }
    
    //MARK: - Browse
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse, Error>)) -> Void){
        createRequest(with: URL(string: Constanst.baseAPIURL + "/browse/new-releases?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }

            }
            
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists(completion: @escaping(Result<FeaturedPlaylistsResponse, Error>) -> Void){
        createRequest(with: URL(string: Constanst.baseAPIURL + "/browse/featured-playlists?limit=20"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
//                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    //print(result)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                    print(error.localizedDescription)
                }

            }
            
            task.resume()
        }
    }
    
    public func getRecommendationsGenres(completion: @escaping((Result<RecommendedGenresResponse, Error>)) -> Void){
        createRequest(with: URL(string: Constanst.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                    print(error.localizedDescription)
                }

            }

            task.resume()
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping((Result<RecommendationsResponse, Error>)) -> Void){
        let seeds = genres.joined(separator: ",")
        
        createRequest(with: URL(string: Constanst.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.faileedToGetData))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    //print(result)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }

            }

            task.resume()
        }
    }
    
    
    //MARK: - Private
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            
            completion(request)
        }
    }
}
