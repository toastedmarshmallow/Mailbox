//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Shannan Hsiao on 10/7/16.
//  Copyright © 2016 Shannan Hsiao. All rights reserved.
//

import UIKit

class MailboxViewController: UIViewController {

    //View Variables
    @IBOutlet weak var remindView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var feedScrollView: UIScrollView!
    @IBOutlet weak var rescheduleOptions: UIImageView!
    
    //Math Variables
    var trayOriginalCenter: CGPoint!
    var traySideOffset: CGFloat!
    var trayRight: CGPoint!
    var trayLeft: CGPoint!
    
    var rescheduleIconOriginalCenter: CGPoint!
    var rescheduleIconNewCenter: CGPoint!
    
    //Icon Variables
    @IBOutlet weak var rescheduleIcon: UIImageView!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var feedImage: UIImageView!
    var listImage: UIImage!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("frame = ",accessibilityFrame.width)
        
        feedScrollView.contentSize = CGSize(width: 375, height: 1805)
        
        rescheduleOptions.alpha = 0.0
        rescheduleIconOriginalCenter = rescheduleIcon.center
        listImage = UIImage(named: "list_icon")
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didSwipeMessage(_:)))
        
        // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
        messageView.isUserInteractionEnabled = true
        messageView.addGestureRecognizer(panGestureRecognizer)

        // Dictates how the message moves left to right
        traySideOffset = 400
        trayRight = CGPoint(x: messageView.center.x + traySideOffset, y: messageView.center.y)
        trayLeft = CGPoint(x: messageView.center.x - traySideOffset, y: messageView.center.y)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didSwipeMessage(_ sender: UIPanGestureRecognizer) {
        //when message is swiped
        
        _ = sender.location(in: view)
        _ = sender.velocity(in: view)
        let translation = sender.translation(in: view)

        
        print("translation \(translation)")
        print("reschedule icon \(rescheduleIcon.center)")
        
        if sender.state == .began {
            print("Gesture began")
            trayOriginalCenter = messageView.center
            
            rescheduleIconNewCenter = rescheduleIcon.center
            
            //  As the reschedule icon is revealed, it should start semi-transparent and become fully opaque. If released at this point, the message should return to its initial position.
            
            //set the alpha to initially be semi-transparent
            self.rescheduleIcon.alpha = 0.3
            self.remindView.alpha = 0.0
            self.deleteIcon.alpha = 0.0
            
            //dragging left
            if translation.x < 0 {
              
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {self.rescheduleIcon.alpha = 1.0}, completion: { (nil) in
                })
                
            }
        } else if sender.state == .changed {
            print("Gesture is changing")
            
            messageView.center = CGPoint(x: trayOriginalCenter.x + translation.x, y: trayOriginalCenter.y)
            
            //at 260pts, changes background color to brown and swaps out the reschedule icon with list icon
            if translation.x < -260{
                print("hello")
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {self.remindView.backgroundColor = UIColor.brown; self.rescheduleIcon.image = self.listImage}, completion: { finished in self.displayRescheduleOptions()
                })
            }
            //at 60 points icon moves with transition
            else if translation.x < -60 {
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {self.remindView.alpha = 1.0; self.rescheduleIcon.center = CGPoint(x: self.rescheduleIconNewCenter.x + (translation.x + 60), y: self.rescheduleIconNewCenter.y)}, completion: { finished in
                })
            }

            
            
        } else if sender.state == .ended {
            
            if translation.x > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.messageView.center = self.trayRight

                
                }
            } else {
                //Dragging animation left
                UIView.animate(withDuration: 0.3) {
                    self.messageView.center = self.trayLeft
                    
                    //if gesture ends before the midpoint of the width, readjust the center point to be center of frame and snap the view back to center
                    if translation.x > -260 {
                        self.messageView.center = self.trayOriginalCenter
                    } else {
                        self.messageView.center = self.trayLeft
                    }

                }
            }
            print("Gesture ended")
            
            UIView.animate(withDuration: 0.0, delay: 1.0, options:[], animations: {self.rescheduleIcon.center = self.rescheduleIconOriginalCenter; self.rescheduleIcon.alpha = 0}, completion: nil)
        }
    }
    
    //animation to display the reschedule options screen
    func displayRescheduleOptions(){
        
        UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {self.rescheduleOptions.alpha = 1.0}, completion: nil)
    }
    

    @IBAction func didTapOptions(_ sender: UITapGestureRecognizer) {
        remindView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {self.rescheduleOptions.alpha = 0.0})
        UIView.animate(withDuration: 0.4, animations: {self.feedImage.center.y -= 100})
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
