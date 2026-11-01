import SwiftUI

struct RecipientStepView: View {
    @State private var name = ""
    @State private var phone = ""
    @State private var upiID = ""

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    TransferStepIndicator(currentStep: 1)

                    Text("Recipient details")
                        .font(Theme.Typography.headlineSmall)
                        .foregroundStyle(Theme.Colors.neutral)

                    AppTextField(title: "Name", placeholder: "Recipient name", text: $name)
                    AppTextField(
                        title: "Mobile number",
                        placeholder: "10-digit mobile number",
                        text: $phone,
                        keyboard: .phonePad,
                        capitalization: .never
                    )
                    AppTextField(
                        title: "UPI ID",
                        placeholder: "name@swiftpay",
                        text: $upiID,
                        keyboard: .emailAddress,
                        capitalization: .never
                    )

                    AppButton(title: "Continue") {}
                }
                .padding(Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
    }
}

#Preview {
    RecipientStepView()
}
