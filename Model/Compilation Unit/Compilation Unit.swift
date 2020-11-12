// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A sequence of statements and labels that represent a program.
///
/// A compilation is parsed from a fully preprocessed translation unit, then used as input for compiling a program.
struct CompilationUnit : Construct {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		
		func parseNextElement() throws -> Element {
			
			if parser.consume(StatementTerminatorLexicalUnit.self) != nil {
				return try parseNextElement()
			} else if let comment = parser.consume(CommentLexicalUnit.self) {
				return .comment(comment)
			} else if let terminator = parser.consume(ProgramTerminatorLexicalUnit.self) {
				return .programTerminator(terminator)
			}
			
			do {
				return .statement(try parser.parse(CommandStatement.self))
			} catch let e1 as Parser.Error {
				do {
					do {
						return .statement(try parser.parse(ValueStatement.self))
					} catch let e2 as Parser.Error {
						do {
							do {
								return .statement(try parser.parse(AllocationStatement.self))
							} catch let e3 as Parser.Error {
								do {
									do {
										return .label(try parser.parse(LabelConstruct.self))
									} catch let e4 as Parser.Error {
										let units = parser.consume(until: {
											$0 is CommentLexicalUnit || $0 is StatementTerminatorLexicalUnit || $0 is ProgramTerminatorLexicalUnit
										})
										return .unrecognisedSource(.init(lexicalUnits: units, error: max(e1, e2, e3, e4)))
									}
								}
							}
						}
					}
				}
			}
			
		}
		
		var elements: [Element] = []
		while parser.hasUnprocessedLexicalUnits {
			elements.append(try parseNextElement())
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
		case comment(CommentLexicalUnit)
		case programTerminator(ProgramTerminatorLexicalUnit)
		case unrecognisedSource(UnrecognisedSource)
	}
	
	/// An element representing source that couldn't be parsed.
	struct UnrecognisedSource {
		
		let lexicalUnits: ArraySlice<LexicalUnit>
		let error: Error
		
		/// The source range.
		var sourceRange: SourceRange {
			guard let first = lexicalUnits.first, let last = lexicalUnits.last else { preconditionFailure("No lexical units") }
			return first.sourceRange.lowerBound..<last.sourceRange.upperBound
		}
		
	}
	
}
