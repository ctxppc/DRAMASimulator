// DRAMASimulator © 2018 Constantino Tsarouhas

import Darwin

/// A value that represents a decimal value of some fixed number of digits.
///
/// - Invariant: A raw value `v` is representable by `Self` iff `unsignedRange.contains(v)`.
protocol WordProtocol : Equatable, RawRepresentable where RawValue == Int {
	
	/// The upper bound unsigned decimal value.
	///
	/// - Invariant: `unsignedUpperBound` = 10ⁿ for some nonnegative integer *n*.
	static var unsignedUpperBound: Int { get }
	
}

extension WordProtocol {
	
	/// The range of unsigned integers representable by words of this type.
	static var unsignedRange: Range<Int> {
		return -unsignedUpperBound..<unsignedUpperBound
	}
	
	/// The range of signed integers representable by words of this type.
	static var signedRange: Range<Int> {
		return -(unsignedUpperBound/2)..<(unsignedUpperBound/2)
	}
	
	/// The zero word.
	static var zero: Self {
		return Self(rawValue: 0)!
	}
	
	/// Creates a word with given signed value, wrapping it if necessary.
	init(wrapping signedValue: Int) {
		let wrappedValue = signedValue % Self.unsignedUpperBound
		self.init(rawValue: wrappedValue > 0 ? wrappedValue : Self.unsignedUpperBound + wrappedValue)!
	}
	
	/// Creates a word with given unsigned value, truncating it if necessary.
	///
	/// - Requires: `unsignedValue` ≥ 0.
	init(truncating unsignedValue: Int) {
		precondition(unsignedValue >= 0, "Truncating negative value")
		self.init(rawValue: unsignedValue % Self.unsignedUpperBound)!
	}
	
	/// The word as an unsigned value.
	///
	/// - Invariant: `Self.unsignedRange.contains(unsignedValue)`.
	var unsignedValue: Int {
		
		get {
			return rawValue
		}
		
		set {
			guard let v = Self.init(rawValue: newValue) else { preconditionFailure("Unrepresentable unsigned value") }
			self = v
		}
		
	}
	
	/// The word as a signed value.
	///
	/// - Invariant: `Self.signedRange.contains(signedValue)`.
	var signedValue: Int {
		
		get {
			if rawValue < Self.unsignedUpperBound / 2 {
				return rawValue
			} else {
				return rawValue - Self.unsignedUpperBound
			}
		}
		
		set {
			guard let v = Self.init(rawValue: newValue > 0 ? newValue : Self.unsignedUpperBound + newValue) else { preconditionFailure("Unrepresentable signed value") }
			self = v
		}
		
	}
	
	/// Modifies the word's signed value and wraps the result before storing it.
	mutating func modifySignedValueWithWrapping(_ handler: (inout Int) -> ()) {
		var signedValue = self.signedValue
		handler(&signedValue)
		self = Self.init(wrapping: signedValue)
	}
	
	/// Increments the word's value by 1, looping back at overflow.
	///
	/// This method is equivalent to but more efficient than `self.modifySignedValueWithWrapping { $0 += 1 }`.
	mutating func increment() {
		self = Self.init(rawValue: rawValue + 1 == Self.unsignedUpperBound ? 0 : rawValue + 1)!
	}
	
	/// Decrements the word's value by 1, looping back at overflow.
	///
	/// This method is equivalent to but more efficient than `self.modifySignedValueWithWrapping { $0 -= 1 }`.
	mutating func decrement() {
		self = Self.init(rawValue: rawValue - 1 == 0 ? Self.unsignedUpperBound : rawValue - 1)!
	}
	
}
