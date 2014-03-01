//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Enio on 08/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"


@implementation Gameplay{
    //CCPhysicsNode *_physicsNode;
    //CCNode *_catapultArm;
}
    // is called when CCB file has completed loading
    - (void)didLoadFromCCB {
        //CCLOG(@"Aqui eu to!!!!!!");
        // tell this scene to accept touches
        self.userInteractionEnabled = TRUE;
        CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
        [_levelNode addChild:level];
        
        // visualize physics bodies & joints
        _physicsNode.debugDraw = TRUE;
        
        // catapultArm and catapult shall not collide
        [_catapultArm.physicsBody setCollisionGroup:_catapult];
        [_catapult.physicsBody setCollisionGroup:_catapult];
        
        // create a joint to connect the catapult arm with the catapult
        _catapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_catapultArm.physicsBody bodyB:_catapult.physicsBody anchorA:_catapultArm.anchorPointInPoints];
        
        // nothing shall collide with our invisible nodes
        _pullbackNode.physicsBody.collisionMask = @[];
        // create a spring joint for bringing arm in upright position and snapping back when player shoots
        _pullbackJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_pullbackNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:60.f stiffness:100.f damping:20.f];
        
        _mouseJointNode.physicsBody.collisionMask = @[];
        
        _physicsNode.collisionDelegate = self;
        
    }

    -(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
    {
        float energy = [pair totalKineticEnergy];
        
        // if energy is large enough, remove the seal
        if (energy > 5000.f)
        {
            [self sealRemoved:nodeA];
        }
    }

    - (void)sealRemoved:(CCNode *)seal {
        [seal removeFromParent];
    }

    // called on every touch in this scene
//    - (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
//        [self launchPenguin];
//    }

    -(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
        CGPoint touchLocation = [touch locationInNode:_contentNode];
    
        // start catapult dragging when a touch inside of the catapult arm occurs
        if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation))
        {
            // move the mouseJointNode to the touch position
            _mouseJointNode.position = touchLocation;
        
            // setup a spring joint between the mouseJointNode and the catapultArm
            _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
            
            // create a penguin from the ccb-file
            _currentPenguin = [CCBReader load:@"Penguin"];
            // initially position it on the scoop. 34,138 is the position in the node space of the _catapultArm
            CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
            // transform the world position to the node space to which the penguin will be added (_physicsNode)
            _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
            // add it to the physics world
            [_physicsNode addChild:_currentPenguin];
            // we don't want the penguin to rotate in the scoop
            _currentPenguin.physicsBody.allowsRotation = FALSE;
            
            // create a joint to keep the penguin fixed to the scoop until the catapult is released
            _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
            
        }
    }

    - (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
        // whenever touches move, update the position of the mouseJointNode to the touch position
        CGPoint touchLocation = [touch locationInNode:_contentNode];
        _mouseJointNode.position = touchLocation;
    }

    - (void)releaseCatapult {
        if (_mouseJoint != nil)
        {
            // releases the joint and lets the catapult snap back
            [_mouseJoint invalidate];
            _mouseJoint = nil;
            
            // releases the joint and lets the penguin fly
            [_penguinCatapultJoint invalidate];
            _penguinCatapultJoint = nil;
            
            // after snapping rotation is fine
            _currentPenguin.physicsBody.allowsRotation = TRUE;
            
            // follow the flying penguin
            CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
            [_contentNode runAction:follow];
        }
    }

    -(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
        // when touches end, meaning the user releases their finger, release the catapult
        [self releaseCatapult];
    }

    -(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
        // when touches are cancelled, meaning the user drags their finger off the screen or onto something else, release the catapult
        [self releaseCatapult];
    }

    - (void)launchPenguin {
        CCLOG(@"Arremesso de penguin");
        // loads the Penguin.ccb we have set up in Spritebuilder
        CCNode* penguin = [CCBReader load:@"Penguin"];
        
        //CCLOG(@"posiciono pinguin na catapulta");
        // position the penguin at the bowl of the catapult
        penguin.position = ccpAdd(_catapultArm.position, ccp(20, 120));
        //penguin.position = ccp(50,0);
        
        //CCLOG(@"adicionar fisica ao pinguin");
        // add the penguin to the physicsNode of this scene (because it has physics enabled)
        [_physicsNode addChild:penguin];
        
        //CCLOG(@"criar e aplicar forca ao pinguin");
        // manually create & apply a force to launch the penguin
        CGPoint launchDirection = ccp(1, 0);
        CGPoint force = ccpMult(launchDirection, 8000);
        [penguin.physicsBody applyForce:force];
        
        // ensure followed object is in visible are when starting
        self.position = ccp(0, 0);
        CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
        [_contentNode runAction:follow];
    }



    - (void)retry {
        // reload this level
        [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
    }

@end