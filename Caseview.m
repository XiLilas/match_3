//
//  Caseview.m
//  match_3
//
//  Created by 王晰 on 23/02/2026.
//

#import "Caseview.h"

@implementation CaseView


- (void)applyType:(CaseType)type {
    if (type < 0) return;
    self.wantsLayer = YES; //active CALayer de NSView, afin set couleur de background.
    self.bezelStyle = NSBezelStyleShadowlessSquare; //NSButton existe 1bordure 1ombre par défaut, supprime les afin de voir la couleur d’arrière-plan que nous avons définie.
    self.bordered = NO; //Supprimez le contour par défaut du bouton
    switch (type) {
        case CaseTA:
            self.layer.backgroundColor = NSColor.redColor.CGColor;
            break;
        case CaseTB:
            self.layer.backgroundColor = NSColor.blueColor.CGColor;
            break;
        case CaseTC:
            self.layer.backgroundColor = NSColor.greenColor.CGColor;
            break;
        case CaseTD:
            self.layer.backgroundColor = NSColor.yellowColor.CGColor;
            break;
        case CaseTE:
            self.layer.backgroundColor = NSColor.purpleColor.CGColor;
            break;
        case CaseTF:
            self.layer.backgroundColor = NSColor.orangeColor.CGColor;
            break;
        default: break;
    }
}

// YES : Épaissir et blanchir la bordure ; NO : Rétablir la bordure fine
- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted){
        self.layer.borderWidth = 3;
        self.layer.borderColor = NSColor.whiteColor.CGColor;
    }else{
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = NSColor.clearColor.CGColor; //transparente
    }
}

@end
