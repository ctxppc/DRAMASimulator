// DRAMASimulator © 2018 Constantino Tsarouhas

struct Address {
	
	/// The constant parts of the address (separated by `+` in assembly code).
	///
	/// The constants are statically summed by the executable.
	///
	/// - Invariant: `constants` is not empty.
	var constants: [Constant]
	enum Constant {
		case name(String)
		case value(Int)
	}
	
	/// The index to apply on the constant.
	var index: Index?
	struct Index {
		
		/// The register that contains the index.
		var indexRegister: Int
		
		/// The modification to perform on the index register before or after indexation.
		var modification: Modification?
		enum Modification {
			case preincrement
			case postincrement
			case predecrement
			case postdecrement
		}
		
	}
	
}
