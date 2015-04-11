//
//  UploadingManager.m
//  SimpleVoiceMemo
//
//  Created by Boyi on 4/11/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "UploadingManager.h"

#import <AFNetworking.h>
#import "VoiceRecord.h"

#import "UMUUploaderManager.h"
#import "NSString+NSHash.h"
#import "NSString+Base64Encode.h"

@implementation UploadingManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static UploadingManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)updateLoadFile:(NSString *)fileName completion:(void (^)(BOOL))handler {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"/%@", FolderName]];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", dataPath, fileName];
    NSData *fileBuffer = [[NSFileManager defaultManager] contentsAtPath:filePath];
    
    NSDictionary * fileInfo = [UMUUploaderManager fetchFileInfoDictionaryWith:fileBuffer];//获取文件信息
    
    NSDictionary * signaturePolicyDic =[self constructingSignatureAndPolicyWithFileInfo:fileInfo];
    
    NSString * signature = signaturePolicyDic[@"signature"];
    NSString * policy = signaturePolicyDic[@"policy"];
    NSString * bucket = signaturePolicyDic[@"bucket"];
    
    UMUUploaderManager * manager = [UMUUploaderManager managerWithBucket:bucket];
    [manager uploadWithFile:fileBuffer policy:policy signature:signature progressBlock:^(CGFloat percent, long long requestDidSendBytes) {
        NSLog(@"%f",percent);
    } completeBlock:^(NSError *error, NSDictionary *result, BOOL completed) {
        UIAlertView * alert;
        if (completed) {
            alert = [[UIAlertView alloc]initWithTitle:@"" message:@"上传成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            NSLog(@"%@",result);
        } else {
            alert = [[UIAlertView alloc]initWithTitle:@"" message:@"上传失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            handler(NO);
        }
        [alert show];
        
    }];
}

- (void)downloadAllFilesAndSaveWithCompletion:(void (^)(NSArray *))handler {
    NSURL * requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"v0.api.upyun.com/voicememo"]];
    NSURLRequest * request = [NSURLRequest requestWithURL:requestURL];
    
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *opr, id responseObject) {
        // TODO: 读取所有文件列表之后便利所有存在文件并batch下载后存储
    } failure:^(AFHTTPRequestOperation *opr, NSError *error) {
        
    }];
    [operation start];
}

#pragma mark - Helper Methods

- (NSDictionary *)constructingSignatureAndPolicyWithFileInfo:(NSDictionary *)fileInfo
{
    // TODO: fill对应的bucket和secret
    NSString * bucket = @"";
    NSString * secret = @"";
    
    NSMutableDictionary * mutableDic = [[NSMutableDictionary alloc]initWithDictionary:fileInfo];
    [mutableDic setObject:@(ceil([[NSDate date] timeIntervalSince1970])+60) forKey:@"expiration"];
    [mutableDic setObject:[NSString stringWithFormat:@"/voicememo/%@.jpeg",@"fileName"] forKey:@"path"]; // TODO: 修改文件名

    NSString * signature = @"";
    NSArray * keys = [mutableDic allKeys];
    keys= [keys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in keys) {
        NSString * value = mutableDic[key];
        signature = [NSString stringWithFormat:@"%@%@%@",signature,key,value];
    }
    signature = [signature stringByAppendingString:secret];
    
    return @{@"signature":[signature MD5],
             @"policy":[self dictionaryToJSONStringBase64Encoding:mutableDic],
             @"bucket":bucket};
}

- (NSString *)dictionaryToJSONStringBase64Encoding:(NSDictionary *)dic
{
    id paramesData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:paramesData
                                                 encoding:NSUTF8StringEncoding];
    return [jsonString base64encode];
}

@end
