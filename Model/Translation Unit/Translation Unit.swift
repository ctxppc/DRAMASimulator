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
		
		var macroIdentifiers: Set<String> = []
		var elements: [Element] = []
		
		func consumeIrrelevantLexicalUnits() {
			let lexicalUnits = parser.consume(until: { $0 is IdentifierLexicalUnit || $0 is PreprocessorLabelLexicalUnit || $0 is PreprocessorVariableAccessLexicalUnit })
			elements.append(contentsOf: lexicalUnits.map { .lexicalUnit($0) })
		}
		
		func parseDirective<D>(ofType _: D.Type) -> Bool where D : Directive {
			do {
				elements.append(.directive(try parser.parse(D.self)))
				return true
			} catch {
				return false
			}
		}
		
		func parseInvocationDirective() throws -> Bool {
			var copy = parser
			guard let unit = copy.consume(IdentifierLexicalUnit.self), macroIdentifiers.contains(unit.identifier) else { return false }
			let directive = try parser.parse(InvocationDirective.self)
			elements.append(.directive(directive))
			macroIdentifiers.insert(directive.macroName)
			return true
		}
		
		consumeIrrelevantLexicalUnits()
		
		while parser.hasUnprocessedLexicalUnits {
			
			let extractedDirective = try parseInvocationDirective()
				|| parseDirective(ofType: ValueDirective.self)
				|| parseDirective(ofType: MacroDefinition.self)
				|| parseDirective(ofType: AssignmentDirective.self)
				|| parseDirective(ofType: ComparisonDirective.self)
				|| parseDirective(ofType: ConditionalJumpDirective.self)
				|| parseDirective(ofType: UnconditionalJumpDirective.self)
				|| parseDirective(ofType: FailDirective.self)
			
			if !extractedDirective {
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
