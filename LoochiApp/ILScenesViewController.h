//
//  ILScenesViewController.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import <UIKit/UIKit.h>
#import "LOOLightClient.h"

@interface ILScenesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, LOOLightClient>

@property (nonatomic, retain) LOOLamp *lamp;
@property (nonatomic, weak) IBOutlet UIView *colorView;
@property (nonatomic, weak) IBOutlet UITableView *scenesTablesView;

@end
