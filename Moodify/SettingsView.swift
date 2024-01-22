
import SwiftUI
import UIKit

struct SettingsView: View {
    @Binding var profileImage: Image?
    @State private var isImagePickerPresented: Bool = false

    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: Image?
        @Binding var isImagePickerPresented: Bool

        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            var parent: ImagePicker

            init(parent: ImagePicker) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = Image(uiImage: uiImage)
                }

                parent.isImagePickerPresented = false
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                parent.isImagePickerPresented = false
            }
        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }

        func makeUIViewController(context: Context) -> UIViewController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            // Nothing to update here
        }
    }

    var body: some View {
        VStack {
            Button(action: {
                // Show image picker or implement logic to upload a new profile photo
                isImagePickerPresented.toggle()
            }) {
                profileImage?
                    .resizable()
                    .frame(width: 380, height: 400)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 10)
            }
            .sheet(isPresented: $isImagePickerPresented, content: {
                // Implement the image picker or photo upload logic here
                // Update the profileImage binding with the new photo
                // Dismiss the image picker when done
                ImagePicker(image: $profileImage, isImagePickerPresented: $isImagePickerPresented)
            })

        }
        .padding()
    }

    // Helper function to navigate back
    func navigateBack() {
        // Dismiss the settings view
    }
}

