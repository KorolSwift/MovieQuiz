//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Ди Di on 26/01/25.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    if !mostPopularMovies.errorMessage.isEmpty || mostPopularMovies.items.isEmpty {
                        let errorDescription = mostPopularMovies.errorMessage.isEmpty ?
                        "Сегодня фильмов для квиза нет" : mostPopularMovies.errorMessage
                        handler(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorDescription])))
                        return
                    }
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}



