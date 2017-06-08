//
//  OrderJDViewController.m
//  kyExpress
//
//  Created by mu on 16/12/22.
//  Copyright © 2016年 kyExpress. All rights reserved.
//

#import "OrderJDViewController.h"
#import "ReDeatilsTableViewCell.h"
#import "OrderRouteCell.h"
#import "OrderJD.h"
#import "sectionHeaderSelectView.h"

@interface OrderJDViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) sectionHeaderSelectView *sectionHeaderView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSArray *routeArr;

@end

static NSString *const TitleCell = @"TitleCell";

@implementation OrderJDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"京东路由详情";
    
    [self.view addSubview:self.tableView];
    
    WS(weakSelf);
    self.tableView.mj_header = [MJChiBaoZiHeader headerWithRefreshingBlock:^{
        if (weakSelf.jdModel) {
            [self requestNetWithJDID:weakSelf.jdModel.JDID];
        }
    }];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - NetWork 

- (void)requestNetWithJDID:(NSString *)JDID {
    
    WS(weakSelf);
    [[NetWorkManager sharedInstance] requestJdorderTrackWithJDOrederID:JDID Success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        [self.tableView.mj_header endRefreshing];
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id result = responseObject[@"result"];
            if ([result isKindOfClass:[NSDictionary class]]) {
                id orderTrack = result[@"orderTrack"];
                if ([orderTrack isKindOfClass:[NSArray class]]) {
                    if ([orderTrack count] != 0) {
                        weakSelf.routeArr = [OrderJD RouteModelWithArr:orderTrack];
                    }
                }
            }
            
            id errCode = responseObject[@"errCode"];
            if ([errCode integerValue] == -9) {
                [weakSelf performSelector:@selector(showToLoginVC) withObject:nil afterDelay:1];
            }
            
            id resultMessage = responseObject[@"resultMessage"];
            if ([resultMessage isKindOfClass:[NSString class]]) {
                if (![Tools isBlankString:resultMessage]) {
                    [Tools myToast:resultMessage];
                }
            }
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)showToLoginVC
{
    if (![UserInfoManage sharedInstance].isShowLoginVC.boolValue) {
        [Tools toLoginVC];
        [UserInfoManage sharedInstance].isShowLoginVC = @YES;
    }
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.routeArr.count != 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataSource.count;
    }else {
        return self.routeArr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self labelAutoCalculateRectWith:self.dataSource[indexPath.row]
                                       FontSize:14.0f
                                        MaxSize:CGSizeMake(kSCREEN_WIDTH - 32, CGFLOAT_MAX)].height + 15.0f;
    }else {
        OrderJD *route =self.routeArr[indexPath.row];
        return (route.contentH>(route.titleH+route.stateH+2)?route.contentH:(route.titleH+route.stateH+2)) + 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 38.5f;
    }
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10.0f;
    }
    if (section == 1) {
        return 0.01f;
    }
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        [self.sectionHeaderView SectionViewWithLeftTitle:@"物流信息" RightTitle:nil DidClick:^(NSInteger index) {
            if (index == 0) {
                
            }
        }];
        return self.sectionHeaderView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.dataSource.count != 0) {
            NSString *string = self.dataSource[indexPath.row];
            ReDeatilsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TitleCell];
            [cell setTitle:@"" Details:string];
            return cell;
        }
    }
    
    if (indexPath.section == 1) {
        return [self RouteCellWithTableView:tableView IndexPath:indexPath];
    }
    
    return [UITableViewCell new];
}

-(UITableViewCell *)RouteCellWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath {
    OrderRouteCell *routeCell= [tableView dequeueReusableCellWithIdentifier:@"OrderRouteCell"
                                                               forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        routeCell.isFirstCell = YES;
        routeCell.recode.textColor = [UIColor colorWithHexString:@"e9343e"];
        routeCell.time.textColor  = [UIColor colorWithHexString:@"e9343e"];
        routeCell.state.textColor = [UIColor colorWithHexString:@"e9343e"];
    }else{
        routeCell.isFirstCell = NO;
        routeCell.recode.textColor = [UIColor colorWithHexString:@"666666"];
        routeCell.time.textColor  = [UIColor colorWithHexString:@"666666"];
        routeCell.state.textColor = [UIColor colorWithHexString:@"666666"];
    }
    routeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    routeCell.routeModel =self.routeArr[indexPath.row];
    return routeCell;
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, CGRectGetHeight(self.view.frame) - 64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = [UIView new];
        
        [_tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_tableView setSeparatorColor:[UIColor colorWithHexString:@"dddddd"]];
        
        [_tableView registerNib:[UINib nibWithNibName:@"ReDeatilsTableViewCell" bundle:nil] forCellReuseIdentifier:TitleCell];
        [_tableView registerClass:[OrderRouteCell class] forCellReuseIdentifier:@"OrderRouteCell"];
        
    }
    return _tableView;
}

-(sectionHeaderSelectView *)sectionHeaderView {
    if (_sectionHeaderView == nil) {
        _sectionHeaderView = [[NSBundle mainBundle] loadNibNamed:@"sectionHeaderSelectView"
                                                           owner:nil
                                                         options:nil][0];
        _sectionHeaderView.userInteractionEnabled = YES;
        _sectionHeaderView.frame = CGRectMake(0, 0, kSCREEN_WIDTH, 30);
    }
    return _sectionHeaderView;
}

- (NSArray *)routeArr {
    if (_routeArr == nil) {
        _routeArr = [NSArray array];
    }
    return _routeArr;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
        if (_jdModel) {
            if (![Tools isBlankString:_jdModel.productName]) {
                [_dataSource addObject:[NSString stringWithFormat:@"商品名称: %@",_jdModel.productName]];
            }
            if (![Tools isBlankString:_jdModel.JDID]) {
                [_dataSource addObject:[NSString stringWithFormat:@"订  单  号: %@",_jdModel.JDID]];
            }
            if (![Tools isBlankString:_jdModel.creteDate]) {
                [_dataSource addObject:[NSString stringWithFormat:@"日       期: %@",_jdModel.creteDate]];
            }
        }
    }
    return _dataSource;
}

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.tableView.mj_header.isRefreshing) {
        return nil;
    }
    NSString *text = [[NSString alloc] init];
    text = @"加载数据失败\n请点击重试";
    
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0 green:171/255.0 blue:179/255.0 alpha:1.0],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    
    if (self.tableView.mj_header.isRefreshing) {
        return nil;
    }
    NSString *text = @"";
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:170/255.0 green:171/255.0 blue:179/255.0 alpha:1.0],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    return [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.tableView.mj_header.isRefreshing) {
        return nil;
    }
    return [UIImage imageNamed:@"nodata"];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.tableView.mj_header.isRefreshing) {
        return nil;
    }
    return [UIColor groupTableViewBackgroundColor];
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    return nil;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0;
}


#pragma mark - DZNEmptyDataSetSource Methods

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    [self.tableView.mj_header beginRefreshing];
    NSLog(@"%s",__FUNCTION__);
}

/*根据传过来的文字内容、字体大小、宽度和最大尺寸动态计算文字所占用的size
 * text 文本内容
 * fontSize 字体大小
 * maxSize  size（宽度，1000）
 * return  size （计算的size）
 */
- (CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    NSDictionary* attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize labelSize;
    
    labelSize = [text boundingRectWithSize: maxSize
                                   options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine
                                attributes:attributes
                                   context:nil].size;
    
    labelSize.height=ceil(labelSize.height);
    labelSize.width=ceil(labelSize.width);
    return labelSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
