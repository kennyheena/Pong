//
//  SecondViewController.m
//  Pong
//
//  Created by Sandun Heenatigala on 5/5/17.
//  Copyright © 2017 Sandun Heenatigala. All rights reserved.
//

#import "SecondViewController.h"



@interface SecondViewController ()
@end



@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // [self initMidi];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// RH MIDI BTLE INSERT
- (void)doneAction:(id)sender
{
    // dismiss popover
    [self dismissViewControllerAnimated:YES completion:nil];
    // would like to update picker view
    //self.midiEndpoint = MIDIGetSource(0);
   // [self connectAllMIDI];
}

//opening link on the button
- (IBAction)linkHome:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.superinteractiv.com"]];
}


// RH edits

- (IBAction)configureCentral:(id)sender {
    CABTMIDICentralViewController *viewController = [CABTMIDICentralViewController new];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    // this will present a view controller as a popover in iPad and modal VC on iPhone...done??
    viewController.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction:)];
    
    navController.modalPresentationStyle = UIModalPresentationPopover;
    
    
    UIPopoverPresentationController *popC = navController.popoverPresentationController;
    popC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popC.sourceRect = [sender frame];
    
    UIButton *button = (UIButton *)sender;
    popC.sourceView = button.superview;
    
    
    [self presentViewController:navController animated:YES completion:nil];
    
    
    // 4sec delay as done button missing???!!
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target: self
                                   selector:@selector(doneAction:)
                                   userInfo:nil
                                    repeats: NO];
    
    
}




- (IBAction)playGame:(id)sender {
    [self performSegueWithIdentifier:@"Game" sender:self];
}

@end

