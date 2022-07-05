

#import "THBEditor.h"




@interface THBEditor () {

}

//@property (nonatomic) THBData *data;
//@property (nonatomic) THBEditModel *editModel;

@end

@implementation THBEditor


#pragma mark - init
- (void)install:(THBData *)data editModel:(THBEditModel *)editModel {
    self.editModel = editModel;
    self.data = data;
}



- (void)uninstall {

}







@end
