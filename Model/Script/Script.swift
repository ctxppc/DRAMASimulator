// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A source file processed into a processed text, parsed into lexical units, mapped to statements, and assembled to a program.
struct Script {
	
	/// Parses a script from given text.
	init(from sourceText: String = "") {
		
		self.sourceText = sourceText
		lexicalUnits = Script.units(in: sourceText)
		statements = lexicalUnits.compactMap { $0 as? _Statement }
		
		statementIndicesBySymbol = lexicalUnits.reduce(into: (indicesBySymbol: [Symbol : Int](), indexOfNextStatement: 0)) { state, unit in
			if unit is _Statement {
				state.indexOfNextStatement += 1
			} else if let label = unit as? _LabelLexicalUnit {
				state.indicesBySymbol[.init(sourceText[label.symbolRange])] = state.indexOfNextStatement
			}
		}.indicesBySymbol
		
		let sourceErrors = lexicalUnits.compactMap { $0 as? PartialLexicalUnit }
		
		if sourceErrors.isEmpty {
			do {
				product = .program(try Program(statements: statements, statementIndicesBySymbol: statementIndicesBySymbol))
			} catch let error as Program.StatementTranslationError {
				let rewrappedError = StatementTranslationError(underlyingError: error.underlyingError, sourceRange: statements[error.statementIndex].sourceRange)
				product = .sourceErrors([rewrappedError])
			} catch {
				product = .programError(error)
			}
		} else {
			product = .sourceErrors(sourceErrors)
		}
		
	}
	
	/// The script's source text.
	let sourceText: String
	
	/// The script's lexical units.
	let lexicalUnits: [_LexicalUnit]
	
	/// The script's statements.
	let statements: [_Statement]
	
	/// A dictionary mapping symbols to indices in the `statements` array.
	let statementIndicesBySymbol: [Symbol : Int]
	typealias Symbol = String
	
	/// The script's product, which may be a program if compilation is successful.
	let product: Product
	enum Product {
		
		/// A program could be assembled.
		case program(Program)
		
		/// A program couldn't be assembled due to source errors.
		case sourceErrors([SourceError])
		
		/// A program couldn't be assembled due to a non-source error.
		case programError(Error)
		
		/// Any errors in the programs.
		var errors: [Error] {
			switch self {
				case .program:					return []
				case .sourceErrors(let errors):	return errors
				case .programError(let error):	return [error]
			}
		}
		
	}
	
	/// Determines all lexical units in given source.
	private static func units(in source: String) -> [_LexicalUnit] {
		
		var units: [_LexicalUnit] = []
		
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
			if let match = _CommentLexicalUnit.regularExpression.firstMatch(in: source, range: fRange) {
				noncommentRange = range(in: match, at: 1)
				commentRange = range(in: match, at: 2)
			} else {
				noncommentRange = sRange
				commentRange = nil
			}
			
			let symbolLabelRange: (SourceRange, SourceRange)?
			let statementRange: SourceRange
			if let match = _LabelLexicalUnit.regularExpression.firstMatch(in: source, range: .init(noncommentRange, in: source)) {
				symbolLabelRange = (range(in: match, at: 2), range(in: match, at: 1))
				statementRange = range(in: match, at: 3)
			} else {
				symbolLabelRange = nil
				statementRange = noncommentRange
			}
			
			if let (symbolRange, labelRange) = symbolLabelRange {
				units.append(_LabelLexicalUnit(sourceRange: labelRange, symbolRange: symbolRange))
			}
			
			let lexicalUnitTypes: [_Statement.Type] = [
				NullaryCommandStatement.self,
				RegisterCommandStatement.self,
				AddressCommandStatement.self,
				ArrayStatement.self
			]
			
			if let lowerBound = source.rangeOfCharacter(from: nonwhitespaceSet, range: statementRange)?.lowerBound,
				let upperBound = source.rangeOfCharacter(from: nonwhitespaceSet, options: .backwards, range: statementRange)?.lowerBound {
				
				let trimmedStatementRange = lowerBound...upperBound
				let typeMatchPair = lexicalUnitTypes.lazy.compactMap { type -> (_Statement.Type, NSTextCheckingResult)? in
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
					units.append(PartialLexicalUnit(sourceRange: statementRange, error: error))
				}
				
			}
			
			if let range = commentRange {
				units.append(_CommentLexicalUnit(sourceRange: range))
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

extension Script : Equatable {
	static func == (first: Self, other: Self) -> Bool {
		first.sourceText == other.sourceText
	}
}
