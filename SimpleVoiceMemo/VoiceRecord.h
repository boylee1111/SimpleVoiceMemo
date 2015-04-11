//
//  VoiceRecord.h
//  SimpleVoiceMemo
//
//  Created by Boyi on 4/11/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

static NSString * const FolderName = @"SimpleVoiceMemo";

@interface VoiceRecord : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic, readonly) BOOL isPlaying;

- (instancetype)initWithFileName:(NSString *)fileName;
- (void)record;
- (void)stopRecord;
- (void)play;
- (void)play:(void (^)(void))completion;
- (void)stopPlay;

@end
