//
//  AllRecordsViewController.m
//  SimpleVoiceMemo
//
//  Created by Boyi on 4/11/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "AllRecordsViewController.h"

#import "RecordFileHelper.h"
#import "VoiceRecord.h"

@implementation AllRecordsViewController

NSInteger playingIndex = -1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allRecords = [[RecordFileHelper sharedInstance] GetAllRecordsInFiles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setAllRecords:(NSArray *)allRecords {
    _allRecords = allRecords;
    [self.tableView reloadData];
}

#pragma mark - table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VoiceRecord *record = self.allRecords[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoiceRecordCellIdentifier" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VoiceRecordCellIdentifier"];
    }
    cell.textLabel.text = record.fileName;
    cell.imageView.image = [UIImage imageNamed:@"play"];
    if (indexPath.row == playingIndex) {
        cell.imageView.image = [UIImage imageNamed:@"stop"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (playingIndex >= 0 && playingIndex < [self.allRecords count]) {
        VoiceRecord *playingVoiceRecord = self.allRecords[playingIndex];
        [playingVoiceRecord stopPlay];
        UITableViewCell *playingCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:playingIndex inSection:0]];
        playingCell.imageView.image = [UIImage imageNamed:@"play"];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    VoiceRecord *voiceRecord = self.allRecords[indexPath.row];
    
    [voiceRecord play:^{
        cell.imageView.image = [UIImage imageNamed:@"play"];
    }];
    cell.imageView.image = [UIImage imageNamed:@"stop"];
    playingIndex = indexPath.row;
}

@end
