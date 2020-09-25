//
//  ContentView.swift
//  SimpleQrCode
//
//  Created by Martin Albrecht on 25.06.20.
//  Copyright © 2020 Martin Albrecht. All rights reserved.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [AnyObject]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems,
                                        applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityView>) {
    }
}


/// Generate QR code
extension String {
    func qrCodeImage() -> UIImage? {
        if !isEmpty {
            let ciContext = CIContext()
            let data = self.data(using: String.Encoding.utf8)
            let qrTransform = CGAffineTransform(scaleX: 24, y: 24)
            
            guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
                return nil
            }
            qrFilter.setValue(data, forKey: "inputMessage")

            guard let ciImage = qrFilter.outputImage?.transformed(by: qrTransform) else {
                return nil
            }
            
            if let img = ciContext.createCGImage(ciImage, from: ciImage.extent) {
                return UIImage(cgImage: img)
            }
        }
        
        return nil
    }
}


struct TextFieldClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            if !text.isEmpty {
                Button(
                    action: { self.text = "" },
                    label: {
                        Image(systemName: "delete.left")
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                    }
                )
            }
        }
    }
}

extension Color {
    static let pinkMain: Color = Color("PinkMain")
    static let pinkDark: Color = Color("PinkDark")
    static let purpleMain: Color = Color("PurpleMain")
    static let blueMain: Color = Color("BlueMain")
}


struct ContentView: View {
    @ObservedObject private var keyboard = KeyboardResponder()
    
    private enum PrefixTypes {
        case text, url, phone
    }
    
    @State private var rawImage: UIImage?
    @State private var codeImage: Image?
    @State private var codeText: String = ""
    @State private var selectedPrefix = PrefixTypes.text
    
    @State private var showShareSheet: Bool = false
    
    private var placeholder: String {
        switch selectedPrefix {
        case PrefixTypes.text:
            return "Enter your text"
            
        case PrefixTypes.url:
            return "Enter your URL"
            
        case PrefixTypes.phone:
            return "Enter your phone number"
        }
    }
    
    private var prefix: String {
        switch selectedPrefix {
        case PrefixTypes.text:
            return ""
            
        case PrefixTypes.url:
            return "url:"
            
        case PrefixTypes.phone:
            return "tel:"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create QR code")
                    .bold()
                    .font(.largeTitle)
                
                VStack {
                    if codeImage != nil {
                        codeImage!
                            .resizable()
                            .scaledToFit()
                            .contextMenu {
                                Button(
                                    action: { self.showShareSheet.toggle()  },
                                    label: {
                                        Text("Share image")
                                            .font(.body)
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.body)
                                    }
                                )
                            }
                            .transition(.scale)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .foregroundColor(Color.primary)
                            .opacity(0.6)
                    }
                }
                .padding()
                .frame(width: 250, height: 250)
                .background(Color.white.opacity(0.3))
                .cornerRadius(20)
                
                Picker(selection: $selectedPrefix, label: Text("Type")) {
                    Text("Text").tag(PrefixTypes.text)
                    Text("URL").tag(PrefixTypes.url)
                    Text("Phone number").tag(PrefixTypes.phone)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)
                
                VStack {
                    ZStack {
                        if codeText.isEmpty {
                            HStack {
                                Text(placeholder)
                                Spacer()
                            }
                            .opacity(0.3)
                        }
                        
                        TextField("", text: $codeText)
                            .modifier(TextFieldClearButton(text: $codeText))
                            .multilineTextAlignment(.leading)
                            .keyboardType(.alphabet)
                            .cornerRadius(10)
                            .overlay(
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: 1)
                                    .offset(y: 10)
                                
                                ,alignment: .bottom
                            )
                    }
                    .foregroundColor(Color.white)
                    .padding(.bottom, 10)
                    
                    HStack {
                        Spacer()
                        
                        Text("\(codeText.count) characters")
                            .font(.caption)
                    }
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                
                Button(
                    action: { self.loadimage() },
                    label: {
                        Text("Create")
                            .padding()
                            .background(Color.pinkMain.opacity(0.6))
                            .cornerRadius(10)
                    }
                )
                .opacity(codeText.isEmpty ? 0.3 : 1)
            }
            .foregroundColor(Color.white)
            .padding()
        }
        .keyboardResponsive(keyboard: self.keyboard)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purpleMain, Color.blueMain]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
        )
        .sheet(isPresented: $showShareSheet, content: {
            ActivityView(activityItems: [self.rawImage! as AnyObject] as [AnyObject], applicationActivities: nil)
        })
    }
    
    private func loadimage() {
        if let img = (prefix + codeText).qrCodeImage() {
            rawImage = img
            codeImage = Image(uiImage: img)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
