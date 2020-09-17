// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import DepthKit

/// An identifier for a register.
struct Register : RawRepresentable, Hashable, Comparable {
	
	static let r0 = Register(rawValue: 0)!
	static let r1 = Register(rawValue: 1)!
	static let r2 = Register(rawValue: 2)!
	static let r3 = Register(rawValue: 3)!
	static let r4 = Register(rawValue: 4)!
	static let r5 = Register(rawValue: 5)!
	static let r6 = Register(rawValue: 6)!
	static let r7 = Register(rawValue: 7)!
	static let r8 = Register(rawValue: 8)!
	static let r9 = Register(rawValue: 9)!
	
	/// The range of valid register indices.
	static let indices = 0...9
	
	/// The range of the address space.
	static let all = r0..<r9
	
	// See protocol.
	init?(rawValue: Int) {
		guard Register.indices.contains(rawValue) else { return nil }
		self.rawValue = rawValue
	}
	
	// See protocol.
	let rawValue: Int
	
}

extension Register : Strideable {
	
	func distance(to other: Self) -> Int {
		self.rawValue.distance(to: other.rawValue)
	}
	
	func advanced(by distance: Int) -> Self {
		Self(rawValue: rawValue.advanced(by: distance)) !! "Address out of bounds"
	}
	
}
