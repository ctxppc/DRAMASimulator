// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A source file parsed into lexical units, mapped to statements, and assembled to a program.
struct Script {
	
	/// Parses a script from given text.
	init(from sourceText: String = "") {
		
		storedSourceText = sourceText
		lexicalUnits = LexicalUnit.units(in: sourceText)
		statements = lexicalUnits.map { Statement(from: $0, source: sourceText) }
		
		var statementIndicesBySymbol: [Symbol : Int] = [:]
		for (lexicalUnit, index) in zip(lexicalUnits, lexicalUnits.indices) {
			if case .label(symbol: let range, fullRange: _) = lexicalUnit {
				statementIndicesBySymbol[.init(sourceText[range])] = index
			}
		}
		self.statementIndicesBySymbol = statementIndicesBySymbol
		
		let sourceErrors = lexicalUnits.compactMap { unit -> SourceError? in
			guard case .error(let error) = unit else { return nil }
			return error
		}
		
		if sourceErrors.isEmpty {
			do {
				program = .program(try Program(statements: statements, statementIndicesBySymbol: statementIndicesBySymbol))
			} catch let error as SourceError {
				program = .sourceErrors([error])
			} catch let error as StatementError {
				if let sourceError = StatementSourceError(from: error, lexicalUnits: lexicalUnits) {
					program = .sourceErrors([sourceError])
				} else {
					program = .programError(error)
				}
			} catch {
				program = .programError(error)
			}
		} else {
			program = .sourceErrors(sourceErrors)
		}
		
	}
	
	/// The script's source text.
	var sourceText: String {
		get { return storedSourceText }
		set { self = .init(from: newValue) }
	}
	
	/// The backing storage for `text`.
	private let storedSourceText: String
	
	/// The script's lexical units.
	let lexicalUnits: [LexicalUnit]
	
	/// The script's statements.
	let statements: [Statement]
	
	/// A dictionary mapping symbols to indices in the `statements` array.
	let statementIndicesBySymbol: [Symbol : Int]
	typealias Symbol = String
	
	/// A program, or if there are errors, the errors that prevent a program from being assembled.
	let program: PartialProgram
	enum PartialProgram {
		
		/// A program could be assembled.
		case program(Program)
		
		/// A program couldn't be assembled due to source errors.
		case sourceErrors([SourceError])
		
		/// A program couldn't be assembled due to non-source errors.
		case programError(Error)
		
	}
	
}
