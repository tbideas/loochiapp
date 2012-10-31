//
//  LOOEnchantmentEditorViewController.h
//  Loochi
//
//  Created by Thomas SARLANDIE on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "LOOLightClient.h"
#import "LOOEnchantmentDetailsEditorViewController.h"

@interface LOOEnchantmentEditorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,
                                                                LOOLightClient, LOOEnchantmentDetailsEditorDelegate>

@property (strong) NSMutableArray *enchantments;
@property (strong) LOOLamp *lamp;

@property (weak) IBOutlet UITableView *enchantmentsTableView;

- (IBAction)doneButton:(id) sender;
- (IBAction)addButton:(id) sender;
- (IBAction)editButton:(id)sender;
- (IBAction)playButton:(id)sender;
- (IBAction)shareButton:(id)sender;

@end
