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
				ForEach(0..<AddressWord.unsignedUpperBound) { address in
					HStack {
						Text(address as NSNumber, formatter: Self.addressFormatter)
							.foregroundColor(.secondary)
							.font(.system(.caption, design: .monospaced))
						Text(machine[address: .init(wrapping: address)].rawValue as NSNumber, formatter: Self.wordFormatter)
							.font(.system(.body, design: .monospaced))
					}.padding(3)
					.border(Color.black)
				}
			}
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
}

#if DEBUG
struct MemoryViewPreviews : PreviewProvider {
	static var previews: some View {
		ForEach(ColorScheme.allCases, id: \.self) { scheme in
			NavigationView {
				MemoryView(machine: templateMachine)
			}.preferredColorScheme(scheme)
			.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}
#endif
