// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A sequence of statements and labels that represent a program.
struct TranslationUnit : Construct {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		
		func parseNextElement() throws -> Element? {
			
			guard parser.hasUnprocessedLexicalUnits else { return nil }
			
			do {
				return .statement(try parser.parse(CommandStatement.self))
			} catch {
				TODO.unimplemented
			}
			
		}
		
		var elements: [Element] = []
		while let element = try parseNextElement() {
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
		case unrecognisedSource(UnrecognisedLexicalUnit)
	}
	
	/// The known statement types.
	private static let statementTypes: [Statement.Type] = [
		CommandStatement.self,
		ValueStatement.self,
		AllocationStatement.self
	]
	
}
