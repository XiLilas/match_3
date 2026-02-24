//
//  Gameboard.m
//  match_3
//
//  Created by 王晰 on 23/02/2026.
//

#import "Gameboard.h"

@interface GameBoard ()
//@property (nonatomic, assign, readwrite) NSInteger size;
@property (nonatomic, strong, readwrite) NSMutableArray<NSMutableArray<CaseModel *> *> *grid;
@end

@implementation GameBoard

// init score=0，arc4random_uniform type tel qu'il ne match pas, remplir la case puis la ligne puis la grille.
- (instancetype)init{
    if (self = [super init]) {
        self.score = 0;
        self.grid = [NSMutableArray arrayWithCapacity:BOARD_SIZE];
        for (NSInteger i=0 ; i<BOARD_SIZE; i++) {
            NSMutableArray<CaseModel *> *row = [NSMutableArray arrayWithCapacity:BOARD_SIZE];
            for (NSInteger j=0; j<BOARD_SIZE; j++) {
                CaseModel *c = [CaseModel new];
                c.row = i;
                c.col = j;
                do {
                    c.type = (CaseType)arc4random_uniform(CASE_TYPE_COUNT);
                } while ([self createsMatchAtRow:i col:j type:c.type inTempRow:row]);
                [row addObject:c];
            }
            [self.grid addObject:row];
        }
    }
    return self;
}



// Vérifier si la correspondance (ligne, colonne) et le type permettent
// une alignement horizontal ou vertical.
// Horizontal : tempRow (deux lignes à gauche) ; Vertical : grid (deux lignes du haut)
- (BOOL)createsMatchAtRow:(NSInteger)row col:(NSInteger)col type:(CaseType)type inTempRow:(NSArray<CaseModel *> *)tempRow {
    // ...
    if (col>=2) {
        if (((CaseModel *)tempRow[col-1]).type == type &&
            ((CaseModel *)tempRow[col-2]).type == type) {
            return YES;
        }
    }
    if (row >= 2) {
        if (((CaseModel *)_grid[row-1][col]).type == type &&
            ((CaseModel *)_grid[row-2][col]).type == type){
            return YES;
        }
    }
    return NO;
}

// Vérifier les paires adjacentes -> échanger -> trouver les correspondances
// -> si aucune n'est trouvée, annuler et renvoyer NON.
- (BOOL)trySwapRow1:(NSInteger)r1 col1:(NSInteger)c1 row2:(NSInteger)r2 col2:(NSInteger)c2 {
    BOOL adjacent = (r1 == r2 && ABS(c1-c2) == 1) || (c1 == c2 && ABS(r1-r2) == 1);
    if (!adjacent) return NO;
    
    CaseModel *a = self.grid[r1][c1];
    CaseModel *b = self.grid[r2][c2];
    self.grid[r1][c1] = b;
    self.grid[r2][c2] = a;
    
    BOOL match = [self findMatches].count > 0;
    if (!match) {
        self.grid[r1][c1] = a;
        self.grid[r2][c2] = b;
        a.row = r1; a.col = c1;
        b.row = r2; b.col = c2;
    }
    return match;
}

// Parcourt toutes les positions et trouve trois lignes ou colonnes consécutives du même type.
// Renvoie un NSSet<NSValue*>, où chaque NSValue encapsule un NSPoint(ligne, colonne).
- (NSMutableSet<NSValue *> *)findMatches {
    // ...
    NSMutableSet<NSValue *> *matched = [NSMutableSet set];
    for (NSInteger i=0; i<BOARD_SIZE; i++) {
        for (NSInteger j=0; j<BOARD_SIZE; j++){
            CaseType type = ((CaseModel *)_grid[i][j]).type;
            if (j+2<BOARD_SIZE && ((CaseModel *)_grid[i][j+1]).type == type &&
                ((CaseModel *)_grid[i][j+2]).type == type) {
                [matched addObject:[NSValue valueWithPoint:NSMakePoint(i, j)]];
                [matched addObject:[NSValue valueWithPoint:NSMakePoint(i, j+1)]];
                [matched addObject:[NSValue valueWithPoint:NSMakePoint(i, j+2)]];
            }
            if (i+2 < BOARD_SIZE && ((CaseModel *)_grid[i+1][j]).type == type &&
                ((CaseModel *)_grid[i+2][j]).type == type) {
                [matched addObject:[NSValue valueWithPoint:NSMakePoint(i, j)]];
                [matched addObject:[NSValue valueWithPoint:NSMakePoint(i+1, j)]];
                [matched addObject:[NSValue valueWithPoint:NSMakePoint(i+2, j)]];
            }
        }
    }
    return matched;
}

// while(have match)：type=-1 -> colonne descends -> remplie en haut des nouvelles cases → score += count*10
- (void)resolve {
    NSMutableSet<NSValue *> *matched = [self findMatches];
    while (matched.count > 0) {
        _score += matched.count * 10;
        for (NSValue *v in matched){
            NSPoint p = v.pointValue;
            ((CaseModel *)_grid[(NSInteger) p.x][(NSInteger)p.y]).type = -1;
        }
        for (NSInteger c = 0; c < BOARD_SIZE; c++) {
            NSInteger writeRow = BOARD_SIZE - 1;
            for (NSInteger r = BOARD_SIZE - 1; r >= 0; r--) {
                if (((CaseModel *)_grid[r][c]).type != -1) {
                    ((CaseModel *)_grid[writeRow][c]).type = ((CaseModel *)_grid[r][c]).type;
                    if (r != writeRow) ((CaseModel *)_grid[r][c]).type = -1;
                    writeRow--;
                }
            }
            for (NSInteger r = writeRow; r >= 0; r--) {
                ((CaseModel *)_grid[r][c]).type = (CaseType)arc4random_uniform(CASE_TYPE_COUNT);
            }
        }
        matched = [self findMatches];
    }
}

@end
