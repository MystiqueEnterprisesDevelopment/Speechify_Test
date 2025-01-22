import SwiftUI

struct FinishView: View {
  @State var title: String
  
  var body: some View {
    VStack(content: {
      Spacer()
      Text(title)
        .font(.largeTitle)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      Spacer()
    })
    .background(Color.blue)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
