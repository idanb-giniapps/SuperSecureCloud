//
//  NotSoGoodNetworkingService.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 25/05/2022.
//

import Foundation

class NotSoGoodNetworkingService {
	func bringSignUpValidationInfo() async throws -> SignUpValidationInfo {
		let url = URL(string: "https://pastebin.com/raw/ZAYJS8zh")!
		
		guard let (data, _) = try? await URLSession.shared.data(from: url) else {
			throw NetworkingError.requestFailed
		}
		
		guard let result = try? JSONDecoder().decode(SignUpValidationInfo.self, from: data) else {
			throw NetworkingError.parsingFailed
		}
		
		return result
	}
}
