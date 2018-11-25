// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

struct SyntaxMap {
	
	/// Ranges in the source text that contain mnemonics.
	var mnemonicRanges: [Script.SourceRange] = []
	
	/// Ranges in the source text that contain addressing modes.
	var addressingModeRanges: [Script.SourceRange] = []
	
	/// Ranges in the source text that contain register operands.
	var registerOperandRanges: [Script.SourceRange] = []
	
	/// Ranges in the source text that contain base addresses.
	var baseAddressRanges: [Script.SourceRange] = []
	
	/// Ranges in the source text that contain address indices.
	var addressIndexRanges: [Script.SourceRange] = []
	
	/// Ranges in the source text that contain comments.
	var commentRanges: [Script.SourceRange] = []
	
	mutating func combine(with map: SyntaxMap) {
		mnemonicRanges			.append(contentsOf: map.mnemonicRanges)
		addressingModeRanges	.append(contentsOf: map.addressingModeRanges)
		registerOperandRanges	.append(contentsOf: map.registerOperandRanges)
		addressIndexRanges		.append(contentsOf: map.addressIndexRanges)
		baseAddressRanges		.append(contentsOf: map.baseAddressRanges)
		commentRanges			.append(contentsOf: map.commentRanges)
	}
	
}

extension SyntaxMap {
	
	init(
		from match:				NSTextCheckingResult,
		searchString:			String,
		mnemnonicGroup:			Int?		= nil,
		addressingModeGroup:	Int?		= nil,
		registerOperandGroup:	Int?		= nil,
		baseAddressGroup:		Int?		= nil,
		addressIndexGroups:		Range<Int>?	= nil,
		commentGroup:			Int?		= nil
	) {
		
		func ranges(in group: Int?) -> [Script.SourceRange] {
			guard let group = group else { return [] }
			return [Range(match.range(at: group), in: searchString)!]
		}
		
		mnemonicRanges = ranges(in: mnemnonicGroup)
		addressingModeRanges = ranges(in: addressingModeGroup)
		registerOperandRanges = ranges(in: registerOperandGroup)
		baseAddressRanges = ranges(in: baseAddressGroup)
		commentRanges = ranges(in: commentGroup)
		
		if let groups = addressIndexGroups {
			addressIndexRanges = [Range(match.range(at: groups[0]), in: searchString)!.lowerBound..<Range(match.range(at: groups[2]), in: searchString)!.upperBound]
		} else {
			addressIndexRanges = []
		}
		
	}
	
	
}
