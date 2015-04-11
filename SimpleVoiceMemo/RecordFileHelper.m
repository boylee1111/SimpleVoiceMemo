//
//  RecordFileHelper.m
//  SimpleVoiceMemo
//
//  Created by Boyi on 4/11/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "RecordFileHelper.h"

#import "VoiceRecord.h"

@implementation RecordFileHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static RecordFileHelper *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSArray *)GetAllRecordsInFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"/%@", FolderName]];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:nil];
    
    NSMutableArray *records = [NSMutableArray array];
    for (NSString *fileName in directoryContent) {
        VoiceRecord *record = [[VoiceRecord alloc] init];
        record.fileName = fileName;
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   dataPath,
                                   fileName,
                                   nil];
        record.fileUrl = [NSURL fileURLWithPathComponents:pathComponents];
        
        [records addObject:record];
    }
    
    return [records copy];
}

@end
