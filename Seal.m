//
//  Seal.m
//  PeevedPenguins
//
//  Created by Enio on 08/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

    - (void)didLoadFromCCB {
        self.physicsBody.collisionType = @"seal";
        //CCLOG(@"passei aqui????");
    }


@end
