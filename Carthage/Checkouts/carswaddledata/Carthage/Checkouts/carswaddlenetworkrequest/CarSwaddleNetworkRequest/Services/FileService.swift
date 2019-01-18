//
//  FileUploadService.swift
//  CarSwaddleNetworkRequest
//
//  Created by Kyle Kendall on 1/5/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

extension NetworkRequest.Request.Endpoint {
    fileprivate static let upload = Request.Endpoint(rawValue: "/api/data/profile-picture")
    fileprivate static let uploadMechanic = Request.Endpoint(rawValue: "/api/data/mechanic/profile-picture")
    fileprivate static let getImage = Request.Endpoint(rawValue: "/api/data/image/{imageName}")
    fileprivate static let getUserImage = Request.Endpoint(rawValue: "/api/data/profile-picture/{id}")
    fileprivate static let getMechanicImage = Request.Endpoint(rawValue: "/api/data/mechanic/profile-picture/{id}")
}

final public class FileService: Service {
    
    // Mark: User
    
    @discardableResult
    public func uploadProfileImage(fileURL: URL, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        return upload(fileURL: fileURL, endpoint: .upload, completion: completion)
    }
    
    @discardableResult
    public func getProfileImage(userID: String, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return getProfileImage(id: userID, endpoint: .upload, completion: completion)
    }
    
    // Mark: Mechanic
    
    @discardableResult
    public func uploadMechanicProfileImage(fileURL: URL, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        return upload(fileURL: fileURL, endpoint: .uploadMechanic, completion: completion)
    }
    
    @discardableResult
    public func getMechanicProfileImage(mechanicID: String, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        return getProfileImage(id: mechanicID, endpoint: .getMechanicImage, completion: completion)
    }
    
    // Mark: Generic
    
    
    @discardableResult
    public func getImage(imageName: String, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        guard imageName.isEmpty == false else { return nil }
        guard let path = try? Path(endpoint: .getImage, pathArguments: ["imageName": imageName]) else { return nil }
        guard var urlRequest = serviceRequest.download(withPath: path.path) else { return nil }
        try? urlRequest.authenticate()
        return serviceRequest.download(urlRequest: urlRequest) { downloadedFileURL, response, error in
            completion(downloadedFileURL, error)
        }
    }
    
    // MARK: Generic Private
    
    @discardableResult
    private func upload(fileURL: URL, endpoint: NetworkRequest.Request.Endpoint, completion: @escaping JSONCompletion) -> URLSessionDataTask? {
        guard let urlRequest = serviceRequest.multipartFormDataPost(with: endpoint) else { return nil }
        try? urlRequest.authenticate()
        let contentType = "image/*"
        return serviceRequest.uploadMultipartFormData(urlRequest: urlRequest, fileURL: fileURL, contentType: contentType) { [weak self] data, response, error in
            self?.completeWithJSON(data: data, error: error, completion: completion)
        }
    }
    
    @discardableResult
    private func getProfileImage(id: String, endpoint: NetworkRequest.Request.Endpoint, completion: @escaping (_ fileURL: URL?, _ error: Error?) -> Void) -> URLSessionDownloadTask? {
        guard id.isEmpty == false else { return nil }
        guard let path = try? Path(endpoint: endpoint, pathArguments: ["id": id]) else { return nil }
        guard var urlRequest = serviceRequest.download(withPath: path.path) else { return nil }
        try? urlRequest.authenticate()
        return serviceRequest.download(urlRequest: urlRequest) { downloadedFileURL, response, error in
            completion(downloadedFileURL, error)
        }
    }
    
}
