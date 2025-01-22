import SwiftUI

class CountdownScreenViewModel: ObservableObject {
  let processDurationInSeconds: Int = 60
  private var timer: Timer?

  @Published var showPaymentSelector: Bool = false
  @Published var selectedPayment: PaymentOptionModel?
  @Published var countdown: Int
  @Published var isLoadingOptions: Bool = false
  @Published var hasCompletedPaymentSelection = false
  @Published var viewState: CountdownScreenState = .Countdown
  
  private lazy var paymentSelectorViewModel: PaymentSelectorViewModel = {
    let vm = PaymentSelectorViewModel()
    vm.dismissSelectorCompletion = { [weak self] shouldDismiss, selectedPayment in
      self?.showPaymentInfo(!shouldDismiss)
      if let payment = selectedPayment {
        self?.selectPaymentOption(payment)
      }
    }
    return vm
  }()

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
  
  func providePaymentSelectorViewModel() -> PaymentSelectorViewModel {
    return paymentSelectorViewModel
  }
  
  func showPaymentInfo(_ show: Bool) {
    self.showPaymentSelector = show
  }
  
  func selectPaymentOption(_ option: PaymentOptionModel) {
    if self.selectedPayment == nil {
      self.selectedPayment = option
    }  else {
      self.selectedPayment = nil
    }
  }
  
  func completePayment() {
    self.viewState = .Finished
    self.timer?.invalidate()
  }
  
  func hasTimeLeft() -> Bool {
    return self.countdown > 0
  }
}
