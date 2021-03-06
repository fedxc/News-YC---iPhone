//
//  NavigationDeckViewController.m
//  HackerNews
//
//  Created by Benjamin Gordon on 1/10/13.
//  Copyright (c) 2013 Benjamin Gordon. All rights reserved.
//

#import "NavigationDeckViewController.h"

@interface NavigationDeckViewController ()

@end

@implementation NavigationDeckViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Disabling scrollToTop not to interfere with main view's scrollToTop
    [navTable setScrollsToTop:NO];
    
    // Set HeaderBar Color
    //headerBar.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1.0];
    
    // Set Up NotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginOrOut) name:@"DidLoginOrOut" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:@"HideKeyboard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggingIn) name:@"LoggingIn" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Did Login Notification
-(void)didLoginOrOut {
    [navTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)loggingIn {
    UITableViewCell *cell = [navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UIView *blackView = [[UIView alloc] initWithFrame:cell.frame];
    blackView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.90];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(blackView.frame.size.width/2 - 12.5, blackView.frame.size.height/2 - 12.5, 25, 25)];
    activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [blackView addSubview:activity];
    [cell addSubview:blackView];
}

#pragma mark - Share to Social
- (IBAction)didClickShareToFacebook:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                //
            }
            else {
                // It WORKED!
                [self.viewDeckController toggleLeftView];
                [FailedLoadingView launchFailedLoadingInView:self.viewDeckController.centerController.view withImage:[UIImage imageNamed:@"bigCheck-01"] text:@"Successfully shared to Facebook!" duration:1.4];
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        
        controller.completionHandler =myBlock;
        [controller setInitialText:@"For those on the go, that need to stay in the know: Check out this free HN Reader app. https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8"];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        // No Facebook Setup
    }
}

- (IBAction)didClickShareToTwitter:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                //
            }
            else {
                // IT WORKED!
                [self.viewDeckController toggleLeftView];
                [FailedLoadingView launchFailedLoadingInView:self.viewDeckController.centerController.view withImage:[UIImage imageNamed:@"bigCheck-01"] text:@"Successfully shared to Twitter!" duration:1.4];
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        
        controller.completionHandler = myBlock;
        [controller setInitialText:@"For those on the go, that need to stay in the know: Check out this free HN Reader app. https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8"];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        // No Twitter Set Up
    }
}

- (IBAction)didClickShareToEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"news/YC - The iOS HN Reader"];
        [mailViewController setMessageBody:@"Check out this free HN Reader app for iOS: https://itunes.apple.com/us/app/news-yc/id592893508?ls=1&mt=8" isHTML:NO];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else {
        // No email account
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            [self.viewDeckController toggleLeftView];
            [FailedLoadingView launchFailedLoadingInView:self.viewDeckController.centerController.view withImage:[UIImage imageNamed:@"bigCheck-01"] text:@"Successfully shared through Email!" duration:1.4];
        }
    }];
}

#pragma mark - Readability
-(void)didClickReadability {
    SettingsCell *cell = (SettingsCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(kProfile ? 2 : 1) inSection:0]];
    if (cell.readabilityLabel.text.length == 18) {
        [cell.readabilityButton setImage:[UIImage imageNamed:@"nav_readability_on-01.png"] forState:UIControlStateNormal];
        cell.readabilityButton.alpha = 1;
        cell.readabilityLabel.text = @"Readability is ON";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Readability"];
    }
    else {
        [cell.readabilityButton setImage:[UIImage imageNamed:@"nav_readability_off-01.png"] forState:UIControlStateNormal];
        cell.readabilityButton.alpha = 0.5;
        cell.readabilityLabel.text = @"Readability is OFF";
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Readability"];
    }
    
}

#pragma mark - Mark As Read
-(void)didClickMarkAsRead {
    SettingsCell *cell = (SettingsCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(kProfile ? 2 : 1) inSection:0]];
    if (cell.markAsReadLabel.text.length == 19) {
        [cell.markAsReadButton setImage:[UIImage imageNamed:@"nav_markasread_on-01.png"] forState:UIControlStateNormal];
        cell.markAsReadButton.alpha = 1;
        cell.markAsReadLabel.text = @"Mark as Read is ON";
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MarkAsRead"];
    }
    else {
        [cell.markAsReadButton setImage:[UIImage imageNamed:@"nav_markasread_off-01.png"] forState:UIControlStateNormal];
        cell.markAsReadButton.alpha = 0.5;
        cell.markAsReadLabel.text = @"Mark as Read is OFF";
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MarkAsRead"];
    }
    
}


