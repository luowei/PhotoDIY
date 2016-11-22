//
//  LWSettingViewController.m
//  PhotoDIY
//
//  Created by luowei on 2016/11/18.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWSettingViewController.h"
#import "LWWebViewController.h"
#import "Reachability.h"

@interface LWSettingViewController () {
}

@property(nonatomic, strong) NSArray *data;

@end

@implementation LWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.data = @[];


    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [locale displayNameForKey:NSLocaleIdentifier value:[locale localeIdentifier]];
//    NSString *languageCode = locale.languageCode;
//    NSLog(@"-----languageCode:%@",languageCode);
    NSLog(@"-----language:%@",language);

    NSString *fileName = @"guide_en";
    if ([language containsString:@"中文"] && ![language containsString:@"繁體"]) {
        fileName = @"guide_cn";
    }else if ([language containsString:@"English"]) {
        fileName = @"guide_en";
    } else if ([language containsString:@"الولايات المتحدة"]) {
        fileName = @"guide_ar";
    } else if ([language containsString:@"français"]) {
        fileName = @"guide_fr";
    } else if ([language containsString:@"日本語"]) {
        fileName = @"guide_ja";
    } else if ([language containsString:@"한국어"]) {
        fileName = @"guide_ko";
    } else if ([language containsString:@"português"]) {
        fileName = @"guide_pt";
    } else if ([language containsString:@"русский"]) {
        fileName = @"guide_ru";
    } else if ([language containsString:@"español"]) {
        fileName = @"guide_es";
    } else if ([language containsString:@"Deutsch"]) {
        fileName = @"guide_de";
    } else if ([language containsString:@"繁體"]) {
        fileName = @"guide_hk";
    }

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        self.data = ((NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil])[@"data"];
    } else {
        NSString *urlStr = [NSString stringWithFormat:@"http://wodedata.com/MyResource/PhotoDIY-Guide/%@.json",fileName];
        NSURL *url = [NSURL URLWithString:urlStr];
        __weak typeof(self) weakSelf = self;
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            weakSelf.data = ((NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:nil])[@"data"];
        }] resume];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buyAction:(UIButton *)sender {
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = 0;
    NSDictionary *sectionDict = self.data[(NSUInteger) section];
    NSArray *sectionData = sectionDict.allValues.firstObject;
    count = sectionData.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LWTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *sectionDict = self.data[(NSUInteger) indexPath.section];
    NSArray *sectionData = sectionDict.allValues.firstObject;
    NSDictionary *rowDict = sectionData[(NSUInteger) indexPath.row];
    NSString *key = rowDict.allKeys.firstObject;
    cell.titleLabel.text = key;
    return cell;
}


#pragma mark - UITableViewDelegate

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionDict = self.data[(NSUInteger) section];
    NSString *sectionTitle = sectionDict.allKeys.firstObject;
    return sectionTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *sectionDict = self.data[(NSUInteger) indexPath.section];
    NSArray *sectionData = sectionDict.allValues.firstObject;
    NSDictionary *rowDict = sectionData[(NSUInteger) indexPath.row];
    NSString *key = rowDict.allKeys.firstObject;

    NSString *urlString = rowDict[key];
    if (![urlString isKindOfClass:[NSString class]] || urlString == nil || [urlString isEqualToString:@""]) {
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    LWWebViewController *webVC = [LWWebViewController viewController:url title:key];
    [self.navigationController pushViewController:webVC animated:YES];
}

@end

@implementation LWTableViewCell


@end

