import SwiftUI

extension UIViewController {

    private struct Preview: UIViewControllerRepresentable {
        let vc: UIViewController

        func makeUIViewController(context: Context) -> some UIViewController { vc }
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    }

    func showPreview() -> some View {
        Preview(vc: self).edgesIgnoringSafeArea(.all)
    }
}
