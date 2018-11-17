// DRAMASimulator © 2018 Constantino Tsarouhas

/// A 10-digit decimal.
struct Word : WordProtocol {
	
	// See protocol.
	static let upperUnsignedValue = 1_00000_00000
	
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
