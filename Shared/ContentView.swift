// Your task is to finish this application to satisfy requirements below and make it look like on the attached screenshots. Try to use 80/20 principle.
// Good luck! 🍀

// 1. Setup UI of the ContentView. Try to keep it as similar as possible.
// 2. Subscribe to the timer and count seconds down from 60 to 0 on the ContentView.
// 3. Present PaymentModalView as a sheet after tapping on the "Open payment" button.
// 4. Load payment types from repository in PaymentInfoView. Show loader when waiting for the response. No need to handle error.
// 5. List should be refreshable.
// 6. Show search bar for the list to filter payment types. You can filter items in any way.
// 7. User should select one of the types on the list. Show checkmark next to the name when item is selected.
// 8. Show "Done" button in navigation bar only if payment type is selected. Tapping this button should hide the modal.
// 9. Show "Finish" button on ContentScreen only when "payment type" was selected.
// 10. Replace main view with "FinishView" when user taps on the "Finish" button.

import SwiftUI
import Combine

struct PaymentOptionModel: Identifiable {
  let option: String
  let id = UUID().hashValue
  let searchableString: String
  
  init(option: String) {
    self.option = option
    self.searchableString = option.lowercased()
  }
}

class Model: ObservableObject {
  let processDurationInSeconds: Int = 60
  var repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()
  var cancellables: [AnyCancellable] = []
  
  @Published var showPaymentSelector: Bool = false
  @Published var selectedPayment: PaymentOptionModel?
  @Published var countdown: Int
  @Published var paymentOptions: [PaymentOptionModel] = []
  @Published var isLoadingOptions: Bool = false
  @Published var hasCompletedPaymentSelection = false
  @Published var searchString: String = "" {
    didSet {
      filterOptions()
      
    }
  }
  
  private var allPaymentOptions:[PaymentOptionModel] = []
  
  private var timer: Timer?
  
  init() {
    countdown = processDurationInSeconds
    self.startTimer()
  }
  
  func startTimer() {
    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
      DispatchQueue.main.async {
        self?.countdown -= 1
        if let countdown = self?.countdown, countdown <= 0 {
          self?.timer?.invalidate()
        }
      }
    })
  }
  
  func showPaymentInfo(_ show: Bool) {
    self.showPaymentSelector = show
  }
  
  func refreshList() {
    guard !isLoadingOptions else {
      return
    }
    
    self.loadPaymentOptions()
  }
  
  func loadPaymentOptions() {
    guard !isLoadingOptions else {
      return
    }
    
    updateLoadingState(isLoading: true)
    
    repository.getTypes { [weak self] result in
      switch result {
      case .success(let options):
        self?.updatePaymentOptions(options)
        self?.updateLoadingState(isLoading: false)
      case .failure(let err):
        print(err.localizedDescription)
        self?.updateLoadingState(isLoading: false)
      }
    }
  }
  
  func updateLoadingState(isLoading: Bool) {
    DispatchQueue.main.async {
      self.isLoadingOptions = isLoading
    }
  }
  
  func updatePaymentOptions(_ options: [PaymentType]) {
    DispatchQueue.main.async {
      self.allPaymentOptions = options.map({ payment in
        return PaymentOptionModel(option: payment.name)
      })
      
      self.paymentOptions = options.map({ payment in
        return PaymentOptionModel(option: payment.name)
      })
      
      self.filterOptions()
    }
  }
  
  func filterOptions() {
    DispatchQueue.main.async {
      if !self.searchString.isEmpty {
        let search = self.searchString.lowercased()
        let regex = NSRegularExpression.escapedPattern(for: search)
        
        self.paymentOptions = self.allPaymentOptions.filter({ model in
          return model.searchableString.contains(regex)
        })
        
      } else {
        self.paymentOptions = self.allPaymentOptions
      }
      
    }
  }
  
  func selectPaymentOption(_ option: PaymentOptionModel) {
    if self.selectedPayment == nil {
      self.selectedPayment = option
    }  else {
      self.selectedPayment = nil
    }
  }
  
  func completePayment() {
    self.hasCompletedPaymentSelection = true
    self.timer?.invalidate()
  }
  
  func hasTimeLeft() -> Bool {
    return self.countdown > 0
  }
  
  func hasPaymentOptions() -> Bool {
    return !allPaymentOptions.isEmpty
  }
}

