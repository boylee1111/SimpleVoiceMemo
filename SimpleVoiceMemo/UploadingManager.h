//
//  UploadingManager.h
//  SimpleVoiceMemo
//
//  Created by Boyi on 4/11/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadingManager : NSObject

+ (instancetype)sharedInstance;

- (void)updateLoadFile:(NSString *)filePath completion:(void (^)(BOOL))handler;
- (void)downloadAllFilesAndSaveWithCompletion:(void (^)(NSArray *))handler;

@end
