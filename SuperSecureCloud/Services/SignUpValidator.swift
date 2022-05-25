//
//  SignUpValidationService.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import Foundation
import Combine

protocol SignUpValidatorProtocol {
	@discardableResult func validate(username: String) async throws -> String
	@discardableResult func validate(password: String) async throws -> String
}

class SignUpValidator {
	private let networkingService: NetworkingServiceProtocol
	
	private var validationInfo: SignUpValidationInfo {
		get async {
			let remoteValidationInfo = try? await networkingService.bringSignUpValidationInfo()
			return remoteValidationInfo ?? .default
		}
	}
	
	init(networkingService: NetworkingServiceProtocol) {
		self.networkingService = networkingService
	}
}

extension SignUpValidator: SignUpValidatorProtocol {
	@discardableResult
	func validate(username: String) async throws -> String {
		
		if username.count < 4 {
			throw ValidationError.Username.tooShort
		}
		else if username.count > 16 {
			throw ValidationError.Username.tooLong
		}
		else if await validationInfo
			.existingUsernames
			.map(\.localizedLowercase)
			.contains(username.localizedLowercase) { throw ValidationError.Username.alreadyExists }
		
		return username
	}
	
	@discardableResult
	func validate(password: String) async throws -> String {
		
		if password.count < 8 {
			throw ValidationError.Password.tooShort
		}
		
		else if password.count > 32 {
			throw ValidationError.Password.tooLong
		}
		
		else if await validationInfo
			.existingPasswords
			.map(\.localizedLowercase)
			.contains(password.localizedLowercase) { throw ValidationError.Password.alreadyExists }
		
		else if await validationInfo
			.insecurePasswords
			.map({ $0.lowercased() })
			.contains(password.localizedLowercase) { throw ValidationError.Password.insecure }
		
		return password
	}

}

enum ValidationError {
	
	// MARK: - Username
	enum Username: Error {
		case tooLong
		case tooShort
		case alreadyExists
		
		var uiDescription: String {
			switch self {
				case .tooLong		: return "Username too long"
				case .tooShort		: return "Username too short"
				case .alreadyExists	: return "This username already exists"
			}
		}
	}

	// MARK: - Password
	enum Password: Error {
		case tooLong
		case tooShort
		case alreadyExists
		case insecure
		
		var uiDescription: String {
			switch self {
				case .tooLong		: return "Password is too long"
				case .tooShort		: return "Password is too short"
				case .alreadyExists	: return "Password already exists"
				case .insecure		: return "Password is insecure"
			}
		}
	}
}
