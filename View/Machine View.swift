// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import DepthKit
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
	
	/// A Boolean value indicating whether memory contents are presented as if they're signed integers.
	@State
	private var signedValues = false
	
	// See protocol.
	var body: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumColumnWidth))]) {
				
				if !machine.ioMessages.isEmpty {
					Section(header: header("In- en uitvoer")) {
						ForEach(machine.ioMessages.indices, id: \.self) { index in
							cell(for: machine.ioMessages[index], index: index)
						}
					}
				}
				
				Section(header: header("Processor")) {
					
					ForEach(Register.all, id: \.self) { register in
						WordCell(
							label:			.register(register),
							contents:		machine[register: register],
							executing:		false,
							signedValue:	signedValues
						)
					}
					
					WordCell(
						label:			.programCounter,
						contents:		.init(machine.programCounter),
						executing:		false,
						signedValue:	signedValues
					)
					
					WordCell(
						label:			.conditionState,
						contents:		.init(wrapping: machine.conditionState.rawValue),
						executing:		false,
						signedValue:	signedValues
					)
					
				}
				
				Section(header: header("Geheugen")) {
					memoryWordCells(omitting: machine.memory.emptySpace)
				}
				
			}
		}.onTapGesture {
			signedValues.toggle()
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
	private func cell(for message: Machine.IOMessage, index: Int) -> some View {
		switch message {
			case .input(let contents):	WordCell(label: .input(index: index), contents: contents, executing: false, signedValue: signedValues)
			case .output(let contents):	WordCell(label: .output(index: index), contents: contents, executing: false, signedValue: signedValues)
		}
	}
	
	/// Returns words cells omitting given address space.
	@ViewBuilder
	private func memoryWordCells(omitting omittedAddressSpace: Range<Memory.Index>) -> some View {
		if omittedAddressSpace.count > 2 * numberOfAdditionalZeroWordsPresented {
			memoryWordCells(at: ..<omittedAddressSpace.lowerBound, leadsOut: true)
			memoryWordCells(at: omittedAddressSpace.upperBound..., leadsIn: true)
		} else {
			ForEach(machine.memory.indices, id: \.self) { index in
				cell(for: index)
			}
		}
	}
	
	/// The number of zero words presented after the last and before the first non-zero word.
	private var numberOfAdditionalZeroWordsPresented: Int { sizeClass == .compact ? 3 : 10 }
	
	/// Returns word cells for given memory locations, plus any overflow word cells.
	private func memoryWordCells<R : RangeExpression>(at range: R, leadsIn: Bool = false, leadsOut: Bool = false) -> some View where R.Bound == Memory.Index {
		
		let m = machine.memory
		let mainRange = range.relative(to: m)
		
		let leadInRange: Range<Memory.Index> = {
			let lowerBound = leadsIn
				? m.index(mainRange.lowerBound, offsetBy: -numberOfAdditionalZeroWordsPresented, limitedBy: m.startIndex) ?? m.startIndex
				: mainRange.lowerBound
			return lowerBound..<mainRange.lowerBound
		}()
		
		let leadOutRange: Range<Memory.Index> = {
			let upperBound = leadsOut
				? m.index(mainRange.upperBound, offsetBy: numberOfAdditionalZeroWordsPresented, limitedBy: m.endIndex) ?? m.endIndex
				: mainRange.upperBound
			return mainRange.upperBound..<upperBound
		}()
		
		return Group {
			ForEach(leadInRange, id: \.self) { index in
				cell(for: index)
					.opacity(normalisedDistance(of: index, to: leadInRange.lowerBound, range: leadInRange.count))
			}
			ForEach(mainRange, id: \.self) { index in
				cell(for: index)
			}
			ForEach(leadOutRange, id: \.self) { index in
				cell(for: index)
					.opacity(normalisedDistance(of: index, to: leadOutRange.upperBound, range: leadOutRange.count))
			}
		}
		
	}
	
	/// Returns a word cell for given memory location.
	private func cell(for index: Memory.Index) -> some View {
		let address = index.address !! "Index out of bounds"
		return WordCell(
			label:			.address(address),
			contents:		machine.memory[address],
			executing:		machine.programCounter == address,
			signedValue:	signedValues
		)
	}
	
	/// Returns the distance of two values, normalised to a given range.
	///
	/// - Returns: The distance between `firstValue` and `otherValue`, normalised to `range`.
	private func normalisedDistance<Value : Strideable>(of firstValue: Value, to otherValue: Value, range: Int) -> Double where Value.Stride == Int {
		Double(abs(firstValue.distance(to: otherValue))) / Double(range)
	}
	
}

private struct WordCell : View {
	
	/// The memory location.
	let label: Label
	enum Label {
		case input(index: Int)
		case output(index: Int)
		case programCounter
		case conditionState
		case register(Register)
		case address(AddressWord)
	}
	
	/// The contents at the memory location.
	let contents: MachineWord
	
	/// A Boolean value indicating whether the program counter is pointing at the location.
	let executing: Bool
	
	/// Whether the contents are presented as a signed value.
	let signedValue: Bool
	
	var body: some View {
		HStack {
			locationLabel
				.foregroundColor(.secondary)
				.font(.system(.caption, design: .monospaced))
			Text(value as NSNumber, formatter: valueFormatter)
				.font(.system(.body, design: .monospaced))
				.foregroundColor(valueColour)
		}.padding(.horizontal)
		.background((executing ? Self.executingColour : .clear).transition(.opacity))
		.clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
	}
	
	@ViewBuilder
	private var locationLabel: some View {
		switch label {
			case .input(let index):		Text("In \(index + 1)")
			case .output(let index):	Text("Uit \(index + 1)")
			case .programCounter:		Text("BT")
			case .conditionState:		Text("CT")
			case .register(let reg):	Text("R\(reg.rawValue)")
			case .address(let address):	Text(address.rawValue as NSNumber, formatter: Self.addressFormatter)
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
	
	/// The word value being presented.
	private var value: Int {
		signedValue ? contents.signedValue : contents.unsignedValue
	}
	
	/// The formatter for the value.
	private var valueFormatter: NumberFormatter {
		signedValue ? Self.signedValueFormatter : Self.unsignedValueFormatter
	}
	
	/// The formatter used to format unsigned values.
	private static let unsignedValueFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formattingContext = .standalone
		formatter.minimumIntegerDigits = 10
		formatter.maximumIntegerDigits = 10
		return formatter
	}()
	
	/// The formatter used to format unsigned values.
	private static let signedValueFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formattingContext = .standalone
		formatter.minimumIntegerDigits = 10
		formatter.maximumIntegerDigits = 10
		formatter.positivePrefix = "+"
		return formatter
	}()
	
	/// The colour of the presented value.
	private var valueColour: Color {
		if contents == .zero {
			return .secondary
		} else if case .conditionState = label {
			return ConditionState(rawValue: contents.unsignedValue) == .positive ? .blue : .red
		} else {
			return .primary
		}
	}
	
	/// The colour used to mark cells being executed subsequently.
	private static let executingColour = Color("Executing")
	
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
