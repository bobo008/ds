//
//  THBRenderProtocol.h
//  mvc-test
//
//  Created by tanghongbo on 2022/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol THBUndoManagerProtocol <NSObject>


- (BOOL)canUndo;
- (BOOL)canRedo;
- (void)undo;
- (void)redo;

- (void)executeAction:(NSString *)actionModel;

@end

NS_ASSUME_NONNULL_END
