//
//  RecordingViewController.m
//  SimpleVoiceMemo
//
//  Created by Boyi on 4/11/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "RecordingViewController.h"

#import "VoiceRecord.h"
#import "RecordFileHelper.h"
#import "UploadingManager.h"

@interface RecordingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *recordingButton;
@property (weak, nonatomic) IBOutlet UIButton *playingButton;
@property (nonatomic, strong) VoiceRecord *voiceRecord;

@end

@implementation RecordingViewController

BOOL isPlaying = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recordingButtonLongPress:)];
    [self.recordingButton addGestureRecognizer:longPress];
    
    self.playingButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)recordingButtonLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.voiceRecord = [[VoiceRecord alloc] initWithFileName:[NSString stringWithFormat:@"%lu", [[NSDate date] hash]]];
        [self.voiceRecord record];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.voiceRecord stopRecord];
        [[UploadingManager sharedInstance] updateLoadFile:self.voiceRecord.fileName completion:nil];
        self.playingButton.hidden = NO;
    }
}

- (IBAction)playRecord:(id)sender {
    if (isPlaying) {
        [self.playingButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.voiceRecord stopPlay];
    } else {
        [self.voiceRecord play:^{
            [self.playingButton setTitle:@"Play" forState:UIControlStateNormal];
            isPlaying = !isPlaying;
        }];
        [self.playingButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
    isPlaying = !isPlaying;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.voiceRecord stopPlay];
    [self.playingButton setTitle:@"Play" forState:UIControlStateNormal];
}

@end
