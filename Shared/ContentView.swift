import SwiftUI
import Combine

enum CountdownScreenState {
  case Finished
  case Countdown
}

struct PaymentOptionModel: Identifiable {
  let option: String
  let id = UUID().hashValue
  let searchableString: String
  
  init(option: String) {
    self.option = option
    self.searchableString = option.lowercased()
  }
}

struct ContentView: View {
  @StateObject var viewModel: CountdownScreenViewModel
  
  var body: some View {
    
    switch viewModel.viewState {
    case .Finished:
      FinishView(title: viewModel.hasTimeLeft() ? "Congratulations" : "Uh oh, the countdown expired :( ")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    case .Countdown:
      CountdownScreen()
    }
  }
  
  @ViewBuilder
  private func CountdownScreen() -> some View {
    VStack {
      Spacer()
      Text("You have only \(viewModel.countdown) seconds left to get the discount")
        .font(.largeTitle)
        .foregroundStyle(Color.white)
      Spacer()
      Buttons
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .sheet(isPresented: $viewModel.showPaymentSelector, content: {
      PaymentModalView(viewModel: viewModel.providePaymentSelectorViewModel())
    })
    .background(
      Color.blue
    )
  }
  
  @ViewBuilder var Buttons: some View {
    VStack(alignment: .center, spacing: 0.0, content: {
      Button("Open payment", action: {
        viewModel.showPaymentInfo(true)
      })
      .foregroundStyle(Color.blue)
      .font(.headline)
      .frame(maxWidth: .infinity, maxHeight: 50.0)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 10.0, style: .continuous)
          .foregroundStyle(Color.white)
          .frame(maxWidth: .infinity, maxHeight: 50.0)
          .padding()
          .onTapGesture {
            viewModel.showPaymentInfo(true)
          }
      )
      
      if viewModel.selectedPayment != nil {
        Button("Finish", action: {
          viewModel.completePayment()
        })
        .foregroundStyle(Color.blue)
        .font(.headline)
        .frame(maxWidth: .infinity, maxHeight: 50.0)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 10.0, style: .continuous)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, maxHeight: 50.0)
            .padding()
            .onTapGesture {
              viewModel.completePayment()
            }
        )
      }
    })
    .frame(maxWidth: .infinity, alignment: .bottom)
  }
}
