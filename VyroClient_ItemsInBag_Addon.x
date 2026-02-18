// VyroClient Items in Bag Spawner Addon - FINAL FIX
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface ACPanView : UIView
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
- (void)setupUI;
- (void)addItemsInBagSection;
@end

extern void SpawnItem(void *itemName, int quantity, float x, float y, float z, int colorHue, int colorSat);
extern void* il2cpp_string_new(const char *str);

static void spawn(NSString *item, int qty) {
    void *str = il2cpp_string_new([item UTF8String]);
    SpawnItem(str, qty, 0, 0, 0, 0, 0);
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
        @"item_backpack_skull", @"item_backpack_