struct ContentView: View {
  @ObservedObject var viewModel: Model
  
  var body: some View {
    
    if viewModel.hasCompletedPaymentSelection {
      FinishView(title: viewModel.hasTimeLeft() ? "Congratulations" : "Uh oh, the countdown expired :( ")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      VStack {
        // Seconds should count down from 60 to 0
        Spacer()
        Text("You have only \(viewModel.countdown) seconds left to get the discount")
          .font(.title)
          .foregroundStyle(Color.white)
        Spacer()
        Buttons
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      .sheet(isPresented: $viewModel.showPaymentSelector, content: {
        PaymentModalView(viewModel: viewModel)
      })
      .background(
        Color.blue
      )
    }
    
  }
  
  @ViewBuilder var Buttons: some View {
    VStack(alignment: .center, spacing: 8.0, content: {
      Button("Open payment", action: {
        viewModel.showPaymentInfo(true)
      })
      .foregroundStyle(Color.blue)
      .font(.body)
      .frame(maxWidth: .infinity, maxHeight: 50.0)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 10.0, style: .continuous)
          .foregroundStyle(Color.white)
          .frame(maxWidth: .infinity, maxHeight: 50.0)
          .padding()
      )
      
      // Visible only if payment type is selected
      if viewModel.selectedPayment != nil {
        Button("Finish", action: {
          viewModel.completePayment()
        })
        .foregroundStyle(Color.blue)
        .frame(maxWidth: .infinity, maxHeight: 50.0)
        .padding()
        .background(
          RoundedRectangle(cornerRadius: 10.0, style: .continuous)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, maxHeight: 50.0)
            .padding()
        )
      }
    })
    .frame(maxWidth: .infinity, alignment: .bottom)
  }
}

struct FinishView: View {
  @State var title: String
  
  var body: some View {
    VStack(content: {
      Spacer()
      
      Text(title)
        .font(.title)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      
      
      Spacer()
    })
    .background(Color.blue)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
  }
}

struct PaymentModalView : View {
  @ObservedObject var viewModel: Model
  
  var body: some View {
    NavigationView {
      PaymentInfoView(viewModel: viewModel)
    }
  }
}

struct PaymentInfoView: View {
  @ObservedObject var viewModel: Model
  
  var body: some View {
    // Load payment types when presenting the view. Repository has 2 seconds delay.
    // User should select an item.
    // Show checkmark in a selected row.
    //
    // No need to handle error.
    // Use refreshing mechanism to reload the list items.
    // Show loader before response comes.
    // Show search bar to filter payment types
    //
    // Finish button should be only available if user selected payment type.
    // Tapping on Finish button should close the modal.
    
    VStack(content: {
    
      if viewModel.isLoadingOptions {
        Spacer()
        HStack(alignment: .center, content: {
          Text("Loading Payment options...")
          ProgressView()
        })
        Spacer()
      } else {
        HStack(content: {
          TextField("Search payment methods", text: $viewModel.searchString)
          Image(systemName: "magnifyingglass")
            .frame(width: 30, height: 30)
        }).padding()
        
        List(viewModel.paymentOptions, rowContent: { option in
          PaymentOptionItem(option)
            .onTapGesture {
              viewModel.selectPaymentOption(option)
            }
        })
        .navigationTitle("Payment info")
        .navigationBarItems(trailing: Button("Done", action: {
          viewModel.showPaymentInfo(false)
        }))
        .refreshable {
          guard !viewModel.hasPaymentOptions() else {
            return
          }
          viewModel.refreshList()
        }
      }
    })
    
    .onAppear(perform: {
      guard !viewModel.hasPaymentOptions() else {
        return
      }
      viewModel.loadPaymentOptions()
    })
    
    
  }
  
  @ViewBuilder func PaymentOptionItem(_ option: PaymentOptionModel) -> some View {
    HStack(alignment: .center, content: {
      Text(option.option)
      Spacer()
      if let selected = viewModel.selectedPayment, selected.option == option.option {
        Image(systemName: "checkmark.circle")
          .resizable()
          .frame(width: 30, height: 30)
      }
    })
    .frame(maxWidth: .infinity)
  }
}
