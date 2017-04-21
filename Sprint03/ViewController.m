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
#import "Car+CoreDataClass.h"

@interface ViewController ()
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
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
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo =
    [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(MyTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Car *car = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.myTitleLabel.text = car.mark;
    cell.mySubtitleLabel.text = car.model;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:car.logoImage]];
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.myImageView.image=image;
            });
        }
    });

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTableViewCell *cell = (MyTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)retrieveInfo
{
    [self.activityIndicator startAnimating];
    HTTPCommunication *http = [[HTTPCommunication alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/iLyaTkachev/Sprint02/master/Sprint01ARC/File.json"];
    
    // получаем info
    [http retrieveURL:url myBlock:^(NSArray *array)
     {
         dataArray=array;
         //[self addCars];
         //[self.myTableView reloadData];
         [self.activityIndicator stopAnimating];
     }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAutoDetail"]) {
        NSIndexPath *indexPath = [self.myTableView indexPathForSelectedRow];
        DetailViewController *detailViewController = segue.destinationViewController;
        Car *car = [self.fetchedResultsController objectAtIndexPath:indexPath];
        detailViewController.titleText = car.mark;
    }
}
- (IBAction)updateClick:(id)sender {
    [self checkCars];
    //[self retrieveInfo];
}

-(void) checkCars
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"Car" inManagedObjectContext:self.context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carID = %d", @"00001"];
    request.predicate = predicate;
    NSError *error = nil;
    NSArray *objs = [self.context executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"no truck find" format:@"%@", [error localizedDescription]];
    }
    if (objs.count > 0) {
        for(Car *object in objs){
            [self.context deleteObject:object];
        }
        }
    else {
        // there's no truck with same id. Use insert method
    }
            [self.context save:&error];
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


///////////////////////////////////////////////////////////////////////////////
//FetchedResultConroller
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Car" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"mark" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.context sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    return self.fetchedResultsController;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.myTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.myTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.myTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.myTableView endUpdates];
}

@end
