#import "CostModel.h"

@implementation CostModel

- (id)init
{
    self = [self init];
    if (self) {
        self.costs = [[NSMutableDictionary alloc] init];
    }
    return self;
}



@end
