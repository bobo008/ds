

#import "THBEditor.h"




@interface THBEditor () {

}

@end

@implementation THBEditor
/// 编辑状态数据
@synthesize editModel = _editModel;
/// 渲染数据
@synthesize data = _data;


#pragma mark - init
- (void)install:(THBData *)data editModel:(THBEditModel *)editModel {
    self.editModel = editModel;
    self.data = data;
}



- (void)uninstall {

}



/// 渲染模块
- (void)draw {
    
}











/// undo redo 模块
- (BOOL)canUndo {
    return NO;
}

- (BOOL)canRedo {
    return NO;
}

- (void)undo {
    
}

- (void)redo {
    
}

- (void)executeAction:(NSString *) actionModel {
    
}

@end
