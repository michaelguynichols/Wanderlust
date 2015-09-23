//
//  WikiWebview.swift
//  QuandlPractice
//
//  Created by Michael Nichols on 8/26/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit

class WikiWebview: UIViewController {
    
    var URL: NSURL?
    @IBOutlet weak var wikiWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestObj = NSURLRequest(URL: URL!);
        wikiWebView.loadRequest(requestObj);
        
    }
    
}