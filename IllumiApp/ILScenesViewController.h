//
//  ILScenesViewController.h
//  Illumi
//
//  Created by Thomas SARLANDIE on 14/08/12.
//
//

#import <UIKit/UIKit.h>
#import "ILLightClient.h"

@interface ILScenesViewController : UITableViewController<ILLightClient>

@property CLALight *lamp;

@end
