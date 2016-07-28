//
//  ViewController.m
//  YTDBDemo
//
//  Created by 佟阳 on 16/7/28.
//  Copyright © 2016年 佟阳. All rights reserved.
//

#import "ViewController.h"
#import "YTDBMasonry.h"
#import "userModel.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *screen;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addShowData:(NSString*)str{
    
    _screen.text = [NSString stringWithFormat:@"%@%@ \r\n",_screen.text,str];

}

- (IBAction)AddData:(id)sender {
    
    [self addShowData:@"123"];
    
    userModel *model = [userModel new];
    
    model.user_value = @"测试一条数据";
    
    [model yt_openDatabases:^(YTDBDriveMaker *Drive) {
        Drive.M(@"t_user").add();
    }];
    
}

- (IBAction)UpdateData:(id)sender {
    
}

- (IBAction)DeleteData:(id)sender {
    
}

- (IBAction)SelectData:(id)sender {
    
}
@end