#pragma mark - Theme Change
-(void)didClickChangeTheme {
    SettingsCell *cell = (SettingsCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(kProfile ? 2 : 1) inSection:0]];
    if (cell.themeLabel.text.length == 14) {
        [cell.nightModeButton setImage:[UIImage imageNamed:@"nav_daymode_on-01.png"] forState:UIControlStateNormal];
        cell.nightModeButton.alpha = 1;
        cell.themeLabel.text = @"Theme is DAY";
        [[NSUserDefaults standardUserDefaults] setValue:@"Day" forKey:@"Theme"];
    }
    else {
        [cell.nightModeButton setImage:[UIImage imageNamed:@"nav_nightmode_on-01.png"] forState:UIControlStateNormal];
        cell.nightModeButton.alpha = 1;
        cell.themeLabel.text = @"Theme is NIGHT";
        [[NSUserDefaults standardUserDefaults] setValue:@"Night" forKey:@"Theme"];
    }
    
    // Change the theme and notify ViewController
    [[HNSingleton sharedHNSingleton] changeTheme];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeTheme" object:nil];
}


#pragma mark - Profile Login
-(void)login {
    ProfileNotLoggedInCell *cell = (ProfileNotLoggedInCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell.passwordTextField.text.length > 0 && cell.usernameTextField.text.length > 0) {
        [[HNSingleton sharedHNSingleton] loginWithUser:cell.usernameTextField.text password:cell.passwordTextField.text];
    }
    [cell.usernameTextField resignFirstResponder];
    [cell.passwordTextField resignFirstResponder];
}

