//
//  LWSettingViewController.m
//  PhotoDIY
//
//  Created by luowei on 2016/11/18.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWSettingViewController.h"
#import "LWWebViewController.h"

@interface LWSettingViewController () {
}

@property(nonatomic, strong) NSArray *data;

@end

@implementation LWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.data = @[];

    NSURL *url = [NSURL URLWithString:@"http://wodedata.com/MyResource/PhotoDIY-Guide/guide_cn.json"];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [locale displayNameForKey:NSLocaleIdentifier value:[locale localeIdentifier]];
//    NSString *languageCode = locale.languageCode;
//    NSLog(@"-----languageCode:%@",languageCode);

    if([language containsString:@"English"]){
        url = [NSURL URLWithString:@"http://wodedata.com/MyResource/PhotoDIY-Guide/guide_en.json"];
    }else if([language containsString:@"English"]){
        url = [NSURL URLWithString:@"http://wodedata.com/MyResource/PhotoDIY-Guide/guide_en.json"];
    }

    __weak typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            weakSelf.data = ((NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:data options:0 error:nil])[@"data"];
        } else {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"guide_cn" ofType:@"json"];
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            self.data = ((NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil])[@"data"];
        }

    }] resume];

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

