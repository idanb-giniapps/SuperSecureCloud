//
//  ProjectExtensions.swift
//  SuperSecureCloud
//
//  Created by Idan Birman on 22/05/2022.
//

import Foundation
import Combine

// MARK: - Bundle
extension Bundle {
	func decode<T: Decodable>(_ type: T.Type, from file: String, withExtension ext: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
		guard let url = self.url(forResource: file, withExtension: ext) else {
			fatalError("Failed to locate \(file) in bundle.")
		}
		
		guard let data = try? Data(contentsOf: url) else {
			fatalError("Failed to load \(file) from bundle.")
		}
		
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = dateDecodingStrategy
		decoder.keyDecodingStrategy = keyDecodingStrategy
		
		do {
			return try decoder.decode(T.self, from: data)
		} catch DecodingError.keyNotFound(let key, let context) {
			fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
		} catch DecodingError.typeMismatch(_, let context) {
			fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
		} catch DecodingError.valueNotFound(let type, let context) {
			fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(_) {
			fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
		} catch {
			fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
		}
	}
}

// MARK: - Property Wrappers
/// All access to the property will be done through a unique concurrent queue with a `barrier` flag for write operations. multiple read operations can happen concurrently.
@propertyWrapper class AccessQueue<T: Any>
{
	@Published private var value: T
	
	private let accessQueue = DispatchQueue(
		label       : "i24news.accessQueue.\(String(describing: T.self))-\(UUID().uuidString)",
		attributes  : .concurrent
	)
	
	func valuePublisher(onQueue queue: DispatchQueue) -> AnyPublisher<T, Never>
	{
		$value
			.receive(on: queue)
			.eraseToAnyPublisher()
	}
	
	var wrappedValue: T
	{
		get
		{
			var returnValue: T!
			
			accessQueue.sync
			{
				returnValue = value
			}
			
			return returnValue
		}
		set
		{
			accessQueue.sync(flags: .barrier)
			{
				value = newValue
			}
		}
	}
	
	init(wrappedValue: T)
	{
		self.value = wrappedValue
	}
}