-(void)logout {
    [[HNSingleton sharedHNSingleton] logout];
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    ProfileNotLoggedInCell *cell = (ProfileNotLoggedInCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (textField == cell.usernameTextField) {
        [cell.passwordTextField becomeFirstResponder];
    }
    else {
        [self login];
    }
    return YES;
}

-(void)hideKeyboard {
    if (![HNSingleton sharedHNSingleton].User && kProfile) {
        ProfileNotLoggedInCell *cell = (ProfileNotLoggedInCell *)[navTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell.usernameTextField resignFirstResponder];
        [cell.passwordTextField resignFirstResponder];
    }
}

#pragma mark - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (kProfile ? 5 : 4);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // FILTER CELL
    if (indexPath.row == kProfile ? 1 : 0) {
        NSString *CellIdentifier = @"FilterCell";
        FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"FilterCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (FilterCell *)view;
                }
            }
        }
        
        [cell setUpCellForActiveFilter];
        
        return cell;
    }
    
    // PROFILE CELL
    else if (indexPath.row == (kProfile ? 0 : 998)) {
        if ([HNSingleton sharedHNSingleton].User) {
            NSString *CellIdentifier = @"ProfileCell";
            ProfileLoggedInCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"ProfileLoggedInCell" owner:nil options:nil];
                for (UIView *view in views) {
                    if([view isKindOfClass:[UITableViewCell class]]) {
                        cell = (ProfileLoggedInCell *)view;
                    }
                }
            }
            
            cell.userLabel.text = [HNSingleton sharedHNSingleton].User.Username;
            cell.karmaLabel.text = [NSString stringWithFormat:@"%d Karma", [HNSingleton sharedHNSingleton].User.Karma];
            
            return cell;
        }
        else {
            NSString *CellIdentifier = @"ProfileCell";
            ProfileNotLoggedInCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"ProfileNotLoggedInCell" owner:nil options:nil];
                for (UIView *view in views) {
                    if([view isKindOfClass:[UITableViewCell class]]) {
                        cell = (ProfileNotLoggedInCell *)view;
                    }
                }
            }
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]) {
                cell.usernameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
            }
            
            cell.usernameTextField.delegate = self;
            cell.passwordTextField.delegate = self;
            [cell.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
            cell.loginButton.layer.cornerRadius = 10;
            [Helpers makeShadowForView:cell.loginButton withRadius:10];
            
            return cell;
        }
    }

    // SHARE CELL
    else if (indexPath.row == (kProfile ? 3 : 2)) {
        NSString *CellIdentifier = @"ShareCell";
        ShareCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"ShareCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (ShareCell *)view;
                }
            }
        }
        [cell.fbButton addTarget:self action:@selector(didClickShareToFacebook:) forControlEvents:UIControlEventTouchUpInside];
        [cell.twitterButton addTarget:self action:@selector(didClickShareToTwitter:) forControlEvents:UIControlEventTouchUpInside];
        [cell.emailButton addTarget:self action:@selector(didClickShareToEmail:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    // SETTINGS CELL
    else if (indexPath.row == (kProfile ? 2 : 1)) {
        NSString *CellIdentifier = @"SettingsCell";
        SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"SettingsCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (SettingsCell *)view;
                }
            }
        }

        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Readability"]) {
            [cell.readabilityButton setImage:[UIImage imageNamed:@"nav_readability_on-01.png"] forState:UIControlStateNormal];
            cell.readabilityButton.alpha = 1;
            cell.readabilityLabel.text = @"Readability is ON";
        }
        else {
            [cell.readabilityButton setImage:[UIImage imageNamed:@"nav_readability_off-01.png"] forState:UIControlStateNormal];
            cell.readabilityButton.alpha = 0.5;
            cell.readabilityLabel.text = @"Readability is OFF";
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MarkAsRead"]) {
            [cell.markAsReadButton setImage:[UIImage imageNamed:@"nav_markasread_on-01.png"] forState:UIControlStateNormal];
            cell.markAsReadButton.alpha = 1;
            cell.markAsReadLabel.text = @"Mark as Read is ON";
        }
        else {
            [cell.markAsReadButton setImage:[UIImage imageNamed:@"nav_markasread_off-01.png"] forState:UIControlStateNormal];
            cell.markAsReadButton.alpha = 0.5;
            cell.markAsReadLabel.text = @"Mark as Read is OFF";
        }
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"Theme"] isEqualToString:@"Night"]) {
            [cell.nightModeButton setImage:[UIImage imageNamed:@"nav_nightmode_on-01.png"] forState:UIControlStateNormal];
            cell.nightModeButton.alpha = 1;
            cell.themeLabel.text = @"Theme is NIGHT";
        }
        else {
            [cell.nightModeButton setImage:[UIImage imageNamed:@"nav_daymode_on-01.png"] forState:UIControlStateNormal];
            cell.nightModeButton.alpha = 1;
            cell.themeLabel.text = @"Theme is DAY";
        }
        
        [cell.readabilityButton addTarget:self action:@selector(didClickReadability) forControlEvents:UIControlEventTouchUpInside];
        [cell.readabilityHidden addTarget:self action:@selector(didClickReadability) forControlEvents:UIControlEventTouchUpInside];
        [cell.markAsReadButton addTarget:self action:@selector(didClickMarkAsRead) forControlEvents:UIControlEventTouchUpInside];
        [cell.markAsReadHidden addTarget:self action:@selector(didClickMarkAsRead) forControlEvents:UIControlEventTouchUpInside];
        [cell.nightModeButton addTarget:self action:@selector(didClickChangeTheme) forControlEvents:UIControlEventTouchUpInside];
        [cell.themeHidden addTarget:self action:@selector(didClickChangeTheme) forControlEvents:UIControlEventTouchUpInside];
        if (kProfile) {
            // If a User is Logged In
            if ([HNSingleton sharedHNSingleton].User) {
                cell.logoutLabel.text = [NSString stringWithFormat:@"Logout %@", [HNSingleton sharedHNSingleton].User.Username];
                [cell.logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
                [cell.logoutHidden addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                cell.logoutLabel.hidden = YES;
                cell.logoutButton.hidden = YES;
                cell.logoutHidden.hidden = YES;
            }
        }
        else {
            cell.logoutButton.hidden = YES;
            cell.logoutHidden.hidden = YES;
            cell.logoutLabel.hidden = YES;
        }
        
        return cell;
    }
    
    // CREDITS CELL
    else if (indexPath.row == (kProfile ? 4 : 3)) {
        NSString *CellIdentifier = @"CreditsCell";
        CreditsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"CreditsCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (CreditsCell *)view;
                }
            }
        }

        return cell;
    }

    return nil;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kProfile ? 1 : 0) {
        return kFilterCellHeight;
    }
    else if (indexPath.row == (kProfile ? 0 : 998)) {
        if ([HNSingleton sharedHNSingleton].User) {
            return kCellProfLoggedInHeight;
        }
        return kCellProfNotLoggedInHeight;
    }
    else if (indexPath.row == (kProfile ? 2 : 1)) {
        if ([HNSingleton sharedHNSingleton].User) {
            return kCellSettingsLoggedInHeight;
        }
        return kCellSettingsHeight;
    }
    else if (indexPath.row == (kProfile ? 3 : 2)) {
        return kCellShareHeight;
    }
    else {
        return kCellCreditsHeight;
    }
}



@end
