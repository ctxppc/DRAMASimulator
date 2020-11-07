// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A value that processes a translation unit into a form that can be parsed into a compilation unit.
struct Preprocessor {
	
	/// Creates a preprocessor for processing given translation unit.
	init(translationUnit: TranslationUnit) {
		self.translationUnit = translationUnit
	}
	
	/// The translation unit being processed.
	private(set) var translationUnit: TranslationUnit
	
	/// A Boolean value indicating whether the translation unit is processed into a form that can be parsed into a compilation unit.
	var processed: Bool {
		translationUnit.isProcessed
	}
	
	/// The processed macros.
	var macros: [MacroDefinition] = []
	
	/// The current scope.
	var scope: Scope = .global(values: [:])
	
	/// A mapping of variables to values in some lexical scope.
	enum Scope {
		
		/// A global scope.
		case global(values: [String : Int])
		
		/// A local scope.
		indirect case local(values: [String : Int], outerScope: Scope)
		
		/// Accesses a variable.
		subscript (variable: String) -> Int? {
			
			get {
				switch self {
					
					case .global(values: let values):
					return values[variable]
						
					case .local(values: let values, outerScope: let outerScope):
					return values[variable] ?? outerScope[variable]
				}
			}
			
			set {
				switch self {
					
					case .global(values: var values):
					values[variable] = newValue
					self = .global(values: values)
						
					case .local(values: var values, outerScope: let outerScope):
					values[variable] = newValue
					self = .local(values: values, outerScope: outerScope)
						
				}
			}
			
		}
		
		/// Enters an inner scope.
		mutating func enter() {
			self = .local(values: [:], outerScope: self)
		}
		
		/// Leaves the scope.
		mutating func leave() {
			switch self {
				
				case .global:
				preconditionFailure("Cannot leave global scope")
					
				case .local(values: _, outerScope: let outerScope):
				self = outerScope
					
			}
		}
		
	}
	
	/// The preprocessor's condition state.
	var conditionState: ConditionState = .zero
	
	/// Processes the next lexical unit or directive.
	mutating func processNext() throws {
		TODO.unimplemented
	}
	
}
