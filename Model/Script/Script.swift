// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A source file parsed into lexical units, mapped to statements, and assembled to a program.
struct Script {
	
	/// Parses a script from given text.
	init(from sourceText: String = "") {
		
		storedSourceText = sourceText
		lexicalUnits = Script.units(in: sourceText)
		statements = lexicalUnits.compactMap { $0 as? Statement }
		
		struct ReductionState {
			var indicesBySymbol = [Symbol : Int]()
			var indexOfNextStatement = 0
		}
		
		statementIndicesBySymbol = lexicalUnits.reduce(into: ReductionState()) { (state, unit) in
			if unit is Statement {
				state.indexOfNextStatement += 1
			} else if let label = unit as? LabelLexicalUnit {
				state.indicesBySymbol[.init(sourceText[label.symbolRange])] = state.indexOfNextStatement
			}
		}.indicesBySymbol
		
		let sourceErrors = lexicalUnits.compactMap {
			($0 as? PartialLexicalUnit)?.error as? SourceError
		}
		
		if sourceErrors.isEmpty {
			do {
				program = .program(try Program(statements: statements, statementIndicesBySymbol: statementIndicesBySymbol))
			} catch let error as Program.StatementTranslationError {
				let rewrappedError = StatementTranslationError(underlyingError: error.underlyingError, sourceRange: statements[error.statementIndex].fullSourceRange)
				program = .sourceErrors([rewrappedError])
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
		
		/// A program couldn't be assembled due to a non-source error.
		case programError(Error)
		
	}
	
	/// Determines all lexical units in given source.
	private static func units(in source: String) -> [LexicalUnit] {
		
		var units: [LexicalUnit] = []
		
		source.enumerateSubstrings(in: source.startIndex..<source.endIndex, options: [.byLines, .substringNotRequired]) { _, sRange, _, stop in
			
			if source[sRange].contains("EINDPR") {
				stop = true
				return
			}
			
			let fRange = NSRange(sRange, in: source)
			func range(in match: NSTextCheckingResult, at group: Int) -> SourceRange {
				return SourceRange(match.range(at: group), in: source)!
			}
			
			let noncommentRange: SourceRange
			let commentRange: SourceRange?
			if let match = CommentLexicalUnit.regularExpression.firstMatch(in: source, range: fRange) {
				noncommentRange = range(in: match, at: 1)
				commentRange = range(in: match, at: 2)
			} else {
				noncommentRange = sRange
				commentRange = nil
			}
			
			let symbolLabelRange: (SourceRange, SourceRange)?
			let statementRange: SourceRange
			if let match = LabelLexicalUnit.regularExpression.firstMatch(in: source, range: .init(noncommentRange, in: source)) {
				symbolLabelRange = (range(in: match, at: 2), range(in: match, at: 1))
				statementRange = range(in: match, at: 3)
			} else {
				symbolLabelRange = nil
				statementRange = noncommentRange
			}
			
			if let (symbolRange, labelRange) = symbolLabelRange {
				units.append(LabelLexicalUnit(fullSourceRange: labelRange, symbolRange: symbolRange))
			}
			
			let lexicalUnitTypes: [Statement.Type] = [
				NullaryCommandStatement.self,
				RegisterCommandStatement.self,
				AddressCommandStatement.self,
				ArrayStatement.self
			]
			
			if let lowerBound = source.rangeOfCharacter(from: nonwhitespaceSet, range: statementRange)?.lowerBound,
				let upperBound = source.rangeOfCharacter(from: nonwhitespaceSet, options: .backwards, range: statementRange)?.lowerBound {
				
				let trimmedStatementRange = lowerBound...upperBound
				let typeMatchPair = lexicalUnitTypes.lazy.compactMap { type -> (Statement.Type, NSTextCheckingResult)? in
					guard let match = type.regularExpression.firstMatch(in: source, range: NSRange(trimmedStatementRange, in: source)) else { return nil }
					return (type, match)
				}.first
				
				do {
					if let (type, match) = typeMatchPair {
						units.append(try type.init(match: match, in: source))
					} else {
						throw ParsingError.illegalFormat(range: statementRange)
					}
				} catch {
					units.append(PartialLexicalUnit(fullSourceRange: statementRange, error: error))
				}
				
			}
			
			if let range = commentRange {
				units.append(CommentLexicalUnit(fullSourceRange: range))
			}
			
		}
		
		return units
		
	}
	
	/// A character set containing all characters except whitespaces.
	private static let nonwhitespaceSet = CharacterSet.whitespaces.inverted
	
	enum ParsingError : LocalizedError, SourceError {
		
		/// A statement has an illegal format.
		case illegalFormat(range: SourceRange)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .illegalFormat:	return "Lijn met ongeldig formaat"
			}
		}
		
		// See protocol.
		var sourceRange: SourceRange {
			switch self {
				case .illegalFormat(range: let range):	return range
			}
		}
		
	}
	
	/// An error that occured while translating a statement into words.
	struct StatementTranslationError : SourceError, LocalizedError {
		
		/// The error that occurred while translating the statement.
		let underlyingError: Error
		
		// See protocol.
		let sourceRange: SourceRange
		
		// See protocol.
		var errorDescription: String? {
			return (underlyingError as? LocalizedError)?.errorDescription
		}
		
	}
	
}
