// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A sequence of statements and labels that represent a program.
///
/// A compilation is parsed from a fully preprocessed translation unit, then used as input for compiling a program.
struct CompilationUnit : Construct {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		
		func parseNextElement() throws -> Element? {
			
			guard parser.hasUnprocessedLexemes else { return nil }
			
			if parser.consume(StatementTerminatorLexeme.self) != nil {
				return try parseNextElement()
			} else if let comment = parser.consume(CommentLexeme.self) {
				return .comment(comment)
			} else if let terminator = parser.consume(ProgramTerminatorLexeme.self) {
				return .programTerminator(terminator)
			}
			
			do {
				return .statement(try parser.parse(CommandStatement.self))
			} catch let e1 as Parser.Error {
				do {
					return .statement(try parser.parse(ValueStatement.self))
				} catch let e2 as Parser.Error {
					do {
						return .statement(try parser.parse(AllocationStatement.self))
					} catch let e3 as Parser.Error {
						do {
							return .label(try parser.parse(LabelConstruct.self))
						} catch let e4 as Parser.Error {
							let units = parser.consume(until: {
								$0 is CommentLexeme || $0 is StatementTerminatorLexeme || $0 is ProgramTerminatorLexeme
							})
							return .unrecognisedSource(.init(lexemes: units, error: max(e1, e2, e3, e4)))
						}
					}
				}
			}
			
		}
		
		var elements: [Element] = []
		while let element = try parseNextElement() {	// sequence(state:next:) doesn't support throwing successor functions
			elements.append(element)
		}
		
		self.init(elements: elements)
		
	}
	
	/// Creates a compilation unit with given elements.
	init(elements: [Element]) {
		self.elements = elements
	}
	
	/// The contents of the unit.
	let elements: [Element]
	enum Element {
		case statement(Statement)
		case label(LabelConstruct)
		case comment(CommentLexeme)
		case programTerminator(ProgramTerminatorLexeme)
		case unrecognisedSource(UnrecognisedSource)
	}
	
	/// An element representing source that couldn't be parsed.
	struct UnrecognisedSource {
		
		let lexemes: ArraySlice<Lexeme>
		let error: Error
		
		/// The source range.
		var sourceRange: SourceRange {
			guard let first = lexemes.first, let last = lexemes.last else { preconditionFailure("No lexemes") }
			return first.sourceRange.lowerBound..<last.sourceRange.upperBound
		}
		
	}
	
}
