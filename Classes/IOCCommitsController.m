#import "IOCCommitsController.h"
#import "CommitController.h"
#import "CommitCell.h"
#import "GHCommits.h"
#import "GHCommit.h"
#import "iOctocat.h"
#import "NSString+Extensions.h"
#import "IOCResourceStatusCell.h"
#import "SVProgressHUD.h"


@interface IOCCommitsController ()
@property(nonatomic,strong)GHCommits *commits;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@end


@implementation IOCCommitsController

- (id)initWithCommits:(GHCommits *)commits {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.commits = commits;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Commits";
	if (!self.commits.resourcePath.isEmpty) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	}
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.commits name:@"users"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.commits.isUnloaded) {
		[self.commits loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[self.tableView reloadData];
		}];
	} else if (self.commits.isChanged) {
		[self.tableView reloadData];
	}
}

#pragma mark Helpers

- (BOOL)resourceHasData {
	return !self.commits.isEmpty;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[SVProgressHUD showWithStatus:@"Reloading…"];
	[self.commits loadWithParams:nil success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.resourceHasData ? self.commits.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return self.statusCell;
	CommitCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommitCellIdentifier];
	if (cell == nil) cell = [CommitCell cell];
	cell.commit = self.commits[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return;
	GHCommit *commit = self.commits[indexPath.row];
	CommitController *viewController = [[CommitController alloc] initWithCommit:commit];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end