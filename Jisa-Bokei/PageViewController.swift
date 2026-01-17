//
//  PageViewController.swift
//  Jisa-Bokei
//
//  Created by 小沢克治 on 2017/12/03.
//  Copyright © 2017年 Private. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setViewControllers([getFirst()], direction: .Forward, animated: true, completion: nil)
        self.set
        
    }

    func getFirst() -> CalculationViewController {
        return storyboard!.instantiateViewController(withIdentifier: "CalculationViewController") as! CalculationViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
