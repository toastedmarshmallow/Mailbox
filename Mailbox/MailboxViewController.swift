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
    @IBOutlet weak var archiveView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var feedScrollView: UIScrollView!
    @IBOutlet weak var rescheduleOptions: UIImageView!
    @IBOutlet weak var secondMessageView: UIView!
    
    //Math Variables
    var trayOriginalCenter: CGPoint!
    var traySideOffset: CGFloat!
    var trayRight: CGPoint!
    var trayLeft: CGPoint!
    
    var rescheduleIconOriginalCenter: CGPoint!
    var rescheduleIconNewCenter: CGPoint!
    
    var archiveIconOriginalCenter: CGPoint!
    var archiveIconNewCenter: CGPoint!
    
    //Icon Variables
    @IBOutlet weak var secondMessage: UIImageView!
    @IBOutlet weak var rescheduleIcon: UIImageView!
    @IBOutlet weak var archiveIcon: UIImageView!
    @IBOutlet weak var feedImage: UIImageView!
    var listImage: UIImage!
    var deleteIcon: UIImage!
    var remindImage: UIImage!
    var archiveImage: UIImage!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("frame = ",accessibilityFrame.width)
        
        feedScrollView.contentSize = CGSize(width: 375, height: 1870)
        
        rescheduleOptions.alpha = 0.0
        rescheduleIconOriginalCenter = rescheduleIcon.center
        archiveIconOriginalCenter = archiveIcon.center
        remindImage = UIImage(named: "later_icon")
        listImage = UIImage(named: "list_icon")
        archiveImage = UIImage (named: "archive_icon")
        deleteIcon = UIImage (named: "delete_icon")
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didSwipeMessage(_:)))
        
        // Attaching gesture recognizer to message view
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
        
        if sender.state == .began {
            print("Gesture began")
            trayOriginalCenter = messageView.center
            rescheduleIconNewCenter = rescheduleIcon.center
            archiveIconNewCenter = archiveIcon.center
            
            //  As the reschedule icon is revealed, it should start semi-transparent and become fully opaque. If released at this point, the message should return to its initial position.
            
            self.rescheduleIcon.alpha = 0.0
            self.remindView.alpha = 0.0
            self.archiveView.alpha = 0.0
            self.archiveIcon.alpha = 0.0
            
            //dragging left
            if translation.x < 0 {
                self.rescheduleIcon.alpha = 0.3
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {self.rescheduleIcon.alpha = 1.0}, completion: { (nil) in})
                
            } else{
            //dragging right
                
                self.archiveIcon.alpha = 0.3
             
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {self.archiveIcon.alpha = 1.0}, completion: { (nil) in
                })
                
            }
        } else if sender.state == .changed {
            print("Gesture is changing")
            
            messageView.center = CGPoint(x: trayOriginalCenter.x + translation.x, y: trayOriginalCenter.y)
           
            //moving right:
           if translation.x > 0{
            
            UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {self.archiveView.alpha = 1.0}, completion: { finished in})
            
                //between 60 and 260, icon moves and background changes green to red
               if translation.x > 60{
                    
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: UIViewAnimationOptions.allowUserInteraction, animations: {self.archiveIcon.center = CGPoint(x: self.archiveIconNewCenter.x + (translation.x - 60), y: self.archiveIconNewCenter.y)}, completion: { finished in})
                
                    if translation.x > 260 {
                        UIView.animate(withDuration: 0.3, animations: {self.archiveView.backgroundColor = UIColor(red:0.66, green:0.06, blue:0.06, alpha:1.0); self.archiveIcon.image = self.deleteIcon}, completion: {finished in})
                    }
                
                }
            
            }
            
            //moving left: at 260pts, changes background color to brown and swaps out the reschedule icon with list icon
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
            
            //moving message to the right
             if translation.x > 0 {
                
                //if moved to the right less than 260pts, move the message back to the center
                UIView.animate(withDuration: 0.3) {
                    self.messageView.center = self.trayOriginalCenter
                }
                
                //if moved to the right greater than 260 points, slide tray to the right
                if translation.x > 260 {
                    UIView.animate(withDuration: 0.3, animations: {self.messageView.center = self.trayRight}, completion: {finished in self.moveFeedView()
                        self.archiveView.alpha = 0.0
                        self.archiveIcon.alpha = 0.0
                    
                        UIView.animate(withDuration: 0.0, delay: 2.0, options: [], animations: {self.reset()}, completion: ({finished in}))})

                }
                
            }else {
                //moving message to the left
                UIView.animate(withDuration: 0.3) {
                   
                    //if gesture ends before 260 points, move the message back to the center
                    if translation.x > -260 {
                        self.messageView.center = self.trayOriginalCenter
                    } else {
                        
                        //if gesture ends after 260 points, move the tray off canvas to the left
                        self.messageView.center = self.trayLeft
                        self.displayRescheduleOptions()
                    }

                }
            }
            print("Gesture ended")
            
            UIView.animate(withDuration: 0.0, delay: 2.0, options:[], animations: {self.rescheduleIcon.center = self.rescheduleIconOriginalCenter; self.archiveIcon.center = self.archiveIconOriginalCenter}, completion: {finished in})
        }
    }
    
    //animation to display the reschedule options screen
    func displayRescheduleOptions(){
        
        UIView.animate(withDuration: 0.2, delay: 2.0, options: [], animations: {self.rescheduleOptions.alpha = 1.0; self.rescheduleIcon.alpha = 0}, completion: nil)
    }
    
    func moveFeedView(){
        UIView.animate(withDuration: 0.4, animations: {self.feedImage.center.y -= 100})
    }
    
    func reset(){
        messageView.center = trayOriginalCenter
        self.feedImage.center.y += 100
        
        //resetting alphas
        self.rescheduleIcon.alpha = 0.0
        self.remindView.alpha = 0.0
        self.archiveView.alpha = 0.0
        self.archiveIcon.alpha = 0.0
        
        //resetting colors
        self.remindView.backgroundColor = UIColor(red:0.96, green:0.85, blue:0.06, alpha:1.0)
        self.archiveView.backgroundColor = UIColor(red:0.05, green:0.88, blue:0.28, alpha:1.0)
        
        //resetting icons
        self.rescheduleIcon.image = self.remindImage
        self.archiveIcon.image = self.archiveImage
        
        self.rescheduleIcon.center = self.rescheduleIconOriginalCenter
        self.archiveIcon.center = self.archiveIconOriginalCenter
    }
    

    @IBAction func didTapOptions(_ sender: UITapGestureRecognizer) {
        remindView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {self.rescheduleOptions.alpha = 0.0}, completion: {finished in self.moveFeedView()
        UIView.animate(withDuration: 0.0, delay: 2.0, options: [], animations: {self.reset()}, completion: ({finished in}))})
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
