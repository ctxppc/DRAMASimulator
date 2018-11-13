// DRAMASimulator © 2018 Constantino Tsarouhas

/// An unsigned 4-digit decimal.
struct AddressWord : RawRepresentable {
	
	/// The range of address words.
	static let range = 0..<10000
	
	/// The zero address.
	static let zero = AddressWord(rawValue: 0)!
	
	// See protocol.
	init?(rawValue: Int) {
		guard AddressWord.range.contains(rawValue) else { return nil }
		self.rawValue = rawValue
	}
	
	/// Converts a word into an address word by truncating it (if necessary).
	init(truncating word: Word) {
		rawValue = word.rawValue % AddressWord.range.upperBound
	}
	
	// See protocol.
	private(set) var rawValue: Int
	
	/// Increments the word's value by 1, looping back at overflow.
	mutating func increment() {
		if rawValue + 1 == AddressWord.range.upperBound {
			rawValue = AddressWord.range.lowerBound
		} else {
			rawValue += 1
		}
	}
	
	/// Increments the word's value by 1, looping back at overflow.
	mutating func decrement() {
		if rawValue - 1 < AddressWord.range.lowerBound {
			rawValue = AddressWord.range.upperBound - 1
		} else {
			rawValue -= 1
		}
	}
	
}
