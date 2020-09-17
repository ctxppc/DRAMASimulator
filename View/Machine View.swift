// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

/// A view presenting a machine.
struct MachineView : View {
	
	/// The machine being presented.
	let machine: Machine
	
	/// The active colour scheme.
	@Environment(\.colorScheme)
	private var colourScheme
	
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
					ForEach(AddressWord.all, id: \.self) { address in
						WordCell(
							location:				.memory(address),
							contents:				machine.memory[address],
							previouslyExecuted:		machine.previousProgramCounter == address,
							subsequentlyExecuted:	machine.programCounter == address
						)
					}
				}
				
			}
		}
	}
	
	/// Returns a header with given text.
	private func header(_ text: LocalizedStringKey) -> some View {
		Text(text)
			.font(.headline)
			.foregroundColor(.secondary)
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
