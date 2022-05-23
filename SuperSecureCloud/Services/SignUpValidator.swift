//
//  SignUpValidationService.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import Foundation
import Combine

protocol SignUpValidatorProtocol {
	func validate(username: String) throws -> String
	func validate(password: String) throws -> String
}

class SignUpValidator: SignUpValidatorProtocol {
	@AccessQueue private var validationInfo: SignUpValidationInfo = .default
	
	init(networkingService: NetworkingServiceProtocol = DependencyProvider.networkingService) {
		Task {
			if let remoteValidationInfo = try? await networkingService.bringSignUpValidationInfo() {
				validationInfo = remoteValidationInfo
				
			}
		}
	}
		
	func validate(username: String) throws -> String {
		
		if username.count < 4 {
			throw ValidationError.Username.tooShort
		}
		else if username.count > 16 {
			throw ValidationError.Username.tooLong
		}
		else if validationInfo.existingUsernames.contains(username) {
			throw ValidationError.Username.alreadyExists
		}
		
		return username
	}
	
	func validate(password: String) throws -> String {
				
		if password.count < 8 {
			throw ValidationError.Password.tooShort
		}
		
		else if password.count > 16 {
			throw ValidationError.Password.tooLong
		}
		
		else if validationInfo.existingPasswords.contains(password) {
			throw ValidationError.Password.alreadyExists
		}
		
		else if validationInfo.insecurePasswords.contains(password) {
			throw ValidationError.Password.insecure
		}
		
		return password
	}
	
}

enum ValidationError: Error {
	case notReady
	
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
