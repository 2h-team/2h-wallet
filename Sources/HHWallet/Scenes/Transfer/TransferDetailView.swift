// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SwiftUI

struct TransferDetailView: View {

    @ObservedObject 
    var viewModel: TransferViewModel

    var action: (TransferViewModel.State.TransferDetails) -> Void

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    TransferDetailView(viewModel: TransferViewModel(), action: {_ in })
}
