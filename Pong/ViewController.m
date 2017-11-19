//
//  ViewController.m
//  Pong
//
//  Created by Sandun Heenatigala on 5/5/17.
//  Copyright © 2017 Sandun Heenatigala. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMIDI/MIDINetworkSession.h>

// zero based channel numbers (e.g. "channel 1" has value 0, "channel 16" has value 15
#define PLAYER_A_MIDI_CHANNEL 0
#define PLAYER_B_MIDI_CHANNEL 0

// MIDI note numbers:
// http://newt.phys.unsw.edu.au/jw/notes.html
#define PLAYER_A_NOTE_NUMBER 10 //36
//#define PLAYER_B_NOTE_NUMBER 38


// core midi client name
#define MIDI_CLIENT_NAME @"Superinteractive Contest"
#define MIDI_PORT_NAME @"Input"


@interface ViewController ()



@end


@implementation ViewController

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView: touch.view];
        Paddle.center = CGPointMake(location.x, Paddle.center.y);
    }

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
    {
        [self touchesBegan:touches withEvent : event];
    }

-(void) CPU
    {
    Ball.center = CGPointMake(Ball.center.x + Xgain, Ball.center.y + Ygain);
        
        if (Ball.center.x < 15)
        {
            Xgain = labs(Xgain);
        }
        if (Ball.center.y < 15)
        {
            Ygain = labs(Ygain);
        }
        if (Ball.center.x > 305)
        {
            Xgain = -labs(Xgain);
        }
        if (Ball.center.y > 539)
        {
            Ygain = -labs(Ygain);
        }
            if (CGRectIntersectsRect(Ball.frame, paddleInv.frame)){
            
                
                //converted the int score to string
                NSString *string = [NSString stringWithFormat:@" %d", score];
                
                //alert for the score
                //change the story board id to MainScreen for the seauge to work
                UIViewController *bb = [self.storyboard instantiateViewControllerWithIdentifier:@"MainScreen"];
                [self presentViewController:bb animated:YES completion:^{
                    
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Your Score is"
                                          message: string
                                          delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
                    [alert show];
                    
                }];
            
               
            
               
            }
        
        
        //ball intersecting paddle
        if (CGRectIntersectsRect(Ball.frame, Paddle.frame))
        {
            Ygain = -labs(Ygain);
            
            //adding score
            score += 1;
            [scoreLabel setText:[NSString stringWithFormat:@"Score : %d", score]];
            
            
        }
        
    }

- (void)viewDidLoad
    {
    //[super viewDidLoad];
    [self initMidi];
    [self connectAllMIDI];
    
   
        
    [super viewDidLoad];
    
        
        //speed of the pong ball travel rich###
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target : self selector :@selector(CPU) userInfo: nil repeats:YES];
        
        Xgain = 10;
        Ygain = 10;
   
    }


- (void)didReceiveMemoryWarning
    {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    }






//ADDING MIDI FUNCTIONALITY
#pragma mark - MIDI control

static int isMidiStatusByte( Byte b )
{
    return b & 0x80;
}

static int computeMessageLength( const Byte *data, int dataLength )
{
    if (dataLength==0 || !isMidiStatusByte(data[0]))
        return 0;
    
    int result=1;
    while (result < dataLength && !isMidiStatusByte(data[result]))
        ++result;
    
    return result;
}

// 0x90 is note-on
static Byte playerAMidiStatus_ = (0xB0 + PLAYER_A_MIDI_CHANNEL);
static Byte playerAMidiValue0_ = PLAYER_A_NOTE_NUMBER;
static Byte playerAMidiValue1_ = 1;


