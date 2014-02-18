//
//  ViewController.m
//  PlayingAreaBoundsDemo
//
//  Created by Craig Hagerman on 2/16/14.
//  Copyright (c) 2014 Craig Hagerman. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController


- (void)viewDidLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //Configure the view
    SKView *skView = (SKView *)self.view;
    
    // set the view only once
    if ( !skView.scene ) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        NSLog(@"width: %f", skView.bounds.size.width);
        NSLog(@"height: %f", skView.bounds.size.height);
        
        // Present the scene.
        [skView presentScene:scene];
    }
}





- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
