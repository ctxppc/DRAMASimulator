// DRAMASimulator © 2018 Constantino Tsarouhas

/// An unsigned 10-digit decimal.
struct Word : RawRepresentable {
	
	/// The range of unsigned integers representable by words.
	static let unsignedRange = 0..<1_00000_00000
	
	/// The range of signed integers representable by words.
	static let signedRange = -50000_00000..<50000_00000
	
	/// The zero word.
	static let zero = Word(rawValue: 0)!
	
	// See protocol.
	init?(rawValue: Int) {
		guard Word.unsignedRange.contains(rawValue) else { return nil }
		self.rawValue = rawValue
	}
	
	/// Converts an address word losslessly into an address word.
	init(_ addressWord: AddressWord) {
		rawValue = addressWord.rawValue
	}
	
	// See protocol.
	private(set) var rawValue: Int
	
	/// The word as a signed value.
	///
	/// - Invariant: `signedRange.contains(signedValue)`.
	var signedValue: Int {
		
		get {
			return rawValue < Word.signedRange.upperBound ? rawValue : rawValue - Word.unsignedRange.upperBound
		}
		
		set {
			precondition(Word.signedRange.contains(newValue), "Unrepresentable signed value")
			rawValue = newValue > 0 ? newValue : Word.unsignedRange.upperBound + newValue
		}
		
	}
	
	/// Increments the word's value by 1, looping back at overflow.
	mutating func increment() {
		if rawValue + 1 == Word.unsignedRange.upperBound {
			rawValue = Word.unsignedRange.lowerBound
		} else {
			rawValue += 1
		}
	}
	
	/// Decrements the word's value by 1, looping back at overflow.
	mutating func decrement() {
		if rawValue - 1 < Word.unsignedRange.lowerBound {
			rawValue = Word.unsignedRange.upperBound - 1
		} else {
			rawValue -= 1
		}
	}
	
	/// The word's digits.
	///
	/// - Invariant: `digits` contains exactly 10 elements.
	/// - Invariant: For all digits `d` in `digits`, 0 ≤ `d` ≤ 9.
	var digits: [Int] {
		
		get {
			let unpaddedDigits = String(rawValue).map { Int(String($0))! }
			return Array(repeating: 0, count: 10 - unpaddedDigits.count) + unpaddedDigits
		}
		
		set {
			precondition(newValue.count == 10, "10 digits expected")
			precondition(newValue.allSatisfy { (0..<10).contains($0) }, "Digits expected")
			rawValue = digits.reduce(0) { product, digit in product * 10 + digit }
		}
		
	}
	
}
