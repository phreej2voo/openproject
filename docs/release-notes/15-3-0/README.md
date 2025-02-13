---
title: OpenProject 15.3.0
sidebar_navigation:
    title: 15.3.0
release_version: 15.3.0
release_date: 2025-02-06
---

# OpenProject 15.3.0

Release date: 2025-02-06

We released OpenProject [OpenProject 15.3.0](https://community.openproject.org/versions/2163).
The release contains several bug fixes and we recommend updating to the newest version.
In these Release Notes, we will give an overview of important feature changes.
At the end, you will find a complete list of all changes and bug fixes.

## Important feature changes

<!-- Inform about the major features in this section -->

## Important updates and breaking changes

<!-- Remove this section if empty, add to it in pull requests linking to tickets and provide information -->

<!--more-->

## Bug fixes and changes

<!-- Warning: Anything within the below lines will be automatically removed by the release script -->
<!-- BEGIN AUTOMATED SECTION -->

- Feature: Cost reports should include work package children \[[#32813](https://community.openproject.org/wp/32813)\]
- Feature: Create recurring meetings with flexible schedules \[[#54188](https://community.openproject.org/wp/54188)\]
- Feature: Meeting templates for recurring meetings \[[#54752](https://community.openproject.org/wp/54752)\]
- Feature: Iterations of recurring meetings \[[#58225](https://community.openproject.org/wp/58225)\]
- Feature: Overview page for a recurring meeting \[[#58226](https://community.openproject.org/wp/58226)\]
- Feature: Show recurring meetings in the meeting index page \[[#58227](https://community.openproject.org/wp/58227)\]
- Feature: Indicate that there are work package relations which the user has no permission to see \[[#58427](https://community.openproject.org/wp/58427)\]
- Feature: Deletion dialog with danger zone for deleting items in a hierarchy \[[#58637](https://community.openproject.org/wp/58637)\]
- Feature: Store token exchange capability on OIDC providers \[[#58862](https://community.openproject.org/wp/58862)\]
- Feature: Allow entering meeting duration in hours and minutes \[[#59404](https://community.openproject.org/wp/59404)\]
- Feature: Allow changing dates of a meeting series occurrence \[[#59773](https://community.openproject.org/wp/59773)\]
- Feature: Automatic instantiation of the next occurrence of a meeting series \[[#59775](https://community.openproject.org/wp/59775)\]
- Feature: Copying of recurring meetings occurrences \[[#59777](https://community.openproject.org/wp/59777)\]
- Feature: Cancelling recurring meetings occurrences \[[#59829](https://community.openproject.org/wp/59829)\]
- Feature: Add trailing unit for input fields in datepicker and lag field \[[#59860](https://community.openproject.org/wp/59860)\]
- Feature:  Update meeting series template blankslate to include information \[[#59867](https://community.openproject.org/wp/59867)\]
- Feature: Pagination for recurring meetings \[[#59883](https://community.openproject.org/wp/59883)\]
- Feature: Cancellation dialogs for recurring meetings \[[#59885](https://community.openproject.org/wp/59885)\]
- Feature: Recurring meetings ICS schedule \[[#59886](https://community.openproject.org/wp/59886)\]
- Feature: Define subject patterns in work package type settings \[[#59909](https://community.openproject.org/wp/59909)\]
- Feature: Prevent editing of subject on work package creation and update \[[#59910](https://community.openproject.org/wp/59910)\]
- Feature: Block users from editing managed subjects of work packages in table views \[[#59911](https://community.openproject.org/wp/59911)\]
- Feature: Show user popover on the name, not only avatar \[[#59925](https://community.openproject.org/wp/59925)\]
- Feature: Add enterprise banner to subject configuration \[[#59929](https://community.openproject.org/wp/59929)\]
- Feature: End recurring meeting series \[[#59951](https://community.openproject.org/wp/59951)\]
- Feature: Recurring meetings: Improved display of form dialog \[[#59974](https://community.openproject.org/wp/59974)\]
- Feature: Update seed data to make &quot;Weekly&quot; a recurring meeting \[[#60135](https://community.openproject.org/wp/60135)\]
- Feature: Rename Dynamic meeting to &quot;one-time&quot; again \[[#60141](https://community.openproject.org/wp/60141)\]
- Feature: Invitation email for meeting series \[[#60200](https://community.openproject.org/wp/60200)\]
- Feature: Allow children creation from the new Relations Tab \[[#60273](https://community.openproject.org/wp/60273)\]
- Feature: Prevent autocomplete on date picker input fields \[[#60286](https://community.openproject.org/wp/60286)\]
- Feature: Allow seeding design variables \[[#60598](https://community.openproject.org/wp/60598)\]
- Feature: Remove ability to set default time tracking activity \[[#60718](https://community.openproject.org/wp/60718)\]
- Feature: Recurring meetings: Allow end date to be optional \[[#60880](https://community.openproject.org/wp/60880)\]
- Feature: Display sums in Timesheet PDF \[[#60923](https://community.openproject.org/wp/60923)\]
- Feature: Separate meeting series show page into two tables \[[#60959](https://community.openproject.org/wp/60959)\]
- Feature: Autocompleters for user cf filter values on the project list   \[[#60972](https://community.openproject.org/wp/60972)\]
- Feature: Better structure upcoming meetings by organising them into named date sections \[[#61030](https://community.openproject.org/wp/61030)\]
- Feature: Relations tab: Show a single date when start and finish dates are the same \[[#61044](https://community.openproject.org/wp/61044)\]
- Feature: Better indicate when a recurring meeting has ended (or is ended manually) with changes in phrasing and a more helpful blankslate \[[#61161](https://community.openproject.org/wp/61161)\]
- Bugfix: Cost query for work package does not show children / value differs from spentTime \[[#33790](https://community.openproject.org/wp/33790)\]
- Bugfix: When logging time with comma in English language settings everything after the comma is cut off \[[#36307](https://community.openproject.org/wp/36307)\]
- Bugfix: Logging time and removing time activity sets the default one \[[#51751](https://community.openproject.org/wp/51751)\]
- Bugfix: Mobile: tap twice on comment input to start typing \[[#57107](https://community.openproject.org/wp/57107)\]
- Bugfix: Opening the meetings details creates additional buttons at the bottom \[[#57912](https://community.openproject.org/wp/57912)\]
- Bugfix: Link to Nextcloud file is duplicated to new work package \[[#58848](https://community.openproject.org/wp/58848)\]
- Bugfix: Notification center: Activity tab goes into mobile layout even when the browser window is smaller desktop wide \[[#59235](https://community.openproject.org/wp/59235)\]
- Bugfix: Network error about notifications showing up on Community \[[#59328](https://community.openproject.org/wp/59328)\]
- Bugfix: \[Regression\] Missing &quot;Commit Message&quot; Comments in Work Packages after upgrade to 15.0.1 \[[#59374](https://community.openproject.org/wp/59374)\]
- Bugfix: Changing an image size is not reflected in the export \[[#59533](https://community.openproject.org/wp/59533)\]
- Bugfix: Table formatting is not reflected in the PDF export \[[#59534](https://community.openproject.org/wp/59534)\]
- Bugfix: Missing arrow next to column name to indicate sorting order \[[#59868](https://community.openproject.org/wp/59868)\]
- Bugfix: Some translation bugs \[[#59913](https://community.openproject.org/wp/59913)\]
- Bugfix: On narrow screens (including mobile) the view always scrolls to the end of the Activity tab \[[#59916](https://community.openproject.org/wp/59916)\]
- Bugfix: Project membership in group administration lists global roles \[[#59934](https://community.openproject.org/wp/59934)\]
- Bugfix: Editing the date of an upcoming recurring meeting to a past date doesn&#39;t move it to the &#39;Past&#39; tab \[[#59944](https://community.openproject.org/wp/59944)\]
- Bugfix: Clicking on recurring meetings, &quot;My meetings&quot; stays selected \[[#59947](https://community.openproject.org/wp/59947)\]
- Bugfix: Meeting template details panel name should be &#39;Meeting series details&#39; \[[#59953](https://community.openproject.org/wp/59953)\]
- Bugfix: Meeting interval can be empty, leading to an error \[[#59955](https://community.openproject.org/wp/59955)\]
- Bugfix: Recurring meeting template header is missing the author name \[[#59958](https://community.openproject.org/wp/59958)\]
- Bugfix: Recurring meeting template info pane is missing some text \[[#59959](https://community.openproject.org/wp/59959)\]
- Bugfix: Internal server error on Azure OIDC login with expired client secret \[[#59960](https://community.openproject.org/wp/59960)\]
- Bugfix: Main recurring meeting index doesn&#39;t show updated empty state \[[#59966](https://community.openproject.org/wp/59966)\]
- Bugfix: Meeting name is not in a lighter shade on the recurring meeting overview page \[[#59976](https://community.openproject.org/wp/59976)\]
- Bugfix: Breadcrumb name should be &#39;My meetings&#39; \[[#59994](https://community.openproject.org/wp/59994)\]
- Bugfix: User is taken back to the top of the page after loading more occurences of recurring meeting \[[#60007](https://community.openproject.org/wp/60007)\]
- Bugfix: Left side menu doesn&#39;t highlight Meeting series name \[[#60019](https://community.openproject.org/wp/60019)\]
- Bugfix: As anonymized user, meetings side menus should be reduced \[[#60117](https://community.openproject.org/wp/60117)\]
- Bugfix: Missing \* to show fields are required + wrong primary button name on the Recurring meeting form \[[#60118](https://community.openproject.org/wp/60118)\]
- Bugfix: Required custom fields prevent a WorkPackage from being added as a child \[[#60122](https://community.openproject.org/wp/60122)\]
- Bugfix: Meeting template shows weird/wrong schedule \[[#60138](https://community.openproject.org/wp/60138)\]
- Bugfix: PDF report: list style of work package description incorrect \[[#60331](https://community.openproject.org/wp/60331)\]
- Bugfix: PDF export: List in table not formatted as in work package description \[[#60333](https://community.openproject.org/wp/60333)\]
- Bugfix: Error message in case of duplicate folder name is not accurate \[[#60423](https://community.openproject.org/wp/60423)\]
- Bugfix: Hyphenation feature in generated pdf files removes space before italic text \[[#60431](https://community.openproject.org/wp/60431)\]
- Bugfix: Custom user action broken \[[#60439](https://community.openproject.org/wp/60439)\]
- Bugfix: Unable to log in to community (web on iOS due to an overlay on small mobile screens \[[#60459](https://community.openproject.org/wp/60459)\]
- Bugfix: Misplaced cursor in comments text editor on iOS  \[[#60538](https://community.openproject.org/wp/60538)\]
- Bugfix: LDAP sync not lockingusers if no values returned \[[#60566](https://community.openproject.org/wp/60566)\]
- Bugfix: Role permissions concerning comments are named &quot;Notes&quot; and are unclear \[[#60602](https://community.openproject.org/wp/60602)\]
- Bugfix: Adding a WP with long name as agenda item on Meetings creates a visual overlap \[[#60608](https://community.openproject.org/wp/60608)\]
- Bugfix: Add relation dialog is overflowing when the ticket name is rather long \[[#60619](https://community.openproject.org/wp/60619)\]
- Bugfix: Mandatory fields not visible during project creation \[[#60652](https://community.openproject.org/wp/60652)\]
- Bugfix: Click on hamburger icon does not always open the sidebar on iOS \[[#60680](https://community.openproject.org/wp/60680)\]
- Bugfix: Applying a change in a cost report query saves it \[[#60681](https://community.openproject.org/wp/60681)\]
- Bugfix: Ending series via number of occurrences does not work if the ending condition was originally after a specific date \[[#60700](https://community.openproject.org/wp/60700)\]
- Bugfix: Regression: If WP title is long without spaces, it overflows outside of the split screen \[[#60705](https://community.openproject.org/wp/60705)\]
- Bugfix: Ends after &#39;a specific date&#39; dates are not inclusive \[[#60713](https://community.openproject.org/wp/60713)\]
- Bugfix: Duplicate work package comments when clicking submit multiple times \[[#60719](https://community.openproject.org/wp/60719)\]
- Bugfix: Should start and end time be deletable once entered? \[[#60722](https://community.openproject.org/wp/60722)\]
- Bugfix: Show dates of Children of a work package in relations tab \[[#60957](https://community.openproject.org/wp/60957)\]
- Bugfix: Icon beside dates of a relation is wrong in relation row \[[#60958](https://community.openproject.org/wp/60958)\]
- Bugfix: Upcoming meetings: Meeting durations under the &#39;Duration&#39; column are not displayed in hours and minutes \[[#61034](https://community.openproject.org/wp/61034)\]
- Bugfix: UI Flickering when clicking on the activity anchor point \[[#61042](https://community.openproject.org/wp/61042)\]
- Bugfix: Poor performance of GET /api/v3/work\_packages/:id and PATCH /api/v3/work\_packages/:id \[[#61058](https://community.openproject.org/wp/61058)\]
- Bugfix: When allowed to log time entries for others, time entries can be logged for any user regardless of visibility \[[#61084](https://community.openproject.org/wp/61084)\]
- Bugfix: Search produces 500 error response on certain attachment constellation \[[#61110](https://community.openproject.org/wp/61110)\]
- Bugfix: Refreshing exchanged token does not work with Keycloak \[[#61140](https://community.openproject.org/wp/61140)\]
- Bugfix: When adding a new meeting globally, leaving the project unselected results in strange error \[[#61176](https://community.openproject.org/wp/61176)\]

<!-- END AUTOMATED SECTION -->
<!-- Warning: Anything above this line will be automatically removed by the release script -->

## Contributions
A very special thank you goes to our sponsors for this release.
Also a big thanks to our Community members for reporting bugs and helping us identify and provide fixes.
Special thanks for reporting and finding bugs go to Luka Bradesko, Andrej Sandorf, Max Mutzge, Lars Geiger, Rudi B., Alexander Aleschenko, Alex Fantini, Peter Wafzig.

Last but not least, we are very grateful for our very engaged translation contributors on Crowdin, who translated quite a few OpenProject strings!
Would you like to help out with translations yourself?
Then take a look at our translation guide and find out exactly how you can contribute.
It is very much appreciated!

