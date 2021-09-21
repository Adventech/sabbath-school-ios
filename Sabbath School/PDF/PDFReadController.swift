/*
 * Copyright (c) 2021 Adventech <info@adventech.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import AsyncDisplayKit
import PSPDFKitUI
import FirebaseDatabase
import FirebaseAuth

class PDFReadController: VideoPlaybackDelegatable {
    let pdfView = PDFView()
    var pdfs: [PDF] = []
    var video: [VideoInfo] = []
    var audio: [Audio] = []
    // let bibleVerses = [1, 2, 3]
    let lessonIndex: String
    var database: DatabaseReference!
    
    init(lessonIndex: String) {
        self.lessonIndex = lessonIndex
        super.init(node: pdfView)
    }
    
    override var prefersStatusBarHidden: Bool {
        if let tabbedView = self.pdfView.tabbedPDFController,
           let pdfController = tabbedView.pdfController as? PDFReadViewController {
           return pdfController.prefersStatusBarHidden
        }
        return false
    }
    
    override func viewDidLoad() {
        setBackButton()
        database = Database.database().reference()
        database.keepSynced(true)
        
        super.viewDidLoad()
        navigationController?.delegate = self
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppStyle.Base.Color.navigationTitle]
            
        self.navigationController?.navigationBar.tintColor = AppStyle.Base.Color.navigationTint
        
        self.getPDFs { pdfs in
            if pdfs.count <= 0 || self.pdfView.pdfLoaded { return }
            
            self.pdfView.loadPDF(pdfs: pdfs, vcDelegate: self)
            self.addChild(self.pdfView.tabbedPDFController)
            
            // pdfView.bibleView.delegate = self
            // pdfView.bibleView.dataSource = self
    
            self.pdfView.tabbedPDFController.pdfController.didMove(toParent: self)
            self.setRightBarButtonItems()
        }
        
        let audioInteractor = AudioInteractor()
        let videoInteractor = VideoInteractor()
        
        audioInteractor.retrieveAudio(quarterlyIndex: String(lessonIndex.prefix(lessonIndex.count-3))) { audio in
            self.audio = audio.filter { $0.targetIndex.starts(with: self.lessonIndex) }
            self.setRightBarButtonItems()
        }
        
        videoInteractor.retrieveVideo(quarterlyIndex: String(lessonIndex.prefix(lessonIndex.count-3))) { video in
            self.video = video
            self.setRightBarButtonItems()
        }
    }
    
    func setRightBarButtonItems() {
        var barButtons: [UIBarButtonItem] = []
        
        if let pdfController = self.pdfView.tabbedPDFController.pdfController as? PDFReadViewController,
           let pdfBarItems = pdfController.navigationItem.rightBarButtonItems {
            barButtons.append(contentsOf: pdfBarItems)
        }
        
        if self.video.count > 0 {
            let videoButton = UIBarButtonItem(image: R.image.iconVideo(), style: .done, target: self, action: #selector(presentVideo(sender:)))
            videoButton.accessibilityIdentifier = "videoButton"
            barButtons.append(videoButton)
        }
        
        if self.audio.count > 0 {
            let audioButton = UIBarButtonItem(image: R.image.iconAudio(), style: .done, target: self, action: #selector(presentAudio(sender:)))
            audioButton.accessibilityIdentifier = "audioButton"
            barButtons.append(audioButton)
        }
        
        self.navigationItem.setRightBarButtonItems(barButtons, animated: false)
    }
    
    @objc func presentVideo(sender: UIBarButtonItem) {
        let videoController = VideoController(video: self.video, lessonIndex: self.lessonIndex, readController: self)
        
        if #available(iOS 13, *) {
            self.present(videoController, animated: true)
        } else {
            self.present(ASNavigationController(rootViewController: videoController), animated: true)
        }
    }
    
    @objc func presentAudio(sender: UIBarButtonItem) {
        let audioController = AudioController(audio: self.audio, lessonIndex: self.lessonIndex)
        
        if #available(iOS 13, *) {
            self.present(audioController, animated: true)
        } else {
            self.present(ASNavigationController(rootViewController: audioController), animated: true)
        }
    }
    
    func getPDFs(cb: @escaping ([PDF]) -> Void) {
        database.child(Constants.Firebase.lessonInfo).child(self.lessonIndex).observe(.value, with: { [self] (snapshot) in
            guard let json = snapshot.data else { return }
            do {
                let lessonInfo: LessonInfo = try FirebaseDecoder().decode(LessonInfo.self, from: json)
                
                self.pdfs = lessonInfo.pdfs
                cb(pdfs)
            } catch {}
            
        }) { error in }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarOpacity(alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    func retrieveAnnotations() {
        for (index, pdf) in pdfs.enumerated() {
            database
                .child(Constants.Firebase.annotations)
                .child((Auth.auth().currentUser?.uid)!)
                .child(lessonIndex)
                .child(pdf.id).observe(.value, with: { [weak self] (snapshot) in
                    do {
                        guard let json = snapshot.data else {
                            self?.pdfView.tabbedPDFController.loadAnnotations(documentIndex: index, annotations: [])
                            return
                        }
                        let annotations = try FirebaseDecoder().decode(Array<PDFAnnotations>.self, from: json)
                        self?.pdfView.tabbedPDFController.loadAnnotations(documentIndex: index, annotations: annotations)
                    } catch {}
                })
        }
        
    }
}

//extension PDFReadController: ASTableDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Click happened
//    }
//}
//
//extension PDFReadController: ASTableDataSource {
//    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
//        let cellNodeBlock: () -> ASCellNode = {
//            return LessonEmptyCellNode()
//        }
//        return cellNodeBlock
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return bibleVerses.count
//    }
//}

extension PDFReadController: PDFReadControllerDelegate {
    func didTapBible() {
        pdfView.showBible = !pdfView.showBible
        pdfView.transitionLayout(withAnimation: true, shouldMeasureAsync: true)
    }
    
    func loadAnnotations() {
        self.retrieveAnnotations()
    }
    
    func uploadAnnotations(documentId: String) {
        for (index, document) in pdfView.tabbedPDFController.documents.enumerated() {
            guard (0 ..< pdfs.count).contains(index) else { continue }
            
            let inkAnnotations = document.allAnnotations(of: .all)
            var allAnnotations: [PDFAnnotations] = []
            for pageIndex in inkAnnotations {
                var annotations: [String] = []
                for annotation in pageIndex.value {
                    let data = try! annotation.generateInstantJSON()
                    let jsonString = String(data: data, encoding: .utf8)
                    annotations.append(jsonString!)
                }
                allAnnotations.append(PDFAnnotations(pageIndex: Int(pageIndex.key.intValue), annotations: annotations))
            }
            
            do {
                let z = try JSONEncoder().encode(allAnnotations)
                let data = try JSONSerialization.jsonObject(with: z, options: .allowFragments)
                database
                    .child(Constants.Firebase.annotations)
                    .child((Auth.auth().currentUser?.uid)!)
                    .child(lessonIndex)
                    .child(pdfs[index].id)
                    .setValue(data)
            } catch {}
        }
    }
}

extension PDFReadController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        DispatchQueue.main.async(execute: {
            self.setNavigationBarOpacity(alpha: 1)
        })
    }
}


protocol PDFReadControllerDelegate {
    func didTapBible()
    func uploadAnnotations(documentId: String)
    func loadAnnotations()
}
