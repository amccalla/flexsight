//
//  MovieFile.swift
//  FlexSight
//

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// Receives a picked video from the Photos picker as a local file URL.
struct MovieFile: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let destination = URL.temporaryDirectory
                .appending(component: "\(UUID().uuidString).\(received.file.pathExtension)")
            try FileManager.default.copyItem(at: received.file, to: destination)
            return MovieFile(url: destination)
        }
    }
}
