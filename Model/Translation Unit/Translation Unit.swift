// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A sequence of lexical units and directives that can be or is processed into a form that can be parsed into a compilation unit.
///
/// A translation unit is parsed from a source unit, then transformed by a preprocessor until it no longer contains directives, and finally used as the input for parsing a compilation unit.
struct TranslationUnit : Construct {
	
	/// Creates a translation unit containing lexical units produced by given lexer.
	init(from sourceUnit: SourceUnit) {
		var parser = Parser(lexicalUnits: sourceUnit.lexicalUnits)
		do {
			try self.init(from: &parser)
		} catch {
			fatalError("Translation unit parsing failed unexpectedly: \(error)")
		}
	}
	
	// See protocol.
	init(from parser: inout Parser) throws {
		
		var elements: [Element] = []
		
		func consumeIrrelevantLexicalUnits() {
			let lexicalUnits = parser.consume(until: { $0 is IdentifierLexicalUnit || $0 is PreprocessorLabelLexicalUnit || $0 is PreprocessorVariableAccessLexicalUnit })
			elements.append(contentsOf: lexicalUnits.map { .lexicalUnit($0) })
		}
		
		consumeIrrelevantLexicalUnits()
		
		while parser.hasUnprocessedLexicalUnits {
			
			// TODO: Parse invocation directive (if identifier is known)
			
			if let directive = try? parser.parse(ValueDirective.self) {
				elements.append(.directive(directive))
			} else if let directive = try? parser.parse(MacroDefinition.self) {
				elements.append(.directive(directive))
			} else if let directive = try? parser.parse(AssignmentDirective.self) {
				elements.append(.directive(directive))
			} else if let directive = try? parser.parse(ComparisonDirective.self) {
				elements.append(.directive(directive))
			} else if let directive = try? parser.parse(ConditionalJumpDirective.self) {
				elements.append(.directive(directive))
			} else if let directive = try? parser.parse(UnconditionalJumpDirective.self) {
				elements.append(.directive(directive))
			} else if let directive = try? parser.parse(FailDirective.self) {
				elements.append(.directive(directive))
			} else {
				elements.append(.lexicalUnit(parser.consume(IdentifierLexicalUnit.self) !! "Expected preprocessor lexical units to be processed"))
			}
			
			consumeIrrelevantLexicalUnits()
			
		}
		
		self.unprocessedElements = elements
		
	}
	
	/// The translation unit's processed or produced lexical units.
	private(set) var processedLexicalUnits: [LexicalUnit] = []
	
	/// The translation unit's unprocessed elements.
	private(set) var unprocessedElements: [Element]
	enum Element {
		case lexicalUnit(LexicalUnit)
		case directive(Directive)
	}
	
	/// A Boolean value indicating whether the translation unit is processed into a form that can be parsed into a compilation unit.
	var isProcessed: Bool {
		unprocessedElements.isEmpty
	}
	
}
