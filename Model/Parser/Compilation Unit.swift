// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import Foundation

/// A sequence of statements and labels that represent a program.
struct CompilationUnit : Construct {
	
	// See protocol.
	init(from parser: inout Parser) {
		
		func parseNextElement() -> Element? {
			
			guard parser.hasUnprocessedLexicalUnits else { return nil }
			
			if parser.consume(StatementTerminatorLexicalUnit.self) != nil {
				return parseNextElement()
			}
			
			if let command = try? parser.parse(CommandStatement.self) {
				return .statement(command)
			} else if let valueStatement = try? parser.parse(ValueStatement.self) {
				return .statement(valueStatement)
			} else if let allocStatement = try? parser.parse(AllocationStatement.self) {
				return .statement(allocStatement)
			} else if let label = try? parser.parse(LabelConstruct.self) {
				return .label(label)
			} else if let comment = parser.consume(CommentLexicalUnit.self) {
				return .comment(comment)
			} else if let terminator = parser.consume(ProgramTerminatorLexicalUnit.self) {
				return .programTerminator(terminator)
			} else {
				let error = parser.deepestError !! "Expected deepest error"
				let units = parser.consume(until: {
					$0 is CommentLexicalUnit || $0 is StatementTerminatorLexicalUnit || $0 is ProgramTerminatorLexicalUnit
				})
				return .unrecognisedSource(.init(lexicalUnits: units, error: error))
			}
			
		}
		
		var elements: [Element] = []
		while let element = parseNextElement() {
			elements.append(element)
		}
		
		self.init(elements: elements)
		
	}
	
	init(elements: [Element]) {
		self.elements = elements
	}
	
	/// The statements in the unit.
	let elements: [Element]
	enum Element {
		case statement(Statement)
		case label(LabelConstruct)
		case comment(CommentLexicalUnit)
		case programTerminator(ProgramTerminatorLexicalUnit)
		case unrecognisedSource(UnrecognisedSource)
	}
	
	struct UnrecognisedSource {
		
		let lexicalUnits: ArraySlice<LexicalUnit>
		let error: Error
		
		/// The source range.
		var sourceRange: SourceRange {
			guard let first = lexicalUnits.first, let last = lexicalUnits.last else { preconditionFailure("No lexical units") }
			return first.sourceRange.lowerBound..<last.sourceRange.upperBound
		}
		
	}
	
	/// The known statement types.
	private static let statementTypes: [Statement.Type] = [
		CommandStatement.self,
		ValueStatement.self,
		AllocationStatement.self
	]
	
}
