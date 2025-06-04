/*
 * Copyright (c) 2024 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SwiftUI

class PollViewModel: ObservableObject {
    @Published var completed: Bool = false
    @Published var savingMode: Bool = false
    @Published var vote: Int = -1
    @Published var results: PollResults? = nil
    
    public func loadUserInput(userInput: UserInputPoll) {
        self.completed = userInput.vote >= 0
        self.vote = userInput.vote
    }

    public func receiveVote(vote: Int) {
        self.savingMode = true
        self.completed = true
        self.vote = vote
    }
    
    public func getResultForIndex(index: Int) -> PollResult? {
        guard let results = results else {
            return nil
        }
        
        return results.results.first(where: { $0.index == index }) ?? PollResult(index: index, percentage: 0, count: 0)
    }
}

struct BlockPollItemView: View {
    var block: PollItem
    @EnvironmentObject var pollViewModel: PollViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: {
            if !pollViewModel.completed {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                pollViewModel.receiveVote(vote: block.index)
            }
        }) {
            VStack {
                HStack {
                    InlineAttributedText(block: AnyBlock(block), markdown: block.markdown).frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    if let result = pollViewModel.getResultForIndex(index: block.index) {
                        InlineAttributedText(block: AnyBlock(block), markdown: "\(result.percentage)%")
                    }
                }.frame(alignment: .leading)
                
                if let result = pollViewModel.getResultForIndex(index: block.index) {
                    GeometryReader { geometry in
                        ZStack (alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(width: geometry.size.width, height: 10)
                                .cornerRadius(6)
                            Rectangle()
                                .foregroundColor(AppStyle.Block.Poll.resultBarColor(block.index == pollViewModel.vote))
                                .frame(width: geometry.size.width * CGFloat(result.percentage) / 100, height: 10)
                                .cornerRadius(6)
                        }
                    }.frame(height: 10)
                    
                }
            }
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppStyle.Block.Poll.borderColor(), lineWidth: 2)
            )
            .cornerRadius(6)
        }
    }
}

struct BlockPollView: StyledBlock, InteractiveBlock, View {
    var block: Poll
    
    @Environment(\.defaultBlockStyles) var defaultStyles: Style
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var viewModel: DocumentViewModel
    @StateObject var pollViewModel: PollViewModel = PollViewModel()
    
    @State var checked = false
    
    var body: some View {
        VStack(spacing: 20){
            Image(systemName: "chart.pie.fill")
                .foregroundColor(themeManager.getSecondaryTextColor())
            
            Text(AppStyle.Block.text(block.caption, defaultStyles, AnyBlock(block), AppealStyleTemplate()))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            VStack {
                ForEach(block.items) { pollItem in
                    BlockPollItemView(block: pollItem).environmentObject(pollViewModel)
                }
            }
        }
        .padding(20)
        .background(themeManager.getSecondaryBackgroundColor())
        .cornerRadius(6)
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear {
            loadInputData()
        }.onChange(of: viewModel.documentUserInput) { newValue in
            loadInputData()
        }.onChange(of: pollViewModel.vote) { vote in
            Task {
                await viewModel.retrievePollData(pollId: block.id) { pollResults in
                    if let pollResults = pollResults {
                        pollViewModel.results = pollResults
                    }
                }
            }
            
            if !pollViewModel.savingMode { return }
            
            saveUserInput(AnyUserInput(UserInputPoll(blockId: block.id, inputType: .poll, vote: vote, timestamp: Int(Date().timeIntervalSince1970))))
        }
    }
    
    internal func loadInputData() {
        if let userInput = getUserInputForBlock(blockId: block.id, userInput: nil)?.asType(UserInputPoll.self) {
            pollViewModel.loadUserInput(userInput: userInput)
        }
    }
}

#Preview {
    BlockPollView(block:
        Poll(
            id: "poll_id",
            type: .poll,
            style: BlockStyle(block: nil, wrapper: nil, image: nil, text: nil),
            caption: "Share your opinion regarding the matter",
            items: [
                PollItem(
                    id: "poll_item_id_1",
                    type: .pollItem,
                    style: BlockStyle(block: nil, wrapper: nil, image: nil, text: nil),
                    index: 0,
                    markdown: "Poll option # 1",
                    data: nil,
                    nested: true),
                PollItem(
                    id: "poll_item_id_2",
                    type: .pollItem,
                    style: BlockStyle(block: nil, wrapper: nil, image: nil, text: nil),
                    index: 2,
                    markdown: "Poll option # 2 fdsa fjdksla jfkdsajk fldsajkl fdjsakl fjkldsajkl fdsa fdsa fdsa fdsa fdsa",
                    data: nil,
                    nested: true)
            ],
            data: nil,
            nested: false
        )
    )
    .environmentObject(ThemeManager())
    .environmentObject(DocumentViewModel())
}
