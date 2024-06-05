//
// Copyright 2023 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

@testable import ElementX
import MatrixRustSDK
import XCTest

final class MediaLoaderTests: XCTestCase {
    func testMediaRequestCoalescing() async {
        let mediaLoadingClient = ClientSDKMock()
        mediaLoadingClient.getMediaContentMediaSourceReturnValue = Data()
        let mediaLoader = MediaLoader(client: mediaLoadingClient)
        
        let mediaSource = MediaSourceProxy(url: URL.documentsDirectory, mimeType: nil)
        
        do {
            for _ in 1...10 {
                _ = try await mediaLoader.loadMediaContentForSource(mediaSource)
            }
            
            XCTAssertEqual(mediaLoadingClient.getMediaContentMediaSourceCallsCount, 10)
        } catch {
            fatalError()
        }
    }
    
    func testMediaThumbnailRequestCoalescing() async {
        let mediaLoadingClient = ClientSDKMock()
        mediaLoadingClient.getMediaThumbnailMediaSourceWidthHeightReturnValue = Data()
        let mediaLoader = MediaLoader(client: mediaLoadingClient)
        
        let mediaSource = MediaSourceProxy(url: URL.documentsDirectory, mimeType: nil)
        
        do {
            for _ in 1...10 {
                _ = try await mediaLoader.loadMediaThumbnailForSource(mediaSource, width: 100, height: 100)
            }
            
            XCTAssertEqual(mediaLoadingClient.getMediaThumbnailMediaSourceWidthHeightCallsCount, 10)
        } catch {
            fatalError()
        }
    }
}
