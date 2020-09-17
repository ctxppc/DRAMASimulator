// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

struct MemoryView : View {
	
	/// The machine whose memory is presented.
	let machine: Machine
	
	@Environment(\.colorScheme)
	private var colourScheme
	
	// See protocol.
	var body: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
				ForEach(AddressWord.all, id: \.self) { address in
					MemoryCell(
						address:				address,
						contents:				machine.memory[address],
						previouslyExecuted:		machine.previousProgramCounter == address,
						subsequentlyExecuted:	machine.programCounter == address
					)
				}
			}
		}
	}
	
}

private struct MemoryCell : View {
	
	/// The memory location.
	let address: AddressWord
	
	/// The contents at the memory location.
	let contents: MachineWord
	
	/// A Boolean value indicating whether the program counter pointed previously at the location.
	let previouslyExecuted: Bool
	
	/// A Boolean value indicating whether the program counter is pointing at the location.
	let subsequentlyExecuted: Bool
	
	var body: some View {
		HStack {
			Text(address.rawValue as NSNumber, formatter: Self.addressFormatter)
				.foregroundColor(.secondary)
				.font(.system(.caption, design: .monospaced))
			Text(contents.rawValue as NSNumber, formatter: Self.wordFormatter)
				.font(.system(.body, design: .monospaced))
		}.padding(.horizontal)
		.background(background.transition(.opacity))
		.clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
	}
	
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
struct MemoryViewPreviews : PreviewProvider {
	static var previews: some View {
		ForEach(ColorScheme.allCases, id: \.self) { scheme in
			NavigationView {
				MemoryView(machine: Document(script: templateScript).machine)
			}.preferredColorScheme(scheme)
			.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}
#endif
