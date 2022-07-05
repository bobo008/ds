

#import "THBFilterMVVMView.h"

#import "THBFilterCell.h"


#import <ReactiveObjC.h>



@interface THBFilterMVVMView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic) UIView *view;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic) NSArray<NSDictionary *> *itemArray;


@property (nonatomic) id<THBFilterMVVMViewModelProtocol> viewModel;


@property (nonatomic) int index;

@end

@implementation THBFilterMVVMView

- (instancetype)initWithFrame:(CGRect)frame persenter:(id<THBFilterMVVMViewModelProtocol>)persenter  {
    if (self = [super initWithFrame:frame]) {
        self.view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
        [self addSubview:self.view];
        self.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

        self.viewModel = persenter;
        [self setup];
    }
    return self;
}


- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@ dealloc", self);
#endif
}

- (void)setup {

    [self setupDataSource];
    [self setupCollectionView];
    

    [RACObserve(self.viewModel, seletIndex) subscribeNext:^(id  _Nullable x) {
        self.index = self.viewModel.seletIndex;
        [self.collectionView reloadData];
    }];
}




- (void)setupDataSource {
    self.itemArray = [self.viewModel obtainArray];
    
    
}


- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 30;
    layout.minimumInteritemSpacing = 30;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    layout.itemSize = CGSizeMake(100, 100);
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([THBFilterCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([THBFilterCell class])];
}

#pragma mark collectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.itemArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    THBFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([THBFilterCell class]) forIndexPath:indexPath];
    NSDictionary *dict = self.itemArray[indexPath.item];
    cell.label.text = dict[@"label"];
    if (self.index == indexPath.item) {
        cell.backgroundColor = UIColor.redColor;
    } else {
        cell.backgroundColor = UIColor.yellowColor;
    }
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel selectItem:self.itemArray[indexPath.item]];
}

@end
