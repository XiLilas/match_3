//
//  Casemodel.h
//  match_3
//
//  Created by 王晰 on 23/02/2026.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CaseType) {
    CaseTA, CaseTB, CaseTC, CaseTD, CaseTE, CaseTF,
    CaseTypeCount = 6
};

@interface CaseModel : NSObject

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger col;
@property (nonatomic, assign) CaseType type;

@end
