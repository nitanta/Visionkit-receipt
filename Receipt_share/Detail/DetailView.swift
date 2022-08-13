//
//  DetailView.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import SwiftUI

struct DetailView: View {
    @Binding var datasource: ReceiptItem?
    @State var scale: CGFloat = 1.0
    
    func getParentSize() -> CGSize {
        guard let ds = datasource, let item = ds.items.first else { return .zero }
        return item.parent
    }
    
    func getScale() -> CGFloat {
        guard let ds = datasource, let item = ds.items.first else { return 1 }
        return item.scale
    }
    
    var body: some View {
        HStack {
            if let datasource = datasource {
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    ScannedReceipt(datasource: datasource.items)
                        .frame(width: getParentSize().width, height: getParentSize().height)
                        .scaleEffect(getScale())
                }
            }
        }
        .navigationTitle(Constants.title)
    }
}

extension DetailView {
    struct Constants {
        static let title = "Receipt"
    }
}

struct ScannedReceipt: View {
    let datasource: [Item]
    var body: some View {
        ZStack {
            ForEach(datasource, id: \.id) { item in
                EditableField(title: item.title)
                    .frame(width: item.position.width, height: item.position.height)
                    .position(x: item.position.origin.x, y: item.position.origin.y)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct EditableField: View {
    var title: String
    @State var edit: Bool = false
    var body: some View {
        VStack {
            if edit {
                TextField("", text: .constant(title))
            } else {
                Text(title)
                    .onTapGesture {
                        edit.toggle()
                    }
            }
        }
        
    }
}

struct MapWrapperView<Content: View>: UIViewRepresentable {
    private var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 0
        scrollView.maximumZoomScale = 100
        scrollView.bouncesZoom = false
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.bounds = hostedView.frame
        scrollView.addSubview(hostedView)
        
        let leftMargin: CGFloat = (scrollView.frame.size.width - hostedView.bounds.width)*0.5
        let topMargin: CGFloat = (scrollView.frame.size.height - hostedView.bounds.height)*0.5
        
        scrollView.contentOffset = CGPoint(x: max(0,-leftMargin), y: max(0,-topMargin));
        scrollView.contentSize = CGSize(width: max(hostedView.bounds.width, hostedView.bounds.width+1), height: max(hostedView.bounds.height, hostedView.bounds.height+1))
        
        return scrollView
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            if(scale < scrollView.minimumZoomScale){
                scrollView.minimumZoomScale = scale
            }
            
            if(scale > scrollView.maximumZoomScale){
                scrollView.maximumZoomScale = scale
            }
            
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            if(scrollView.zoomScale < 1){
                let leftMargin: CGFloat = (scrollView.frame.size.width - hostingController.view!.frame.width)*0.5
                let topMargin: CGFloat = (scrollView.frame.size.height - hostingController.view!.frame.height)*0.5
                scrollView.contentInset = UIEdgeInsets(top: max(0, topMargin), left: max(0,leftMargin), bottom: 0, right: 0)
            }
            
        }
    }
}
