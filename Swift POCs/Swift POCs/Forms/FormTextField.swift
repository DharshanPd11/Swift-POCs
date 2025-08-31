//
//  FormTextField.swift
//  Swift POCs
//
//  Created by Priyadharshan Raja on 31/08/25.
//
import SwiftUI

struct FormTextField: View {
    private var title: String
    private var placeholder: String
    @Binding private var text: String
    
    init(title: String, placeholder: String, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
        }
        .padding([.horizontal], 20)
    }
}


#Preview {
    @Previewable @State var name: String = "uigkhj"
    FormTextField(title: "Name", placeholder: "Enter your name", text: $name)
}
