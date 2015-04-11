//
//  VoiceRecord.m
//  SimpleVoiceMemo
//
//  Created by Boyi on 4/11/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "VoiceRecord.h"

@implementation VoiceRecord

void (^playCompletionHandler)();

- (instancetype)initWithFileName:(NSString *)fileName {
    if ((self = [super init])) {
        _fileName = [NSString stringWithFormat:@"%@.m4a", fileName];
        
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [[NSString alloc] initWithFormat:@"/%@/%@", FolderName, _fileName],
                                   nil];
        _fileUrl = [NSURL fileURLWithPathComponents:pathComponents];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"/%@", FolderName]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:_fileUrl settings:recordSetting error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
    }
    
    return self;
}

- (BOOL)isPlaying {
    if (self.player != nil) {
        return [self.player isPlaying];
    }
    return NO;
}

- (void)record {
    if (!self.recorder.recording) {
        [self.recorder prepareToRecord];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [self.recorder record];
        
        NSLog(@"file name = %@", self.fileUrl);
    }
}

- (void)stopRecord {
    [self.recorder stop];
     
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}

- (void)play {
    if (!self.recorder.recording) {
        NSError *error;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.fileUrl error:&error];
        self.player.delegate = self;
        [self.player prepareToPlay];
        if (![self.player play]) {
            NSLog(@"Error while playing, %@", error);
        }
    }
}

- (void)play:(void (^)(void))completion {
    [self play];
    playCompletionHandler = completion;
}

- (void)stopPlay {
    [self.player stop];
}

#pragma mark - deleagtes

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (playCompletionHandler != nil) {
        playCompletionHandler();
    }
    playCompletionHandler = nil;
}

@end
