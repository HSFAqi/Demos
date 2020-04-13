//
//  ViewController.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/4/13.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "ViewController.h"
#import "MessageModel.h"
#import "NewMessageVC.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<MessageModel *> *messages;

/**
 * 0或1，缺省为0取更旧的元素，1取更新的元素
 */
@property (nonatomic, copy) NSString *direction;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.direction = @"0";
    MJWeakSelf
    // 下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.direction = @"0";
        [weakSelf loadMessages];
    }];
    // 上啦加载更多
    self.tableView.mj_footer  = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.direction = @"1";
        [weakSelf loadMessages];
    }];
    // Footer
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 90)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 20, width-40, 50);
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"新增消息" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(createNewMessageEvent) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:btn];
    self.tableView.tableFooterView = footer;
    // 加载数据
    [self.tableView.mj_header beginRefreshing];
}

// MARK: - actions
// 新增消息
- (void)createNewMessageEvent{
    NewMessageVC *vc = [[NewMessageVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    MJWeakSelf
    vc.newMessageSuccessBlock = ^(){
        [weakSelf.tableView.mj_header beginRefreshing];
    };
}

// MARK: - load data
- (void)loadMessages{
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    NSString *url = @"https://3evjrl4n5d.execute-api.us-west-1.amazonaws.com/dev/message?id=AAA&limit=10";
    [manger GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        NSArray *items = responseObject[@"data"][@"items"];
        if (items && [items isKindOfClass:[NSArray class]]) {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in items) {
                MessageModel *model = [MessageModel yy_modelWithDictionary:dic];
                [arr addObject:model];
            }
            if ([self.direction isEqualToString:@"0"]) {
                // 表示下拉刷新
                self.messages = arr;
            }else{
                // 表示加载更多
                [self.messages addObjectsFromArray:arr];
            }
            [self.tableView reloadData];
        }else{
            NSLog(@"数据格式有误");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"%@", error.localizedDescription);
    }];
}

// MARK: - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellReuseId"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellReuseId"];
    }
    MessageModel *model = self.messages[indexPath.row];
    cell.textLabel.text = model.content;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.creationTime];
    cell.detailTextLabel.text = [formatter stringFromDate:date];
    return cell;
}

// MARK: - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// MARK: - lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}
- (NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

@end
