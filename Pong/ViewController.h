//
//  ViewController.h
//  Pong
//
//  Created by Sandun Heenatigala on 5/5/17.
//  Copyright © 2017 Sandun Heenatigala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudioKit/CoreAudioKit.h>
#import <AudioToolbox/AudioToolbox.h>

//@interface SecondViewController : UIViewController <UIPickerViewDelegate>
@interface ViewController : UIViewController
{
    //paddle
    IBOutlet UIImageView *Paddle;
    
    //ball
    IBOutlet UIImageView *Ball;
    IBOutlet UIImageView *paddleInv;
    
    NSTimer *timer;
    NSInteger Ygain;
    NSInteger Xgain;
    
    //adding score
    IBOutlet UILabel *scoreLabel;
    int score;
    

    // timer variable
    
    //float timeSlider;
    
    // MIDI
    
    BOOL midiClientCreated_;
    MIDIClientRef midiClient_;
    
    BOOL midiInputPortCreated_;
    MIDIPortRef midiInputPort_;
    
    BOOL midiInputPortEndpointConnected_;
    MIDIEndpointRef midiConnectedInputEndpoint_;
    
    float xPaddle_;
    int testPaddle_;
}




//}

-(void)CPU;

@property (nonatomic) MIDIEndpointRef midiEndpoint;


- (IBAction)configureCentral:(id)sender;
- (IBAction)playerAIncrement:(id)sender;


@end

