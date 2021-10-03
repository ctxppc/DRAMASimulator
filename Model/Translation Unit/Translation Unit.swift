// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A sequence of lexemes and directives that can be or is processed into a form that can be parsed into a compilation unit.
///
/// A translation unit is parsed from a source unit, then transformed by a preprocessor until it no longer contains directives, and finally used as the input for parsing a compilation unit.
struct TranslationUnit : Construct {
	
	/// Creates a translation unit containing lexemes produced by given lexer.
	init(from sourceUnit: SourceUnit) {
		var parser = Parser(lexemes: sourceUnit.lexemes)
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
		
		func consumeIrrelevantLexemes() {
			let lexemes = parser.consume(until: { $0 is IdentifierLexeme || $0 is PreprocessorLabelLexeme || $0 is PreprocessorVariableAccessLexeme })
			elements.append(contentsOf: lexemes.map { .lexeme($0) })
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
			guard let unit = copy.consume(IdentifierLexeme.self), macroIdentifiers.contains(unit.identifier) else { return false }
			let directive = try parser.parse(InvocationDirective.self)
			elements.append(.directive(directive))
			macroIdentifiers.insert(directive.macroName)
			return true
		}
		
		consumeIrrelevantLexemes()
		
		while parser.hasUnprocessedLexemes {
			
			let extractedDirective = try parseInvocationDirective()
				|| parseDirective(ofType: ValueDirective.self)
				|| parseDirective(ofType: MacroDefinition.self)
				|| parseDirective(ofType: AssignmentDirective.self)
				|| parseDirective(ofType: ComparisonDirective.self)
				|| parseDirective(ofType: ConditionalJumpDirective.self)
				|| parseDirective(ofType: UnconditionalJumpDirective.self)
				|| parseDirective(ofType: FailDirective.self)
			
			if !extractedDirective {
				elements.append(.lexeme(parser.consume(IdentifierLexeme.self) !! "Expected preprocessor lexemes to be processed"))
			}
			
			consumeIrrelevantLexemes()
			
		}
		
		self.unprocessedElements = elements
		
	}
	
	/// The translation unit's processed or produced lexemes.
	private(set) var processedLexemes: [Lexeme] = []
	
	/// The translation unit's unprocessed elements.
	private(set) var unprocessedElements: [Element]
	enum Element {
		case lexeme(Lexeme)
		case directive(Directive)
	}
	
	/// A Boolean value indicating whether the translation unit is processed into a form that can be parsed into a compilation unit.
	var isProcessed: Bool {
		unprocessedElements.isEmpty
	}
	
}
