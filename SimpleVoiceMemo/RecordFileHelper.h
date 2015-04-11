//
//  RecordFileHelper.h
//  SimpleVoiceMemo
//
//  Created by Boyi on 4/11/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordFileHelper : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)GetAllRecordsInFiles;

@end
