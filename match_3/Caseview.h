//
//  Caseview.h
//  match_3
//
//  Created by 王晰 on 23/02/2026.
//

#import <Cocoa/Cocoa.h> //pour UI
#import "Casemodel.h"

NS_ASSUME_NONNULL_BEGIN
@interface CaseView : NSButton
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger col;

- (void)applyType:(CaseType)type;
- (void)setHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
