//
//  LWSettingViewController.m
//  PhotoDIY
//
//  Created by luowei on 2016/11/18.
//  Copyright © 2016年 wodedata. All rights reserved.
//

#import "LWSettingViewController.h"
#import "LWWebViewController.h"

@interface LWSettingViewController (){
}

@property(nonatomic, strong) NSArray *data;

@end

@implementation LWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.data = @[];
    __weak typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://wodedata.com/MyResource/PhotoDIY-Guide/guide_cn.json"]
            completionHandler:^(NSData *data,
                    NSURLResponse *response,
                    NSError *error) {
                weakSelf.data = ((NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data options:0 error:nil])[@"guide_gif"];

            }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buyAction:(UIButton *)sender {
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section){
        case 0:{    //关于
            switch (indexPath.row){
                case 0:{
                    break;
                }
                case 1:{
                    NSURL *url = [NSURL URLWithString:@"http://wodedata.com"];
                    LWWebViewController *webVC = [LWWebViewController viewController:url title:@"官方网站"];
                    [self.navigationController pushViewController:webVC animated:YES];
                    break;
                }
                case 2:{
                    NSURL *url = [NSURL URLWithString:@"http://m.weibo.cn/u/1745746500"];
                    LWWebViewController *webVC = [LWWebViewController viewController:url title:@"微博"];
                    [self.navigationController pushViewController:webVC animated:YES];
                    break;
                }
                case 3:{
                    NSURL *url = [NSURL URLWithString:@"http://github.com/luowei/PhotoDIY"];
                    LWWebViewController *webVC = [LWWebViewController viewController:url title:@"PhotoDIY源代码"];
                    [self.navigationController pushViewController:webVC animated:YES];
                    break;
                }
                default:{
                    break;
                }
            }
            break;
        }
        //----------------------
        case 1:{    //使用指南
            switch (indexPath.row){
                default:{
                    if(self.data.count == 0){
                        return;
                    }
                    NSDictionary *keyValue = self.data[(NSUInteger) indexPath.row];
                    NSString *key = keyValue.allKeys.firstObject;
                    NSURL *url = [NSURL URLWithString:keyValue[key]];
                    LWWebViewController *webVC = [LWWebViewController viewController:url title:key];
                    [self.navigationController pushViewController:webVC animated:YES];
                    break;
                }
            }
            break;
        }
        default:{
            break;
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
