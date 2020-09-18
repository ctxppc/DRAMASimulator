// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

/// A view presenting a machine.
struct MachineView : View {
	
	/// The machine being presented.
	let machine: Machine
	
	/// The active colour scheme.
	@Environment(\.colorScheme)
	private var colourScheme
	
	/// The active colour scheme.
	@Environment(\.horizontalSizeClass)
	private var sizeClass
	
	/// The minimum width of the grid's columns.
	@ScaledMetric
	private var minimumColumnWidth: CGFloat = 180
	
	// See protocol.
	var body: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumColumnWidth))]) {
				
				Section(header: header("Processor")) {
					
					ForEach(Register.all, id: \.self) { register in
						WordCell(
							location:				.register(register),
							contents:				machine[register: register],
							previouslyExecuted:		false,
							subsequentlyExecuted:	false
						)
					}
					
					WordCell(
						location:				.programCounter,
						contents:				.init(machine.programCounter),
						previouslyExecuted:		false,
						subsequentlyExecuted:	false
					)
					
					WordCell(
						location:				.conditionState,
						contents:				.init(wrapping: machine.conditionState.rawValue),
						previouslyExecuted:		false,
						subsequentlyExecuted:	false
					)
					
				}
				
				Section(header: header("Geheugen")) {
					memoryWordCells(omitting: machine.memory.highestLowAddress()..<machine.memory.lowestHighAddress())
				}
				
			}
		}
	}
	
	/// Returns a header with given text.
	private func header(_ text: LocalizedStringKey) -> some View {
		Text(text)
			.font(.headline)
			.foregroundColor(.secondary)
			.padding(.top)
			.padding(.bottom, 4)
	}
	
	/// Returns words cells omitting given address space.
	@ViewBuilder
	private func memoryWordCells(omitting omittedAddressSpace: Range<AddressWord>) -> some View {
		if omittedAddressSpace.count > 2 * numberOfAdditionalZeroWordsPresented {
			memoryWordCells(at: ..<omittedAddressSpace.lowerBound)
			memoryWordCells(at: omittedAddressSpace.upperBound...)
		} else {
			ForEach(AddressWord.all, id: \.self) { address in
				memoryWordCell(at: address)
			}
		}
	}
	
	/// The number of zero words presented after the last and before the first non-zero word.
	private var numberOfAdditionalZeroWordsPresented: Int { sizeClass == .compact ? 10 : 50 }
	
	/// Returns word cells for given memory locations, plus any overflow word cells.
	private func memoryWordCells(at range: PartialRangeUpTo<AddressWord>) -> some View {
		let m = machine.memory
		let overflowRange = range.upperBound..<(m.index(range.upperBound, offsetBy: numberOfAdditionalZeroWordsPresented, limitedBy: m.endIndex) ?? m.endIndex)
		return Group {
			ForEach(range.relative(to: m), id: \.self) { address in
				memoryWordCell(at: address)
			}
			ForEach(overflowRange, id: \.self) { address in
				memoryWordCell(at: address)
					.opacity(opacity(for: address, overflowRange: overflowRange, ascending: false))
			}
		}
	}
	
	/// Returns word cells for given memory locations, plus any overflow word cells.
	private func memoryWordCells(at range: PartialRangeFrom<AddressWord>) -> some View {
		let m = machine.memory
		let overflowRange = (m.index(range.lowerBound, offsetBy: -numberOfAdditionalZeroWordsPresented, limitedBy: m.startIndex) ?? m.startIndex)..<range.lowerBound
		return Group {
			ForEach(overflowRange, id: \.self) { address in
				memoryWordCell(at: address)
					.opacity(opacity(for: address, overflowRange: overflowRange, ascending: true))
			}
			ForEach(range.relative(to: m), id: \.self) { address in
				memoryWordCell(at: address)
			}
		}
	}
	
	/// Returns the opacity for the cell at given address.
	private func opacity(for address: AddressWord, overflowRange: Range<AddressWord>, ascending: Bool) -> Double {
		let ascendingValue = Double(address.rawValue - overflowRange.lowerBound.rawValue) / Double(overflowRange.upperBound.rawValue - overflowRange.lowerBound.rawValue)
		return ascending ? ascendingValue : 1 - ascendingValue
	}
	
	/// Returns a word cell for given memory location.
	@ViewBuilder
	private func memoryWordCell(at address: AddressWord) -> some View {
		WordCell(
			location:				.memory(address),
			contents:				machine.memory[address],
			previouslyExecuted:		machine.previousProgramCounter == address,
			subsequentlyExecuted:	machine.programCounter == address
		)
	}
	
}

private struct WordCell : View {
	
	/// The memory location.
	let location: Location
	enum Location {
		case programCounter
		case conditionState
		case register(Register)
		case memory(AddressWord)
	}
	
	/// The contents at the memory location.
	let contents: MachineWord
	
	/// A Boolean value indicating whether the program counter pointed previously at the location.
	let previouslyExecuted: Bool
	
	/// A Boolean value indicating whether the program counter is pointing at the location.
	let subsequentlyExecuted: Bool
	
	var body: some View {
		HStack {
			locationLabel
				.foregroundColor(.secondary)
				.font(.system(.caption, design: .monospaced))
			Text(contents.rawValue as NSNumber, formatter: Self.wordFormatter)
				.font(.system(.body, design: .monospaced))
		}.padding(.horizontal)
		.background(background.transition(.opacity))
		.clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
	}
	
	@ViewBuilder
	private var locationLabel: some View {
		switch location {
			case .programCounter:		Text("BT")
			case .conditionState:		Text("CT")
			case .register(let reg):	Text("R\(reg.rawValue)")
			case .memory(let address):	Text(address.rawValue as NSNumber, formatter: Self.addressFormatter)
		}
	}
	
	/// The cell background.
	@ViewBuilder
	private var background: some View {
		if subsequentlyExecuted {
			Self.executingColour
		} else if previouslyExecuted {
			Self.executedColour
		}
	}
	
	/// The formatter used to format addresses.
	private static let addressFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formattingContext = .standalone
		formatter.minimumIntegerDigits = 4
		formatter.maximumIntegerDigits = 4
		return formatter
	}()
	
	/// The formatter used to format machine words.
	private static let wordFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formattingContext = .standalone
		formatter.minimumIntegerDigits = 10
		formatter.maximumIntegerDigits = 10
		return formatter
	}()
	
	/// The colour used to mark cells being executed subsequently.
	private static let executingColour = Color("Executing")
	
	/// The colour used to mark cells being executed previously.
	private static let executedColour = Color("Executed")
	
}

#if DEBUG
struct MachineViewPreviews : PreviewProvider {
	static var previews: some View {
		ForEach(ColorScheme.allCases, id: \.self) { scheme in
			NavigationView {
				MachineView(machine: Document(script: templateScript).machine)
			}.navigationViewStyle(StackNavigationViewStyle())
			.preferredColorScheme(scheme)
		}
	}
}
#endif
