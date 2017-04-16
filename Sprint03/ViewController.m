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

@interface ViewController ()

@end

@implementation ViewController

NSArray *dataArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    dataArray = [[NSArray alloc]init];
    [self RetrieveInfo];
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

- (void)RetrieveInfo
{
    HTTPCommunication *http = [[HTTPCommunication alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/iLyaTkachev/Sprint02/master/Sprint01ARC/File.json"];
    
    // получаем info
    [http retrieveURL:url myBlock:^(NSArray *array)
     {
         dataArray=array;
         [self.myTableView reloadData];
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
    [self RetrieveInfo];
}


@end
