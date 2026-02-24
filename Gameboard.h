//
//  Gameboard.h
//  match_3
//
//  Created by 王晰 on 23/02/2026.
//

#import <Foundation/Foundation.h>
#import "Casemodel.h"

#define BOARD_SIZE 8
#define CASE_TYPE_COUNT 6

@interface GameBoard : NSObject
//@property (nonatomic, assign, readonly) NSInteger size;
@property (nonatomic, strong, readonly) NSMutableArray<NSMutableArray<CaseModel *> *> *grid;
@property (nonatomic, assign) NSInteger score;

- (instancetype)init;
//- (void)resetBoard;
- (BOOL)trySwapRow1:(NSInteger)r1 col1:(NSInteger)c1 row2:(NSInteger)r2 col2:(NSInteger)c2;
- (void)resolve;
@end
