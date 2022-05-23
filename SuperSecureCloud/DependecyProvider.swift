//
//  DependecyProvider.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import Foundation

struct DependencyProvider {
	static var networkingService: NetworkingServiceProtocol { NetworkingService() }
	static var signUpValidator: SignUpValidatorProtocol { SignUpValidator() }
}
