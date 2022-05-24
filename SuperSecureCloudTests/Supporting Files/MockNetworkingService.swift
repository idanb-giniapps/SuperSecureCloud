//
//  MockNetworkingService.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import Foundation
@testable import SuperSecureCloud

class MockNetworkingService: NetworkingServiceProtocol {
	
	func bringSignUpValidationInfo() async throws -> SignUpValidationInfo {
		
		Bundle(for: type(of: self))
			.decode(SignUpValidationInfo.self,
					from			: "mockResponse",
					withExtension	: "json")
	}
	
}
