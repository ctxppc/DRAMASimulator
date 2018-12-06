// DRAMASimulator © 2018 Constantino Tsarouhas

/// A 10-digit decimal.
struct Word : WordProtocol {
	
	// See protocol.
	static let unsignedUpperBound = 1_00000_00000
	
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
	private(set) var rawValue: Int {
		willSet { assert(rawValue >= 0) }
	}
	
	/// Accesses the unsigned value's digits in given range, where the zeroth digit is the least significant digit.
	///
	/// - Requires: `range.lowerBound` ≥ 0.
	/// - Invariant: The number of decimal digits in `w[digitsAt: a...b]` for some word `w` and integers `a` and `b` is equal to or less than `b` - `a`.
	subscript (digitsAt range: ClosedRange<Int>) -> Int {
		
		get {
			let leftTruncated = unsignedValue / 10 ** range.lowerBound
			return leftTruncated % 10 ** (range.upperBound - range.lowerBound + 1)
		}
		
		set {
			
			assert(newValue < 10 ** (range.upperBound - range.lowerBound + 1), "Digits out of bounds")
			
			let lowMultiplier = 10 ** range.lowerBound
			let highMultiplier = 10 ** (range.upperBound + 1)
			
			let low = unsignedValue % lowMultiplier
			let middle = newValue * lowMultiplier
			let high = unsignedValue / highMultiplier * highMultiplier
			
			self = Word(rawValue: low + middle + high)!
			
		}
	}
	
	/// Accesses the unsigned value's digit at given index, where the zeroth digit is the least significant digit.
	///
	/// - Requires: `index` ≥ 0.
	/// - Invariant: The value of `w[digitAt: a]` for some word `w` and integer `a` is between 0 and 9.
	subscript (digitAt index: Int) -> Int {
		get { return self[digitsAt: index...index] }
		set { self[digitsAt: index...index] = newValue }
	}
	
}

extension Word : CustomStringConvertible {
	var description: String {
		let unpaddedCharacters = Array(String(rawValue))
		return String(repeatElement("0", count: 10 - unpaddedCharacters.count) + unpaddedCharacters)
	}
}

infix operator ** : BitwiseShiftPrecedence

private func ** (base: Int, exponent: Int) -> Int {
	guard exponent > 0 else { return 1 }
	return base * base ** (exponent - 1)
}
