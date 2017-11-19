//
//  SecondViewController.h
//  Pong
//
//  Created by Sandun Heenatigala on 5/5/17.
//  Copyright © 2017 Sandun Heenatigala. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudioKit/CoreAudioKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SecondViewController : UIViewController <UIPickerViewDelegate>
{
    // timer variable
    
    //float timeSlider;
    
    // MIDI
    
    BOOL midiClientCreated_;
    MIDIClientRef midiClient_;
    
    BOOL midiInputPortCreated_;
    MIDIPortRef midiInputPort_;
    
    BOOL midiInputPortEndpointConnected_;
    MIDIEndpointRef midiConnectedInputEndpoint_;

    
}

@property (nonatomic) MIDIEndpointRef midiEndpoint;
@property (weak, nonatomic) IBOutlet UIPickerView *midiInputEndpointPicker;

//adding the slider for time variable


- (IBAction)configureCentral:(id)sender;


- (IBAction)playGame:(id)sender;


//- (IBAction)playerBIncrement:(id)sender;


@end
