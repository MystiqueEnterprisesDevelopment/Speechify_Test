import SwiftUI

struct PaymentModalView : View {
  @StateObject var viewModel: PaymentSelectorViewModel
  
  var body: some View {
    NavigationView {
      PaymentInfoView(viewModel: viewModel)
    }
  }
}

struct PaymentInfoView: View {
  @StateObject var viewModel: PaymentSelectorViewModel
  
  var body: some View {
    switch viewModel.viewState {
    case .Loading:
      LoadingView()
    case .DisplayPaymentOptions:
      PaymentSelector()
    }
  }
  
  @ViewBuilder
  private func LoadingView() -> some View {
    VStack(content: {
      Spacer()
      HStack(alignment: .center, content: {
        Text("Loading Payment options...")
        ProgressView()
      })
      Spacer()
    })
  }
  
  @ViewBuilder
  private func PaymentSelector() -> some View {
    VStack(content: {
      HStack(content: {
        TextField("Search payment methods", text: $viewModel.searchString)
          .foregroundStyle(Color(UIColor.label))
        Image(systemName: "magnifyingglass")
          .frame(width: 30, height: 30)
      }).padding()
      List(viewModel.displayedPaymentOptions, rowContent: { option in
        PaymentOptionItem(option)
      })
      .navigationTitle("Payment info")
      .navigationBarItems(trailing: Button( viewModel.hasSelectedPayment() ? "Done":"Cancel", action: {
        viewModel.dismissSelector(true)
      }))
      .refreshable {
        viewModel.refreshList()
      }
    })
  }
  
  @ViewBuilder
  private func PaymentOptionItem(_ option: PaymentOptionModel) -> some View {
    HStack(alignment: .center, content: {
      Text(option.option)
        .font(.headline)
        .foregroundStyle(Color(UIColor.label))
      Spacer()
      if let selected = viewModel.selectedPayment, selected.option == option.option {
        Image(systemName: "checkmark.circle")
          .resizable()
          .frame(width: 30, height: 30)
          .font(.headline)
          .foregroundStyle(Color(UIColor.label))
      }
    })
    .onTapGesture {
      viewModel.selectPaymentOption(option)
    }
    .background(
      Rectangle()
        .foregroundStyle(Color(UIColor.clear))
        .background(Color(UIColor.clear))
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture {
          viewModel.selectPaymentOption(option)
        }
    )
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
