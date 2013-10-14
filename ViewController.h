//  ViewController.h
//  DBTutorial
//
//  Created by Raj Kadam on 05/06/13.
//  Copyright (c) 2013 Achal Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ViewController : UIViewController


@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *contactDB;
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *address;
@property (strong, nonatomic) IBOutlet UITextField *phone;
- (IBAction)SaveBtn:(id)sender;
- (IBAction)FindBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *_status;
- (IBAction)DeleteBtn:(id)sender;

@end