static void midiReadProc(const MIDIPacketList *packetList, void *readProcRefCon, void *srcConnRefCon)
{
    ViewController *that = (__bridge ViewController *)readProcRefCon;
    
    const MIDIPacket *packet = packetList->packet;
    
    for (UInt32 i = 0; i < packetList->numPackets; i++) {
        int dataLength = packet->length;
        const Byte *data = packet->data;
        
        int messageLength = computeMessageLength(data, dataLength);
        while (messageLength != 0) {
            
            if (messageLength==3) { // only care about note messages
                NSLog(@"midi msg received");
                //    if (data[0] == playerAMidiStatus_ && data[1] == playerAMidiValue0_ && data[2] > 10) {
                //         [that performSelectorOnMainThread:@selector(playerAIncrement:) withObject:0 waitUntilDone:NO];
                //   }
                if (data[0] == playerAMidiStatus_ && data[1] == playerAMidiValue0_ ) {
                    playerAMidiValue1_ = data[2];
                    [that performSelectorOnMainThread:@selector(playerAIncrement:) withObject:0 waitUntilDone:NO];
                }
     
            }
            
            data += messageLength;
            dataLength -= messageLength;
            messageLength = computeMessageLength(data, dataLength);
        }
        
        packet = MIDIPacketNext(packet);
    }
}


- (void)initMidi
{
    midiClientCreated_ = NO;
    midiInputPortCreated_ = NO;
    midiInputPortEndpointConnected_ = NO;
    
    OSStatus status = MIDIClientCreate((__bridge CFStringRef)MIDI_CLIENT_NAME, /*notifyProc=*/NULL, /*notifyRefCon=*/NULL, &midiClient_);
    if (status == noErr) {
        midiClientCreated_ = YES;
    } else {
        [self displayMidiError:status whenPerformingAction:@"creating MIDI client"];
        return;
    }
    
    status = MIDIInputPortCreate(midiClient_, (__bridge CFStringRef)MIDI_PORT_NAME, midiReadProc, (__bridge void*)self, &midiInputPort_);
    if (status == noErr) {
        midiInputPortCreated_ = YES;
    } else {
        [self displayMidiError:status whenPerformingAction:@"creating MIDI input port"];
        
        MIDIClientDispose(midiClient_);
        midiClientCreated_ = NO;
        
        return;
    }
}



- (void)disposeMidi
{
    if (midiClientCreated_) {
        // Dispose the MIDI client and associated connections before self is disposed.
        // This is necessary because the midiReadProc has a pointer to self.
        
        // MIDIPortDispose not needed. MIDIClientDispose handles cleanup.
        
        MIDIClientDispose(midiClient_);
        
        midiClientCreated_ = NO;
        midiInputPortCreated_ = NO;
        midiInputPortEndpointConnected_ = NO;
    }
}

- (void)setMidiSourceEndpoint: (MIDIEndpointRef)midiEndpoint
{
    if (midiClientCreated_==NO || midiInputPortCreated_==NO)
        return;
    
    if (midiInputPortEndpointConnected_ && midiEndpoint==midiConnectedInputEndpoint_)
        return; // already connected to midiEndpoint, bail.
    
    // disconnect previous connection, if active
    if (midiInputPortEndpointConnected_) {
        OSStatus status = MIDIPortDisconnectSource(midiInputPort_, midiConnectedInputEndpoint_);
        if (status != noErr)
            [self displayMidiError:status whenPerformingAction:@"disconnecting MIDI endpoint"];
        midiInputPortEndpointConnected_ = NO;
    }
    
    if (midiEndpoint == MIDIGetSource(-1))
        return; // no device selected
    
    // connect specified endpoint
    OSStatus status = MIDIPortConnectSource(midiInputPort_, midiEndpoint, /*connRefCon=*/0);
    if (status == noErr) {
        midiConnectedInputEndpoint_ = midiEndpoint;
        midiInputPortEndpointConnected_ = YES;
    } else {
        [self displayMidiError:status whenPerformingAction:@"connecting MIDI endpoint"];
        midiInputPortEndpointConnected_ = NO;
    }
}

