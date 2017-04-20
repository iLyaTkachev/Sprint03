//
//  ViewController.m
//  Sprint03
//
//  Created by iLya Tkachev on 4/14/17.
//  Copyright © 2017 iLya Tkachev. All rights reserved.
//

#import "ViewController.h"
#import "MyTableViewCell.h"
#import "HTTPCommunication.h"
#import "DetailViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ViewController

NSArray *dataArray;
NSEntityDescription *entity;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    dataArray = [[NSArray alloc]init];
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.context = delegate.managedObjectContext;
    entity = [NSEntityDescription entityForName:@"Car" inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID = %d", @"00001"];
    //request.predicate = predicate;
    NSError *error = nil;
    NSArray *objs = [self.context executeFetchRequest:request error:&error];
    for(NSManagedObject *object in objs){
        NSLog(@"Found %@", [object valueForKey:@"mark"]);
    }

    //[self retrieveInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTableViewCell *cell = (MyTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.myTitleLabel.text=[[dataArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.mySubtitleLabel.text=[[dataArray objectAtIndex:indexPath.row] objectForKey:@"subtitle"];
    //cell.myImageView.image = [UIImage imageNamed:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"image_name"]];
    //[self DownloadImage:cell.myImageView.image URL:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"image_name" ]];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"image_name" ]]];
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.myImageView.image=image;
            });
        }
    });
    
    
    return cell;
}

- (void)retrieveInfo
{
    HTTPCommunication *http = [[HTTPCommunication alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/iLyaTkachev/Sprint02/master/Sprint01ARC/File.json"];
    
    // получаем info
    [http retrieveURL:url myBlock:^(NSArray *array)
     {
         dataArray=array;
         [self addCars];
         //[self.myTableView reloadData];
     }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAutoDetail"]) {
        NSIndexPath *indexPath = [self.myTableView indexPathForSelectedRow];
        DetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.titleText = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    }
}
- (IBAction)updateClick:(id)sender {

    [self retrieveInfo];
}

-(void) checkCars
{
    
}

-(void) addCars
{
    NSError *error=nil;
    for (int i=0;i<dataArray.count; i++) {
        NSManagedObject *newCar=[[NSManagedObject alloc]initWithEntity:entity insertIntoManagedObjectContext:self.context];
        [newCar setValue:[[dataArray objectAtIndex:i] objectForKey:@"title"] forKey:@"mark"];
        [newCar setValue:[[dataArray objectAtIndex:i] objectForKey	:@"subtitle"] forKey:@"model"];
        [newCar setValue:[[dataArray objectAtIndex:i] objectForKey	:@"image_name"] forKey:@"logoImage"];
        [newCar setValue:[[dataArray objectAtIndex:i] objectForKey	:@"ID"] forKey:@"carID"];
        [self.context save:&error];
    }
    }


@end
