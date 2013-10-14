//
//  ViewController.m
//  DBTutorial
//
//  Created by Raj Kadam on 05/06/13.
//  Copyright (c) 2013 Achal Patel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize _status;
@synthesize name;
@synthesize address;
@synthesize phone;
//@synthesize contactDB;


/*

 1. Identifies the application’s Documents directory and constructs a path to the contacts.db database file.
 2. Creates an NSFileManager instance and subsequently uses it to detect if the database file already exists.
 3. If the file does not yet exist the code converts the path to a UTF-8 string and creates the database via a call to the SQLite sqlite3_open() function, passing through a reference to the contactDB variable declared previously in the interface file.
 4. Prepares a SQL statement to create the contacts table in the database.
 5. Reports the success or otherwise of the operation via the status label.
 6. Closes the database.


*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"Contact.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)";
            
            if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                _status.text = @"Failed to create table";
            }
            sqlite3_close(_contactDB);
        } else {
            _status.text = @"Failed to open/create database";
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return [textField resignFirstResponder];
}

- (IBAction)SaveBtn:(id)sender {
    
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (name.text.length !=0 && address.text.length !=0 && phone.text.length !=0) {
        
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO CONTACT (name, address, phone) VALUES (\"%@\", \"%@\", \"%@\")",
                               self.name.text, self.address.text, self.phone.text];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            self._status.text = @"Contact added";
            self.name.text = @"";
            self.address.text = @"";
            self.phone.text = @"";
        } else {
            self._status.text = @"Failed to add contact";
        }
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
    }else{
        self._status.text = @"Insert complete info";
    }

}

- (IBAction)FindBtn:(id)sender {
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT address, phone FROM contact WHERE name=\"%@\"",
                              self.name.text];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *addressField = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(
                                                                             statement, 0)];
                self.address.text = addressField;
                NSString *phoneField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 1)];
                self.phone.text = phoneField;
                _status.text = @"Match found";
            } else {
                _status.text = @"Match not found";
                self.address.text = @"";
                self.phone.text = @"";
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
    }

}

-(Boolean)checkRow{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT address, phone FROM contact WHERE name=\"%@\"",
                              self.name.text];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *addressField = [[NSString alloc]
                                          initWithUTF8String:
                                          (const char *) sqlite3_column_text(
                                                                             statement, 0)];
                //self.address.text = addressField;
                NSString *phoneField = [[NSString alloc]
                                        initWithUTF8String:(const char *)
                                        sqlite3_column_text(statement, 1)];
                //self.phone.text = phoneField;
                _status.text = @"Match found";
                sqlite3_finalize(statement);
                sqlite3_close(_contactDB);
                return true;
            } else {
                _status.text = @"Match not found";
                self.address.text = @"";
                self.phone.text = @"";
                sqlite3_finalize(statement);
                sqlite3_close(_contactDB);
                return false;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_contactDB);
    }

}

- (IBAction)DeleteBtn:(id)sender {
    
    //NSString *strPath=[self destinationPath];
    
    const char *dbPath=[_databasePath UTF8String];
    NSString * nm = self.name.text;
    
    //sqlite3_stmt *statement;
    if ([self checkRow]) {
        
    
    if(sqlite3_open(dbPath, &_contactDB)==SQLITE_OK)
    {
        NSString *q=[NSString stringWithFormat: @"delete from contact where name= \"%@\"",nm];
        const char *sqlQuery =[q UTF8String];
        sqlite3_stmt *queryStatement;
        
        //prepare sql stmt ready for execution
        sqlite3_prepare_v2(_contactDB, sqlQuery, -1, &queryStatement, NULL);
        if (sqlite3_step(queryStatement) == SQLITE_DONE)//Executes a SQL statement previously prepared
        {
                _status.text = @"record deleted";
                name.text = @"";
                phone.text = @"";
                address.text = @"";
          // _status.text = (@"record deleted");
            //name.text = @"";
        }
        else
        {
           _status.text = (@"Failed to del");
            //  NSAssert1(0, @"Error while deleting data. '%s'", sqlite3_errmsg(mojivaDB));
            NSLog(@"ERROR");
            //status.text = @"Failed to add contact";
        }
        sqlite3_finalize(queryStatement);//deleted previously created stmt
        sqlite3_close(_contactDB);
    }
    }else{
        _status.text = (@"Invalid Row ");
    }
}
@end
