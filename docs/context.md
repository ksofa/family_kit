3.1.	Functional purpose
The program provides a platform for accounting, monitoring and managing medicines in home first-aid kits. Users can create and edit lists of medications, track their expiration dates, and receive reminders about taking medications with dosages and times. The app supports searching for medications by name, category, or destination, sharing first-aid kit data for family members, and storing medication history with the ability to analyze and generate reports.
3.2.	Operational purpose
The operational purpose of the program is to make the process of recording and using drugs simple, safe and convenient. The app automates the control of expiration dates, helps you avoid using expired medications, and provides reminders for taking medications and recommendations for storing them. Additional features, such as sharing, make home first aid kit management accessible and efficient for all users, ensuring timely access to important information at any time.

 
4.	PROGRAM REQUIREMENTS
4.1.	Requirements for functional characteristics
4.1.1.	User authentication
4.1.1.1.	User profile (entity definition):
4.1.1.1.1.	Email address (required):
4.1.1.1.1.1.	Text field.
4.1.1.1.1.2.	Format: username@domain.
4.1.1.1.1.3.	Maximum length: 100 characters.
4.1.1.1.1.4.	A unique value.
4.1.1.1.2.	Password (required):
4.1.1.1.2.1.	Text field.
4.1.1.1.2.2.	Minimum length: 8 characters.
4.1.1.1.2.3.	Maximum length: 64 characters.
4.1.1.1.2.4.	It must contain:
4.1.1.1.2.5.	At least one capital letter.
4.1.1.1.2.6.	At least one lowercase letter.
4.1.1.1.2.7.	At least one digit.
4.1.1.1.2.8.	At least one special character.
4.1.1.1.3.	First name (required):
4.1.1.1.3.1.	Text field.
4.1.1.1.3.2.	Maximum length: 50 characters.
4.1.1.1.4.	Last name (required):
4.1.1.1.4.1.	Text field.
4.1.1.1.4.2.	Maximum length: 50 characters.
4.1.1.1.5.	Avatar (optional):
4.1.1.1.5.1.	Field for uploading an image.
4.1.1.1.5.2.	Supported formats: .jpg, .png, .gif.
4.1.1.1.5.3.	Maximum file size: 5 MB.
4.1.1.1.6.	Consent to the user agreement (required):
4.1.1.1.6.1.	Check mark (checkbox).
4.1.1.1.6.2.	You can't create a profile without activating it.
4.1.1.2.	Registration
4.1.1.2.1.	Data format and validationданн
4.1.1.2.1.1.	Verification of credentials:
4.1.1.2.1.1.1.	To register via email: an email is sent with a confirmation code or activation link.
4.1.2.	Creating and managing first aid kits
4.1.2.1.	 First aid kit fields (entity definition):
4.1.2.1.1.	Name (required):
4.1.2.1.1.1.	Text field (maximum length: 100 characters).
4.1.2.1.2.	Author (owner) (required):
4.1.2.1.2.1.	The user who created the first aid kit(full name).
4.1.2.1.2.2.	Filled in automatically when creating a first aid kit from your profile.
4.1.2.1.3.	First aid kit location address (optional):
4.1.2.1.3.1.	Placemark for a geo location
4.1.2.1.4.	Privacy (required):
4.1.2.1.5.	Choose from two values:
4.1.2.1.5.1.	Private (available only to the owner).
4.1.2.1.5.2.	Shared (ability to connect other users).
4.1.2.2.	User roles: 
4.1.2.2.1.	Administrator:
4.1.2.2.1.1.	Full control and customization.
4.1.2.2.1.2.	It can add, edit, or delete medications.
4.1.2.2.1.3.	Has the right to change the rights of other users, invite new ones, or delete existing ones.
4.1.2.2.2.	Editor:
4.1.2.2.2.1.	Participate in the daily management of the first aid kit.
4.1.2.2.2.2.	Can edit information about medications, but not delete them.
4.1.2.2.2.3.	It has the ability to create, edit, or delete reminders.
4.1.2.2.3.	The observer:
4.1.2.2.3.1.	Getting information without the ability to edit it.
4.1.2.2.3.2.	Has read-only access.
4.1.2.3.	Scanning module
4.1.2.3.1.	 The module supports working with QR codes and barcodes (EAN-13, UPC-A, Code 128)
4.1.2.3.2.	Scanning is performed using the device's built-in camera.
4.1.2.3.3.	The following processing scenarios are supported:
4.1.2.3.3.1.	Automatically add data from the code (QR code).
4.1.2.3.3.2.	Retrieving the ID from the barcode and then searching the database.
4.1.2.4.	QR code processing logic
4.1.2.4.1.	The QR code shouldcontain complete information about the drug:
4.1.2.4.1.1.	Name of the drug.
4.1.2.4.1.2.	Date of manufacture and expiration date.
4.1.2.4.2.	If the scan is successful, the app will:
4.1.2.4.2.1.	Retrieves data from a QR code.
4.1.2.4.2.2.	Automatically fills out the drug card.
4.1.2.4.2.3.	Notifies the user about adding a drug.
4.1.2.4.3.	If the QR code is incorrect, a notification is displayed:
4.1.2.4.3.1.	"The code was not recognized. Check the packaging or enter the data manually."
4.1.2.5.	Barcode processing logic
4.1.2.5.1.	The barcode contains a unique drug identifier (for example, EAN-13).
4.1.2.5.2.	Processing algorithm:
4.1.2.5.2.1.	Scan the barcode.
4.1.2.5.2.2.	Checking whether the barcode matches in the local database:
4.1.2.5.2.2.1.	If there is a match, the drug data is automatically filled in.
4.1.2.5.2.2.2.	If no data is found locally, a request is made to the external API to get the information.
4.1.2.5.2.3.	If the data is successfully received, the drug is added to the app's database.
4.1.2.5.3.	Drug authentication:
4.1.2.5.3.1.	If the ID is not found in the database, a notification is displayed:
"Barcode not recognized. Check the packaging or enter the data manually."
4.1.2.5.4.	Notifications and operation statuses
4.1.2.5.4.1.	Success - "Drug added successfully".
4.1.2.5.4.2.	Error - "Barcode or QR code not recognized"
4.1.2.6.	Adding medications to the first aid kit
4.1.2.6.1.	Functionality:
4.1.2.6.1.1.	Manual addition:
4.1.2.6.1.1.1.	Filling out the medication card manually
4.1.2.6.1.2.	Scanning QR codes and barcodes:
4.1.2.6.1.2.1.	Automatically add medications via scanning.
4.1.2.6.2.	Complete list of medication parameters:
4.1.2.6.2.1.	Title.
4.1.2.6.2.2.	Form of issue.
4.1.2.6.2.3.	Dosage.
4.1.2.6.2.4.	Volume/quantity.
4.1.2.6.2.5.	Expiration date.
4.1.2.6.2.6.	Category.
4.1.2.7.	Managing first aid kit users:
4.1.2.7.1.	Methods for transmitting shared access:
4.1.2.7.1.1.	Unique access code:
4.1.2.7.1.1.1.	The app generates a unique code (for example, "FAM-1234-5678") that is linked to the user's first-aid kit.
4.1.2.7.1.1.2.	The user can copy this code with a single tap on the screen.
4.1.2.7.1.1.3.	The code can be sent via instant messengers, e-mail, or other manual methods.
4.1.2.7.1.2.	User roles in the first aid kit:
4.1.2.7.1.2.1.	Administrator: Full control and configuration.
4.1.2.7.1.2.2.	Editor: Participate in the daily management of the first aid kit.
4.1.2.7.1.2.3.	Observer: Getting information without the ability to edit it.
4.1.2.7.2.	Private drugs
4.1.2.7.2.1.	Each drug has a "Private" option.
4.1.2.7.2.1.1.	If enabled: the drug is visible only to the administrator, even in the general medicine cabinet.
4.1.3.	Medication tracking during the admission process
4.1.3.1.	Description of the "Medicine"entity
4.1.3.1.1.	ID (s):
4.1.3.1.1.1.	Unique ID of the record.
4.1.3.1.1.2.	Type: numeric or string (UUID).
4.1.3.1.2.	Title:
4.1.3.1.2.1.	Full name of the drug, as indicated in the instructions or on the package.
4.1.3.1.2.2.	Type: text.
4.1.3.1.2.3.	Required field.
4.1.3.1.3.	Active substance:
4.1.3.1.3.1.	The main active component of the drug.
4.1.3.1.3.2.	Type: text.
4.1.3.1.3.3.	Required field.
4.1.3.1.4.	Category:
4.1.3.1.4.1.	Type: Business directory.
4.1.3.1.4.2.	Description: belonging to a group.
4.1.3.1.5.	Release form:
4.1.3.1.5.1.	Type: Business directory.
4.1.3.1.5.2.	Required field.
4.1.3.1.6.	Expiration date:
4.1.3.1.6.1.	Expiration date.
4.1.3.1.6.2.	Type: date.
4.1.3.1.6.3.	Required field.
4.1.3.1.7.	Storage conditions:
4.1.3.1.7.1.	Type: text.
4.1.3.1.7.2.	Optional field.
4.1.3.1.7.3.	Unique ID of the package to be scanned.
4.1.3.1.7.4.	Type: string.
4.1.3.2.	Mechanism for debiting a dose:
4.1.3.2.1.	After fixing the drug intake, the amount of the drug in the first-aid kit is automatically reduced by the specified dosage.
4.1.3.2.2.	After taking it, you can manually reduce the amount of the drug.
4.1.3.3.	Balance control:
4.1.3.3.1.	If the remaining balance is reduced to the minimum level (5% of the initial amount or 3 units), a notification is sent to the user.
4.1.3.3.2.	If the remainder is zero, the drug is marked as "Finished" and displayed in a separate category.
4.1.4.	Ability to group medicines by category
4.1.4.1.	Category:
4.1.4.1.1.	Preset values:
4.1.4.1.1.1.	Aboutcold, pain, allergies, gastrointestinal tract, heart, vitamins.
4.1.4.2.	Dimension
4.1.4.2.1.	Grouping method:
4.1.4.2.1.1.	Manually:
4.1.4.2.1.1.1.	The user specifies the category themselves.
4.1.4.2.1.2.	Automatically:
4.1.4.2.1.2.1.	Based on the built-in directories.
4.1.5.	Reminders and notifications
4.1.5.1.	Setting up reminders
4.1.5.1.1.	Basic parameters:
4.1.5.1.1.1.	Time:
4.1.5.1.1.1.1.	Specify the exact time for the reminder.
4.1.5.1.1.1.2.	Support for recurring reminders (daily, weekly, every other day).
4.1.5.1.1.2.	Dosage:
4.1.5.1.1.2.1.	Specify the amount of the drug and its size.
4.1.5.1.1.2.2.	Configuration interface
4.1.5.1.1.2.3.	Setup steps:
4.1.5.1.1.3.	Select medications from the list.
4.1.5.1.1.4.	Repeat time selection: 
4.1.5.1.1.4.1.	Date
4.1.5.1.1.4.2.	Time
4.1.5.1.1.4.3.	Periodicity
4.1.5.1.2.	Notification format
4.1.5.1.2.1.	Notification text:
4.1.5.1.2.1.1.	"Time to take medications: Drug A — 2 tablets, Drug B-1 capsule after meals."
4.1.5.1.2.1.2.	Notifications about expiring medicines
4.1.5.1.2.1.3.	Deadline before expiration:
4.1.5.1.2.2.	The notification is received:
4.1.5.1.2.2.1.	7 days before the expiration date.
4.1.5.1.2.3.	Filtering:
4.1.5.1.2.3.1.	Notifications are sent only for medicines that are in the first-aid kit and have an expiring expiration date.
4.1.5.1.2.3.1.1.	Text of the notification: "The expiration date of drug A expires in 7 days (Date: 25.11.2024)".
4.1.6.	Search and filtering
4.1.6.1.	Fuzzy search:
4.1.6.1.1.	Algorithms:
4.1.6.1.1.1.	Search by partial match.
4.1.6.1.1.2.	Typo-sensitive search.
4.1.6.1.2.	 Search fields
4.1.6.1.2.1.	Name of the drug:
4.1.6.1.2.1.1.	Standard field, text search.
4.1.6.1.2.2.	Category:
4.1.6.1.2.2.1.	It displays the drugs that belong to the selected category.
4.1.7.	History and analytics
4.1.7.1.	Drug administration logging: structure and functionality
4.1.7.1.1.	Log Entity
4.1.7.1.1.1.	Required fields:
4.1.7.1.1.1.1.	Date (required): when the reception was made.
4.1.7.1.1.1.2.	Time (required): exact time of taking the drug.
4.1.7.1.1.1.3.	Name of the drug (required): it is selected from the list of medications added to the first-aid kit.
4.1.7.1.1.1.4.	Dosage (required): the amount of medication taken.
4.1.7.1.1.1.4.1.	Drug quantity
4.1.7.1.1.1.4.2.	Dimension from the list: 
4.1.7.1.1.1.4.2.1.	List contents: mg (milligrams), g (grams), mcg(micrograms), ml (milliliters), L (liters), pcs (pieces), tablets (tablets), cap (drops), units (units)
4.1.7.1.1.1.5.	Status: Indicates whether the reception was completed ("Accepted", "Missed").
4.1.7.1.2.	Editing and deleting functionality
4.1.7.1.2.1.	Edit: Records can be edited.
4.1.7.1.2.2.	Delete: You can delete an entry if necessary, but the system may ask for confirmation of the action to avoid accidental errors.
4.1.7.1.3.	Reception schedule and prescriptions
4.1.7.1.3.1.	Entering a prescription: The user can add a prescription to the app by specifying the drug, dosage, course duration, and frequency of use.
4.1.7.1.3.2.	Formation of the reception schedule: The app calculates the required amount of the drug for the entire course of treatment and compares it with the remaining amount.
4.1.7.1.4.	What reports can be generated:
4.1.7.1.4.1.	Personal medication log:
	Report on all medications taken during the specified period (for example, for a week, month, or course of treatment).
