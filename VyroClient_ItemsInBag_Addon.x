// VyroClient Items in Bag - SAFE VERSION
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern void SpawnItem(void *itemName, int quantity, float x, float y, float z, int colorHue, int colorSat);
extern void* il2cpp_string_new(const char *str);

static void spawn(NSString *item, int qty) {
    @try {
        void *str = il2cpp_string_new([item UTF8String]);
        SpawnItem(str, qty, 0, 0, 0, 0, 0);
    } @catch (NSException *e) {
        NSLog(@"[ItemsInBag] Spawn error: %@", e);
    }
}

static void spawnLater(NSString *item, int qty, double delay) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ spawn(item, qty); });
}

static NSArray* allBags(void) {
    return @[
        @"item_backpack", @"item_backpack_big", @"item_backpack_black", @"item_backpack_cube",
        @"item_backpack_gold", @"item_backpack_green", @"item_backpack_large_base",
        @"item_backpack_large_basketball", @"item_backpack_large_clover", @"item_backpack_mega",
        @"item_backpack_neon", @"item_backpack_pink", @"item_backpack_realistic",
        @"item_backpack_skull", @"item_backpack_small_base", @"item_backpack_white",
        @"item_backpack_with_flashlight"
    ];
}

// NO HOOKS - Just create a button overlay instead
static void addFloatingButton(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        if (!window) return;
        
        // Create floating button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(20, 100, 60, 60);
        btn.backgroundColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.9 alpha:0.9];
        [btn setTitle:@"🎒" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:30];
        btn.layer.cornerRadius = 30;
        btn.clipsToBounds = YES;
        
        [btn addTarget:btn action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        
        // Make it draggable
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:btn action:@selector(handlePan:)];
        [btn addGestureRecognizer:pan];
        
        [window addSubview:btn];
        NSLog(@"[ItemsInBag] Floating button added!");
    });
}

@interface UIButton (ItemsInBag)
- (void)showMenu;
- (void)handlePan:(UIPanGestureRecognizer*)gesture;
@end

@implementation UIButton (ItemsInBag)

- (void)showMenu {
    UIAlertController *menu = [UIAlertController 
        alertControllerWithTitle:@"🎒 Items in Bag" 
        message:@"Choose an option" 
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [menu addAction:[UIAlertAction actionWithTitle:@"Spawn Item IN Bag" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            [self spawnItemInBag];
    }]];
    
    [menu addAction:[UIAlertAction actionWithTitle:@"Spawn All Bags (17)" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSArray *bags = allBags();
            for (NSInteger i = 0; i < bags.count; i++) {
                spawnLater(bags[i], 1, i * 0.08);
            }
    }]];
    
    [menu addAction:[UIAlertAction actionWithTitle:@"Random Bag x5" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSArray *bags = allBags();
            for (int i = 0; i < 5; i++) {
                NSString *randomBag = bags[arc4random_uniform((uint32_t)bags.count)];
                spawnLater(randomBag, 1, i * 0.12);
            }
    }]];
    
    [menu addAction:[UIAlertAction actionWithTitle:@"Cancel" 
        style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    [rootVC presentViewController:menu animated:YES completion:nil];
}

- (void)spawnItemInBag {
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"🎒 Spawn Item IN Bag" 
        message:@"Enter item name" 
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"item_shotgun";
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Spawn" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSString *itemName = alert.textFields[0].text;
            if (itemName && itemName.length > 0) {
                NSArray *bags = allBags();
                NSString *randomBag = bags[arc4random_uniform((uint32_t)bags.count)];
                spawn(randomBag, 1);
                spawnLater(itemName, 1, 0.05);
            }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Spawn 5x" 
        style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSString *itemName = alert.textFields[0].text;
            if (itemName && itemName.length > 0) {
                for (int i = 0; i < 5; i++) {
                    NSArray *bags = allBags();
                    NSString *randomBag = bags[arc4random_uniform((uint32_t)bags.count)];
                    spawnLater(randomBag, 1, i * 0.15);
                    spawnLater(itemName, 1, i * 0.15 + 0.05);
                }
            }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" 
        style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *rootVC = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    while (rootVC.presentedViewController) {
        rootVC = rootVC.presentedViewController;
    }
    [rootVC presentViewController:alert animated:YES completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self.superview];
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self.superview];
    }
}

@end

%ctor {
    NSLog(@"[ItemsInBag] SAFE VERSION - Creating floating button");
    addFloatingButton();
}
