// DRAMASimulator © 2018–2021 Constantino Tsarouhas

/// A value or address operand specified in assembly code.
///
/// Value operands may evaluate to values exceeding the address space so they're truncated as needed if they're used in memory accesses.
struct ValueOperand {
	
	/// The base value, as a signed value, i.e., as written in assembly.
	var base: Int
	
	/// The index to apply on the base, or `nil` if no indexing is to be applied.
	var index: Index?
	struct Index {
		
		init(indexRegister: Register, modification: ValueOperand.Index.Modification? = nil) {
			self.indexRegister = indexRegister
			self.modification = modification
		}
		
		init?(from indexRegister: CommandStatement.Argument.Address.IndexRegister) {
			switch indexRegister {
				case .none:								return nil
				case .reading(let register):			self.init(indexRegister: register, modification: nil)
				case .preincrementing(let register):	self.init(indexRegister: register, modification: .preincrement)
				case .postincrementing(let register):	self.init(indexRegister: register, modification: .postincrement)
				case .predecrementing(let register):	self.init(indexRegister: register, modification: .predecrement)
				case .postdecrementing(let register):	self.init(indexRegister: register, modification: .postdecrement)
			}
		}
		
		/// The register that contains the index.
		var indexRegister: Register
		
		/// The modification to perform on the index register before or after indexation, or `nil` if the index register is unaffected by indexing.
		var modification: Modification?
		enum Modification : Int {
			case preincrement	= 3
			case postincrement	= 4
			case predecrement	= 5
			case postdecrement	= 6
		}
		
	}
	
	/// Evaluates the value, adding given index value.
	///
	/// - Parameter index: The index.
	func value(adding index: MachineWord) -> MachineWord {
		var value = index
		value.modifySignedValueWithWrapping { $0 += base }
		return value
	}
	
}

extension ValueOperand {
	
	init(base: Int, indexRegister: Register, mode: Int) {
		self.base = base
		self.index = Index(indexRegister: indexRegister, mode: mode)
	}
	
	var mode: Int {
		return index?.mode ?? 1
	}
	
}

extension ValueOperand.Index {
	
	init?(indexRegister: Register, mode: Int) {
		if let modification = Modification(rawValue: mode) {
			self.init(indexRegister: indexRegister, modification: modification)
		} else if mode == 2 {
			self.init(indexRegister: indexRegister, modification: nil)
		} else {
			return nil
		}
	}
	
	var mode: Int {
		return modification?.rawValue ?? 2
	}
	
}
