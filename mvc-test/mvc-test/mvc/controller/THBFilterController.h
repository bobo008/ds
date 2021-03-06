//
//  THBFilterController.h
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import <UIKit/UIKit.h>
#import "THBEditor.h"
NS_ASSUME_NONNULL_BEGIN

@interface THBFilterController : NSObject

@property (nonatomic) UIView *superView;
@property (nonatomic) CGRect frame;
@property (nonatomic) THBEditor *editor;
- (void)setup;

@end

NS_ASSUME_NONNULL_END
