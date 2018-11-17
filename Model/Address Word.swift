// DRAMASimulator © 2018 Constantino Tsarouhas

/// A 4-digit decimal.
struct AddressWord : WordProtocol {
	
	// See protocol.
	static let upperUnsignedValue = 10000
	
	// See protocol.
	init?(rawValue: Int) {
		guard AddressWord.unsignedRange.contains(rawValue) else { return nil }
		self.rawValue = rawValue
	}
	
	/// Converts a word into an address word by truncating it (if necessary).
	init(truncating word: Word) {
		self.rawValue = word.rawValue % AddressWord.upperUnsignedValue
	}
	
	// See protocol.
	private(set) var rawValue: Int
	
}
