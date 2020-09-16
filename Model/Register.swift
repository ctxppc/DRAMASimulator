// DRAMASimulator © 2018–2020 Constantino Tsarouhas

/// An identifier for a register.
struct Register : RawRepresentable {
	
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
	
	// See protocol.
	init?(rawValue: Int) {
		guard Register.indices.contains(rawValue) else { return nil }
		self.rawValue = rawValue
	}
	
	// See protocol.
	let rawValue: Int
	
}