- (MIDIEndpointRef)midiSourceEndpoint
{
    if (midiInputPortEndpointConnected_) {
        return midiConnectedInputEndpoint_;
    } else {
        return MIDIGetSource(-1);
    }
}
//DONE UPTO THIS


// RH MIDI BTLE INSERT
- (void)doneAction:(id)sender
{
    // dismiss popover
    [self dismissViewControllerAnimated:YES completion:nil];
    // would like to update picker view
    //self.midiEndpoint = MIDIGetSource(0);
    [self connectAllMIDI];
}

// RH edits
- (void)connectAllMIDI

{
    // find the selected endpoint in the list and select it
    ItemCount n = MIDIGetNumberOfSources();
    NSLog(@"number of midi devices = @%01lu", n);
    
    for (int i=1; i < n; ++i) {
        MIDIEndpointRef endpoint = MIDIGetSource(i);
         //MIDIEndpointRef endpoint = MIDIGetSource(n);
        // connect specified endpoint
        OSStatus status = MIDIPortConnectSource(midiInputPort_, endpoint, /*connRefCon=*/0);
        if (status == noErr) {
            midiConnectedInputEndpoint_ = endpoint;
            midiInputPortEndpointConnected_ = YES;
        } else {
            [self displayMidiError:status whenPerformingAction:@"connecting MIDI endpoint"];
            midiInputPortEndpointConnected_ = NO;
        }
}
    
    // disconnect previous connection, if active
    NSLog(@"number of midi devices = @%01lu", n);
    
    
}



#pragma mark - UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ItemCount n = MIDIGetNumberOfSources();
    if (n == 0) {
        return @"No MIDI inputs available";
    } else {
        
        if (row >= 0 && row < n) {
            MIDIEndpointRef endpoint = MIDIGetSource(row);
            MIDIEntityRef entity;
            OSStatus status = MIDIEndpointGetEntity(endpoint, &entity);
            if (status == noErr) {
                
                CFStringRef cfName;
                status = MIDIObjectGetStringProperty(entity, kMIDIPropertyDisplayName, &cfName);
                if (status == noErr && cfName)
                    return (__bridge NSString*)cfName;
                else
                    return @"error getting name";
                
            } else {
                return @"error querying entity";
            }
        } else {
            return @"";
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    ItemCount n = MIDIGetNumberOfSources();
    if (row >= 0 && row < n) {
        self.midiEndpoint = MIDIGetSource(row);
    } else {
        self.midiEndpoint = MIDIGetSource(-1);
    }
}

- (IBAction)playerAIncrement:(id)sender
{
    
    NSLog(@"demo press");
    [self midiMove];
}


- (void)midiMove

{
    
    xPaddle_ = playerAMidiValue1_ * self.view.bounds.size.width / (127);
    Paddle.center = CGPointMake(xPaddle_, Paddle.center.y);
   
}



- (void)displayMidiError: (OSStatus)errorCode whenPerformingAction: (NSString*)actionDescription
{
    /*
     Something went wrong while configuring MIDI (%actionDescription).
     The system reported: <NSError.description> (<fourCC or number>).
     MIDI control might not be working. Sorry.
     */
    
    NSError *nsError = [NSError errorWithDomain:NSOSStatusErrorDomain code:errorCode userInfo:nil];
    
    char fourCCOrErrorNumber[128];
    formatError(fourCCOrErrorNumber, errorCode);
    
    NSString *messageString = [NSString stringWithFormat:@"Something went wrong while configuring MIDI (%@).\n The system reported: %@ (%s).\n\nMIDI control might not be working. Sorry.",
                               actionDescription, nsError.description, fourCCOrErrorNumber];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MIDI problem"
                                                    message:messageString
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

// Error display based on answers here: http://stackoverflow.com/questions/2196869/how-do-you-convert-an-iphone-osstatus-code-to-something-useful

static char *formatError(char *str, OSStatus error)
{
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    return str;
}

@end
