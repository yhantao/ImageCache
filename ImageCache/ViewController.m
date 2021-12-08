//
//  ViewController.m
//  ImageCache
//
//  Created by Hantao Yang on 12/6/21.
//

#import "ViewController.h"
#import "ItemCell.h"


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *myTableView;

@property (nonatomic, weak) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, assign) NSUInteger count;

@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation ViewController

- (NSMutableArray *)data{
    if(!_data){
        _data = [NSMutableArray new];
    }
    return _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.myTableView.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = self.myTableView.refreshControl;
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    self.count = 120;
    __weak typeof(self)welf = self;
    [self loadDataWithCompletionHandler:^(NSArray *arr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self)sself = welf;
            [sself.data addObjectsFromArray:arr];
            [sself.myTableView reloadData];
            sself.isRefreshing = NO;
        });
        
    }];
    
}

- (void)loadDataWithCompletionHandler:(void(^)(NSArray *arr))completion{
    if(_isRefreshing){
        return;
    }
    _isRefreshing = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int max = (int)self.count + 20;
        NSMutableArray *mutableArray = [NSMutableArray new];
        while(self.count < max){
            NSString *urlStr = [NSString stringWithFormat:@"https://picsum.photos/id/%lu/400/300", self.count];
            [mutableArray addObject:urlStr];
            self.count ++;
        }
        completion([mutableArray copy]);
    });
}

- (void)refresh:(UIRefreshControl *)sender{
    self.count = 120;
    
    __weak typeof(self)welf = self;
    [self loadDataWithCompletionHandler:^(NSArray *arr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self)sself = welf;
            [sself.data removeAllObjects];
            [sself.data addObjectsFromArray:arr];
            [sself.myTableView reloadData];
            [sself.refreshControl endRefreshing];
            sself.isRefreshing = NO;
        });
        
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ItemCell *cell = (ItemCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell configCell:self.data[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.data count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300.0f;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y = [scrollView contentOffset].y;
    if(y >= 0.8 * scrollView.contentSize.height){
        __weak typeof(self)welf = self;
        [self loadDataWithCompletionHandler:^(NSArray *arr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self)sself = welf;
                [sself.data addObjectsFromArray:arr];
                [sself.myTableView reloadData];
                [sself.refreshControl endRefreshing];
                sself.isRefreshing = NO;
            });
            
        }];
    
    }
}

- (void)didReceiveMemoryWarning{
    [self.data removeAllObjects];
    [[NSOperationQueue mainQueue] cancelAllOperations];
}

@end
