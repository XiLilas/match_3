//
//  ViewController.m
//  match_3
//
//  Created by 王晰 on 23/02/2026.
//

#import "ViewController.h"
#import "Gameboard.h"
#import "Caseview.h"

#define TILE_SIZE 56.0  // pixels size of each case

@interface ViewController ()
@property (nonatomic, strong) GameBoard *board;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<CaseView *> *> *caseViews;
@property (nonatomic, strong) NSTextField *scoreLabel;
@property (nonatomic, assign) NSInteger selectedRow;  // -1 = not selected
@property (nonatomic, assign) NSInteger selectedCol;

@property (nonatomic, strong) NSButton *startButton;
@property (nonatomic, strong) NSTextField *timerLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeLeft;
@property (nonatomic, assign) BOOL gameActive;

@end


@implementation ViewController

// initialement : selectedRow = selectedCol = -1
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.selectedRow = -1;
    self.selectedCol = -1;
}

// Appelée lors de l'affichage de la fenêtre, créant l'échiquier，
// tous les boutons et le score.
- (void)viewDidAppear {
    [super viewDidAppear];
    if (self.caseViews) return ;

    self.board = [[GameBoard alloc] init];
    self.caseViews = [NSMutableArray arrayWithCapacity:BOARD_SIZE];
    
    for (NSInteger i=0; i<BOARD_SIZE; i++) {
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:BOARD_SIZE];
        for (NSInteger j = 0; j < BOARD_SIZE; j++) {
            CaseView *cv = [[CaseView alloc] init];
            cv.row = i;
            cv.col = j;
            cv.target = self;
            cv.action = @selector(caseTapped:);
            NSInteger flippedR = BOARD_SIZE -1 - i;
            cv.frame = CGRectMake(j * TILE_SIZE, flippedR * TILE_SIZE, TILE_SIZE, TILE_SIZE);
            [self.view addSubview:cv];
            [row addObject:cv];
        }
        [self.caseViews addObject:row];
    }
    self.scoreLabel = [NSTextField labelWithString:@"Score: 0"];
    self.scoreLabel.frame = CGRectMake(0, BOARD_SIZE * TILE_SIZE + 10, 200, 30);
    self.scoreLabel.font = [NSFont boldSystemFontOfSize:18];
    [self.view addSubview:self.scoreLabel];
    
    // Start Button
    self.startButton = [NSButton buttonWithTitle:@"Start" target:self action:@selector(startGame)];
    self.startButton.frame = CGRectMake(220, BOARD_SIZE * TILE_SIZE + 10, 100, 30);
    [self.view addSubview:self.startButton];
    
    //Time left
    self.timerLabel = [NSTextField labelWithString:@"20s"];
    self.timerLabel.frame = CGRectMake(0, BOARD_SIZE * TILE_SIZE + 50, 200, 30);
    self.timerLabel.font = [NSFont boldSystemFontOfSize:18];
    [self.view addSubview:self.timerLabel];

    [self renderBoard];
}

// Start/Reset Timer label
- (void)startGame {
    self.board = [[GameBoard alloc] init];
    self.timeLeft = 20;
    self.gameActive = YES;
    [self renderBoard];
    [self updateScore];
    self.timerLabel.stringValue = @"20s";
    [self.timer invalidate];  // 停掉旧的timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

// chaque seconde
- (void)tick {
    self.timeLeft--;
    self.timerLabel.stringValue = [NSString stringWithFormat:@"%lds", self.timeLeft];
    if (self.timeLeft <= 0) {
        [self endGame];
    }
}

- (void)endGame {
    [self.timer invalidate];
    self.timer = nil;
    self.gameActive = NO;
    self.timerLabel.stringValue = @"Fini!";
    // Final score
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Partie terminée!";
    alert.informativeText = [NSString stringWithFormat:@"Score final: %ld", self.board.score];
    [alert addButtonWithTitle:@"Rejouer"];
    [alert addButtonWithTitle:@"Terminer"];
    [alert runModal];
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
        [self startGame];  // pour Rejouer
    }
}


// Lire les données de board.grid et mettre à jour la couleur de chaque bouton.
- (void)renderBoard {
    for (NSInteger i = 0; i < BOARD_SIZE; i++) {
        for (NSInteger j = 0; j < BOARD_SIZE; j++) {
            CaseModel *c = self.board.grid[i][j];
            CaseView *cv = self.caseViews[i][j];
            [cv applyType:c.type];
        }
    }
}


- (void)updateScore {
    self.scoreLabel.stringValue = [NSString stringWithFormat:@"Score: %ld", self.board.score];
}

// selectedRow==-1 : stocke la position, et hightlight
// si click sur la meme position, annule le hightlight, reset -1
// sinon : annule le hightlight，et trySwap，Swap(Change)Reussie
// alors resolve+render+updateScore，reset -1
- (void)caseTapped:(CaseView *)sender {
    if (!self.gameActive) return; //ne peut pas cliquer si game non start
    if (self.selectedRow == -1) {
        self.selectedRow = sender.row;
        self.selectedCol = sender.col;
        [self highlightRow:sender.row col:sender.col selected:YES];
    } else {
        if (self.selectedRow == sender.row && self.selectedCol == sender.col) {
            [self highlightRow:sender.row col:sender.col selected:NO];
            self.selectedRow = -1;
            self.selectedCol = -1;
            return;
        }
        [self highlightRow:self.selectedRow col:self.selectedCol selected:NO];
        BOOL swapped = [self.board trySwapRow1:self.selectedRow col1:self.selectedCol
                                         row2:sender.row col2:sender.col];
        if (swapped) {
            [self.board resolve];
            [self renderBoard];
            [self updateScore];
        }
        self.selectedRow = -1;
        self.selectedCol = -1;
    }
}


// caseViews[row][col] setHighlighted:selected
// Ajouter ou supprimer la bordure mise en surbrillance d'une cellule spécifique.
- (void)highlightRow:(NSInteger)row col:(NSInteger)col selected:(BOOL)selected {
    CaseView *cv = self.caseViews[row][col];
    [cv setHighlighted:selected];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
