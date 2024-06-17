//
//  MovieIntroViewModel.swift
//  MovieTrailer
//
//  Created by Kevin Lu on 2024/6/12.
//

import Foundation
import Combine

class MovieIntroViewModel: ObservableObject {
    @Published var detail: DetailResponse?
    @Published var video: Video?
    @Published var posters: [Poster]?
    @Published var similar: SimilarResponse?
    @Published var isLoadingDetail = false
    @Published var isLoadingVideo = false
    
    private let networkService: NetworkProtocol
    private let apiRequest: APIRequestProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkProtocol, apiRequest: APIRequestProtocol) {
        self.networkService = networkService
        self.apiRequest = apiRequest
    }
    
    func fetchDetail(movieId: Int) {
        isLoadingDetail = true
        let request = apiRequest.detail(movieId: movieId)
        networkService.fetch(with: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoadingDetail = false
            } receiveValue: { [weak self] (response: DetailResponse) in
                self?.detail = response
            }
            .store(in: &cancellables)
    }
    
    func fetchVideo(movieId: Int) {
        isLoadingVideo = true
        let request = apiRequest.video(movieId: movieId)
        networkService.fetch(with: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoadingVideo = false
            } receiveValue: { [weak self] (response: VideoResponse) in
                if let officialTrailer = response.results.first(where: { $0.isOfficialTrailer }) {
                    self?.video = officialTrailer
                } else {
                    self?.video = response.results.first(where: { $0.videoType == .trailer })
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchImages(movieId: Int) {
        let request = apiRequest.images(movieId: movieId)
        networkService.fetch(with: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { [weak self] (response: ImagesResponse) in
                
                self?.posters = response.posters
            }
            .store(in: &cancellables)
    }
    
    func fetchSimilar(movieId: Int) {
        let request = apiRequest.similar(movieId: movieId)
        networkService.fetch(with: request)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { [weak self] (response: SimilarResponse) in
                self?.similar = response
            }
            .store(in: &cancellables)
    }
}
