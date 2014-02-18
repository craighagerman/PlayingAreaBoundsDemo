//
//  MyScene.m
//  PlayingAreaBoundsDemo
//
//  Created by Craig Hagerman on 2/16/14.
//  Copyright (c) 2014 Craig Hagerman. All rights reserved.
//

#import "MyScene.h"

static NSString * const movable = @"movable"; // to identify movable nodes

static const uint32_t ballCategory  = 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t topCategory = 0x1 << 1; // 00000000000000000000000000000010


@interface MyScene()
@property (nonatomic, strong) SKSpriteNode *selectedNode;

@end


@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        // Setup scene here

        self.backgroundColor = [SKColor colorWithRed:0.68 green:0.03 blue:0.30 alpha:1.0];
        
        // Create and place a lable
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        myLabel.text = @"Testing Playing Area Bounds";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        [self addChild:myLabel];
        
        
        // Loading the top element as a node
        SKSpriteNode *top = [SKSpriteNode spriteNodeWithImageNamed:@"top"];
        [top setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 250.0)];
        top.zPosition = 1;
        top.physicsBody =  [SKPhysicsBody bodyWithRectangleOfSize:top.frame.size];
        top.physicsBody.dynamic = NO;
        top.physicsBody.categoryBitMask = topCategory;
        top.physicsBody.contactTestBitMask = ballCategory;
        top.physicsBody.collisionBitMask = 0;       // 0 = OK for other nodes to pass over each other
        [self addChild:top];
        
        // Create a ball using SKShape Node
        SKShapeNode *ball = [[SKShapeNode alloc] init];
        CGMutablePathRef myPath = CGPathCreateMutable();
        CGPathAddArc(myPath, NULL, 0,0, 15, 0, M_PI*2, YES);
        ball.path = myPath;
        ball.lineWidth = 1;
        ball.fillColor = [SKColor blueColor];
        ball.zPosition = 2;
        
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
        top.physicsBody.dynamic = NO;
        ball.physicsBody.categoryBitMask = ballCategory;
        ball.physicsBody.contactTestBitMask = topCategory;
        ball.physicsBody.collisionBitMask = 0;
        
        [ball setName:movable];
        [ball setPosition:CGPointMake(150, self.size.height - 150)];
        
        ball.userData = [NSMutableDictionary dictionary];
        [ball.userData setValue:[NSValue valueWithCGPoint:ball.position] forKey:@"startingPosition"];
        [ball.userData setValue:[NSNumber numberWithBool:FALSE] forKey:@"onMat"];
        
        [self addChild:ball];
        
        
        // Create a ball sprite using an image without userData settings (ie. won't 'snap back')
        SKSpriteNode *ball2 = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
        [ball2 setName:movable];
        [ball2 setPosition:CGPointMake(300, 630)];
        ball2.zPosition = 2;
        
        ball2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball2.frame.size.width/2];
        ball2.physicsBody.categoryBitMask = ballCategory;
        ball2.physicsBody.contactTestBitMask = topCategory;
        ball2.physicsBody.collisionBitMask = 0;
        
        [self addChild:ball2];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}







-(void)didBeginContact:(SKPhysicsContact*)contact
{
    // Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    // react to the contact between ball and top
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == topCategory) {
        NSLog(@"ball + top contact");
    }
}


-(void)didEndContact:(SKPhysicsContact *)contact
{
    // Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    // react to the contact between ball and top
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == topCategory) {
        firstBody.collisionBitMask = topCategory;
        [firstBody.node.userData setValue:[NSNumber numberWithBool:TRUE] forKey:@"onMat"];
    }
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    [self selectNodeForTouch:positionInScene];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint positionInScene = [[touches anyObject] locationInNode:self];
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:positionInScene];
    
    if ( [[touchedNode.userData valueForKey:@"onMat"] isEqual:[NSNumber numberWithBool:FALSE]] ) {
        CGPoint cgp = [[touchedNode.userData valueForKey:@"startingPosition"] CGPointValue];
        [touchedNode setPosition:cgp];
    }
}


// get the touch from the touches set. Then convert the touch location to the location in a specific node
- (void)selectNodeForTouch:(CGPoint)touchLocation
{
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    // check if node is a new node, or the one previously touched (in which case do nothing)
    if(![_selectedNode isEqual:touchedNode]) {
        [_selectedNode removeAllActions];
        //[_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
        _selectedNode = touchedNode;
    }
}



// get the touch and convert it‘s position to the position in your scene.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    CGPoint previousPosition = [touch previousLocationInNode:self];
    
    CGPoint translation = CGPointMake(positionInScene.x - previousPosition.x, positionInScene.y - previousPosition.y);
    //NSLog(@"New position X: %f,  Y: %f", positionInScene.x, positionInScene.y  );
    [self panForTranslation:translation];
}


// check if _selectedNode is an animal node and sets the position based on a passed-in translation.
- (void)panForTranslation:(CGPoint)translation
{
    CGPoint position = [_selectedNode position];
    if([[_selectedNode name] isEqualToString:movable]) {
        [_selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
    }
}





-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end
