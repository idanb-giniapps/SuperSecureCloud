//
//  MockNetworkingService.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import Foundation

class MockNetworkingService: NetworkingServiceProtocol {
	
	func bringSignUpValidationInfo() async throws -> SignUpValidationInfo {
		Bundle.main.decode(SignUpValidationInfo.self, from: "mockResponse")
	}
	
}
