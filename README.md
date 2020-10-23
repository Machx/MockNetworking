# MockNetworking

MockNetworking is a Swift package allowing the replaying of mock responses to network requests through Apple Networking API's by tying into the URLProtocol system.

## Installation

MockNetworking is available for integration into Xcode through the Swift Package Manager. Point to `https://github.com/Machx/MockNetworking.git` in Xcode when adding the new package.

## Basic Usage

To setup a mock response you simply need to register the response and then unregister the class when appropraite. In the example below we'll setup a response for 1 test.

```swift
let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
let response = try XCTUnwrap(HTTPURLResponse(url: url,
					statusCode: 200,
					httpVersion: HTTPURLResponse.HTTP_1_1,
					headerFields: nil))

MockURLProtocol.register(response: response, for: url)
defer {
	MockURLProtocol.unregister()
}
```
This uses `HTTPURLResponse`, there is also a custom api available.

```swift
let url = try XCTUnwrap(URL(string: "https://wwww.apple.com"))
let mockResponse = MockPropertyResponse(url: url,
					status: 200,
					headerFields: [:])

MockURLProtocol.regigsterMock(response: mockResponse, for: url)
defer {
	MockURLProtocol.unregister()
}
```

The `register` api both registers MockURLProtocol with the URLProtocol system if it isn't already registered and stores the prepared response for the given url.

## License

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
