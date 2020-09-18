// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import DepthKit

/// A 4-digit decimal, usually used to represent addresses.
struct AddressWord : Word, Comparable {
	
	/// The range of the address space.
	static let all = AddressWord.zero...AddressWord(rawValue: unsignedUpperBound - 1)!
	
	// See protocol.
	static let unsignedUpperBound = 10000
	
	// See protocol.
	init?(rawValue: Int) {
		guard AddressWord.unsignedRange.contains(rawValue) else { return nil }
		self.rawValue = rawValue
	}
	
	/// Converts a word into an address word by truncating it (if necessary).
	init(truncating word: MachineWord) {
		self.rawValue = word.rawValue % AddressWord.unsignedUpperBound
	}
	
	// See protocol.
	private(set) var rawValue: Int {
		willSet { assert(rawValue >= 0) }
	}
	
}

extension AddressWord : Strideable {
	
	func distance(to other: Self) -> Int {
		self.rawValue.distance(to: other.rawValue)
	}
	
	func advanced(by distance: Int) -> Self {
		Self(rawValue: rawValue.advanced(by: distance)) !! "Address out of bounds"
	}
	
}
