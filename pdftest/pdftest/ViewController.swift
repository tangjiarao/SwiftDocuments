//
//  ViewController.swift
//  pdftest
//
//  Created by tangjiarao on 2018/5/28.
//  Copyright © 2018年 tangjiarao. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    
    var downloadRequest: Request?
    
    //文档根路径
    let documentsURL: URL =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    //文件夹路径
    var pdfDocumentsURL: URL {
        let url = documentsURL.appendingPathComponent("PDF", isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Create PDF dir failed dfdfdfd")
            }
        }
        return url
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let localURL = pdfDocumentsURL.appendingPathComponent("aaa").appendingPathComponent("aa.pdf")
        let remoteURL = URL(string: "https://zk.scutde.net/zk-resource/00504/ppt/0101-02.pdf")
        
        checkStatusCode(remoteURL: remoteURL!,succeed: {
            
            self.downloadPdf(remoteURL: remoteURL!, localURL: localURL, succeed: { fileTotalCount in
                
                self.viewPdf(pdfURL: localURL)
                
            }, failed: {
                print("Download failed")
            }, canceled: {
                print("Download canceled fff")
            })
        },failed: {
            print("Get Request failed")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func checkStatusCode(remoteURL: URL, succeed: @escaping ()->Void,failed: @escaping ()->Void) {
        
        Alamofire.request(remoteURL).response{
            response in
            
            if response.response?.statusCode == 200{
                succeed()
            }else{
                failed()
            }
        }
    }
    
    
    fileprivate func downloadPdf(remoteURL: URL, localURL: URL, succeed: @escaping (_ fileTotalCount: Int64)->Void, failed: @escaping ()->Void, canceled: @escaping ()->Void) {
        //下载文件的保存路径
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (localURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        var fileTotalCount:Int64 = 0
        self.downloadRequest = Alamofire.download(remoteURL, to: destination)
            .downloadProgress { progress in
                
                print(progress.totalUnitCount)
                print(progress.fractionCompleted)
            }
            .response { response in
                
                
                if response.error == nil && response.response?.statusCode == 200 && FileManager.default.fileExists(atPath: localURL.path) {
                    succeed(fileTotalCount)
                } else {
                    if response.resumeData != nil {
                        canceled()
                    } else {
                        failed()
                    }
                }
        }
        
    }
    
    fileprivate func viewPdf(pdfURL: URL) {
        let documentController = UIDocumentInteractionController(url: pdfURL)
        documentController.name = "文档测试"
        documentController.delegate = self
        documentController.presentPreview(animated: true)
        
    }
    
    
}

extension ViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.navigationController ?? self
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        
    }
}
