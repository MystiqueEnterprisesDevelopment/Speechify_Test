import SwiftUI

enum PaymentSelectorViewState {
  case Loading
  case DisplayPaymentOptions
}

class PaymentSelectorViewModel: ObservableObject {
  private let repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()
  private var allPaymentOptions:[PaymentOptionModel] = []
  var dismissSelectorCompletion: ((Bool, PaymentOptionModel?) -> ())?

  @Published var selectedPayment: PaymentOptionModel?
  @Published var displayedPaymentOptions: [PaymentOptionModel] = []
  @Published var viewState: PaymentSelectorViewState
  @Published var searchString: String = "" {
    didSet {
      filterOptions()
    }
  }
  
  init() {
    self.viewState = .Loading
    loadPaymentOptions()
  }
  
  func refreshList() {
   loadPaymentOptions()
  }
  
  func loadPaymentOptions() {
    updateLoadingState(isLoading: true)
    
    repository.getTypes { [weak self] result in
      switch result {
      case .success(let options):
        self?.updatePaymentOptions(options)
        self?.updateLoadingState(isLoading: false)
        self?.showPayments()
      case .failure(let err):
        print(err.localizedDescription)
        self?.updateLoadingState(isLoading: false)
      }
    }
  }
  
  func updateLoadingState(isLoading: Bool) {
    DispatchQueue.main.async {
      if isLoading {
        self.viewState = .Loading
      }
    }
  }
  
  func updatePaymentOptions(_ options: [PaymentType]) {
    DispatchQueue.main.async {
      self.allPaymentOptions = options.map({ payment in
        return PaymentOptionModel(option: payment.name)
      })
      
      self.filterOptions()
    }
  }
  
  private func showPayments() {
    DispatchQueue.main.async {
      self.viewState = .DisplayPaymentOptions
    }
  }
  
  func filterOptions() {
    DispatchQueue.main.async {
      if !self.searchString.isEmpty {
        let search = self.searchString.lowercased()
        let regex = NSRegularExpression.escapedPattern(for: search)
        
        self.displayedPaymentOptions = self.allPaymentOptions.filter({ model in
          return model.searchableString.contains(regex)
        })
      } else {
        self.displayedPaymentOptions = self.allPaymentOptions
      }
    }
  }
  
  func selectPaymentOption(_ option: PaymentOptionModel) {
    DispatchQueue.main.async {
     
      if let selected = self.selectedPayment, selected.option == option.option {
        self.selectedPayment = nil
      } else {
        self.selectedPayment = option
      }
    }
  }
  
  func hasPaymentOptions() -> Bool {
    return !allPaymentOptions.isEmpty
  }
  
  func dismissSelector(_ dismiss: Bool) {
    DispatchQueue.main.async { [weak self] in
      self?.dismissSelectorCompletion?(dismiss, self?.selectedPayment)
    }
  }
  
  func hasSelectedPayment() -> Bool {
    return selectedPayment != nil
  }
}