4.1.7.1.4.2.	Report on a specific drug:
	Analysis of how many doses were taken, how long the course lasted, and the rest of the drug.
4.1.7.1.4.3.	Report format:
4.1.7.1.4.3.1.	Structure:
4.1.7.1.4.3.1.1.	Personal data (username or family member).
4.1.7.1.4.3.1.2.	Name and dosage of the drug.
4.1.7.1.4.3.1.3.	Dates and times of reception.
4.1.7.1.4.3.1.4.	Reception status (completed/skipped).
4.1.7.1.4.3.2.	Storage and upload formats:
4.1.7.1.4.3.2.1.	PDF
4.1.7.1.4.3.3.	Data storage:
4.1.7.1.4.3.3.1.	Cloud Storage: When syncing family access or creating reports, data is stored in cloud storage (Firebase)
4.1.7.1.4.3.4.	Uploading and transmitting reports:
4.1.7.1.4.3.4.1.	Via the app: "Export" button with a choice of format (PDF).
4.1.7.1.4.3.4.2.	Resupply Notifications
4.1.8.	Shared access
4.1.8.1.	Creating a family group:
4.1.8.1.1.	The user can create a family group to which one or more first-aid kits can be linked.
4.1.8.1.2.	When creating a group, the user is assigned as an Administrator.
4.1.8.2.	Managing the group composition:
4.1.8.2.1.	The administrator can add or remove first aid kits to the family group.
4.1.8.2.2.	A user can only be added to the group with the Administrator's consent.
4.1.8.3.	Adding users to the first aid kit
4.1.8.3.1.	Methods for transmitting shared access:
4.1.8.3.1.1.	Unique access code:
4.1.8.3.1.1.1.1.	The app generates a unique code (for example, "FAM-1234-5678") that is linked to the user's first-aid kit.
4.1.8.3.1.1.1.2.	The user can copy this code with a single tap on the screen.
4.1.8.3.1.1.1.3.	The code can be sent via instant messengers, e-mail, or other manual methods.
4.1.8.3.2.	Access Settings
4.1.8.3.2.1.	What data can be edited: 
4.1.8.3.2.1.1.	First aid kit contents:
4.1.8.3.2.1.1.1.	Administrator: Add, edit, or delete medications (for example, when the expiration date expires).
4.1.8.3.2.1.1.2.	Editor: Can edit information, but not delete drugs.
4.1.8.3.2.1.1.3.	Observer: Read-only access.
4.1.8.3.2.2.	Reminders:
4.1.8.3.2.2.1.	Admin and Editor: Can create, edit, or delete reminders.
4.1.8.3.2.2.2.	Observer: does not have the right to change reminders.
4.1.8.3.2.3.	Managing users
4.1.8.3.2.3.1.	Rights and restrictions:
4.1.8.3.2.3.1.1.	Only the Administrator can change the rights of other users.
4.1.8.3.2.3.1.2.	The administrator is the only one who can invite new users or delete existing ones from the first aid kit or family group.
4.2.	Organization of input data
4.2.1.	For correct operation, the program accepts input data sent with the user's touch on the screen or by scanning barcodes and QR codes.
4.2.1.1.	To add medications, you must specify:
4.2.1.1.1.	Name of the drug.
4.2.1.1.2.	A category.
4.2.1.1.3.	Expiration date.
4.2.1.1.4.	Dosage;
4.2.1.1.5.	Storage conditions.
4.2.1.2.	If you use shared access, you need to identify users and configure their access rights.
4.2.1.3.	To set up reminders, you must specify the time, dosage, and frequency of taking medications.
4.3.	Organization of output data
4.3.1.	The program provides the following output data:
4.3.1.1.	Notifications to users about the approaching expiration date of drugs, the need to take a drug, or replenishment of stocks.
4.3.1.2.	History of actions with the first-aid kit, including adding, deleting, and editing information about medications, as well as the medication history.
4.3.1.3.	Recommendations for storing medicines.
4.3.1.4.	Medication reports that can be saved.





