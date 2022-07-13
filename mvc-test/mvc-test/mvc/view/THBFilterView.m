

#import "THBFilterView.h"

#import "THBFilterCell.h"



#import <ReactiveObjC.h>



@interface THBFilterView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic) UIView *view;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic) NSArray<THBFilterModel *> *itemArray;

@end

@implementation THBFilterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
        [self addSubview:self.view];
        self.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

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

//    [self setupNoti]
}




- (void)setupDataSource {
    self.itemArray = [THBFilterManager manager].modelArrays;
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
    THBFilterModel *model = self.itemArray[indexPath.item];
    cell.label.text = model.filterID;
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    THBFilterModel *model = self.itemArray[indexPath.item];
//    model.isne
//    [[THBFilterManager manager] down]
    if (self.selectItem) {
        self.selectItem(self.itemArray[indexPath.item]);
    }
}

@end
