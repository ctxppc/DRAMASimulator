// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A source text compiled into a program through its intermediate steps.
///
/// `Script` defines the recipe of converting a source text to a program through its intermediate steps.
struct Script {
	
	/// Creates a script with given text.
	init(from sourceText: String) {
		
		self.sourceText = sourceText
		self.lexicalUnits = Lexer(from: sourceText).lexicalUnits
		
		var parser = Parser(lexicalUnits: lexicalUnits)
		self.compilationUnit = (try? parser.parse(CompilationUnit.self)) !! "Compilation unit parsing shouldn't fail completely"
		
		var statements: [Statement] = []
		var statementIndicesBySymbol: [Symbol : Int] = [:]
		var unrecognisedSources: [CompilationUnit.UnrecognisedSource] = []
		for element in compilationUnit.elements {
			switch element {
				
				case .statement(let statement):
				statements.append(statement)
				
				case .label(let label):
				statementIndicesBySymbol[label.symbol] = statements.endIndex
				
				case .unrecognisedSource(let source):
				unrecognisedSources.append(source)
					
				case .comment, .programTerminator:
				continue
				
			}
		}
		
		self.statements = statements
		self.statementIndicesBySymbol = statementIndicesBySymbol
		
		if unrecognisedSources.isEmpty {
			do {
				self.product = .program(try Program(statements: statements, statementIndicesBySymbol: statementIndicesBySymbol))
			} catch {
				self.product = .programError(error)
			}
		} else {
			self.product = .sourceErrors(unrecognisedSources)
		}
		
	}
	
	/// The source text.
	let sourceText: String
	
	/// The script's lexical units.
	let lexicalUnits: [LexicalUnit]
	
	/// The compilation unit encoded by the script's lexical units.
	let compilationUnit: CompilationUnit
	
	/// The script's statements.
	let statements: [Statement]
	
	/// A dictionary mapping symbols to indices in the `statements` array.
	let statementIndicesBySymbol: [Symbol : Int]
	typealias Symbol = String
	
	/// The script's product, which may be a program if compilation is successful.
	let product: Product
	enum Product {
		
		/// A program could be assembled.
		case program(Program)
		
		/// A program couldn't be assembled due to errors in the source text.
		case sourceErrors([CompilationUnit.UnrecognisedSource])
		
		/// A program couldn't be assembled due to a non-source error.
		case programError(Error)
		
		/// Any errors in the script.
		var errors: [Error] {
			switch self {
				case .program:						return []
				case .sourceErrors(let sources):	return sources.map(\.error)
				case .programError(let error):		return [error]
			}
		}
		
	}
	
}
