//
// Copyright 2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only
// Please see LICENSE in the repository root for full details.
//

import Compound
import SwiftUI

struct ShareExtensionView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(.compound.bgCanvasDefault)
    }
}

#Preview {
    ShareExtensionView()
}