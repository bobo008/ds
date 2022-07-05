

#import "THBFilterMVPView.h"

#import "THBFilterCell.h"


#import <ReactiveObjC.h>



@interface THBFilterMVPView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic) UIView *view;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic) NSArray<NSDictionary *> *itemArray;


@property (nonatomic) id<THBFilterMVPPersenterProtocol> persenter;

@end

@implementation THBFilterMVPView

- (instancetype)initWithFrame:(CGRect)frame persenter:(id<THBFilterMVPPersenterProtocol>)persenter  {
    if (self = [super initWithFrame:frame]) {
        self.view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
        [self addSubview:self.view];
        self.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

        self.persenter = persenter;
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:THBFilterMVPUpdateNotificaiton object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        // 修改选中框
    }];

}




- (void)setupDataSource {
    self.itemArray = [self.persenter obtainArray];
    
    
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
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.persenter selectItem:self.itemArray[indexPath.item] index:indexPath.item];
}

@end
