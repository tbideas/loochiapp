//
//  ILScenesViewController.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import <UIKit/UIKit.h>
#import "ILLightClient.h"

@interface ILScenesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ILLightClient>

@property (nonatomic, retain) CLALight *lamp;
@property (nonatomic, weak) IBOutlet UIView *colorView;
@property (nonatomic, weak) IBOutlet UITableView *scenesTablesView;

@end
