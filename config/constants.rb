# What a mess.. Where do all these constants belong? Why no namespacing or at least a comment explaining what they're for?
# Globals and global constants are BAD

DEFAULT_JOURNAL_TYPES = ['Payment','Receipt','Journal']

ASSETS = 'Assets'
CASH = 'Cash'; BANK_DEPOSITS = 'Bank Accounts'; SECURITIES = 'Securities'
LAND = 'Land'; MACHINERY = 'Machinery'
LOANS_MADE = 'Loans made'; BORROWINGS = 'Borrowings'; TAXES_PAYABLE = "Tax payable"; OTHER_LIABILITIES = "Other liabilities"
CURRENT_ASSET_HEADS = [CASH, BANK_DEPOSITS, SECURITIES, LOANS_MADE]
FIXED_ASSET_HEADS = [LAND, MACHINERY]
LIABILITIES = [BORROWINGS, TAXES_PAYABLE, OTHER_LIABILITIES]
ASSET_CLASS_NOT_CHOSEN = 'Choose asset or liability class'
ASSET_CLASSES = [CURRENT_ASSET_HEADS, FIXED_ASSET_HEADS, LIABILITIES].flatten
CAPITAL = "Capital"; RESERVES = "Reserves"; PROFIT_AND_LOSS_ACCOUNT = "Profit & Loss Account"
EQUITY = [CAPITAL, RESERVES, PROFIT_AND_LOSS_ACCOUNT]

INTEREST_INCOME = 'Interest Income'; INTEREST_EARNED_ON_DEPOSITS = 'Interest earned on deposits'; FEE_INCOME = 'Fee income'
INCOMES = [INTEREST_INCOME, INTEREST_EARNED_ON_DEPOSITS, FEE_INCOME]
SALARIES = 'Salaries'; RENT_AND_TAXES = 'Rent, Rates, and Taxes'; ADMIN_EXPENSES = 'Administration Expenses'; TRAVEL_EXPENSES = 'Travel And Conveyance';
EXPENSES = [SALARIES, RENT_AND_TAXES, ADMIN_EXPENSES, TRAVEL_EXPENSES]
INCOME_HEAD_NOT_CHOSEN = 'Choose income or expense head'
INCOME_HEADS = [INCOMES, EXPENSES].flatten

DEBIT_BALANCE = "Dr."
CREDIT_BALANCE = "Cr."
DEFAULT_TO_DEBIT_BALANCE = [ASSETS, EXPENSES]
DEFAULT_TO_CREDIT_BALANCE = [LIABILITIES, INCOMES]

INSTALLMENT_FREQUENCIES = [:daily, :weekly, :biweekly, :monthly, :quadweekly]
WEEKDAYS = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
MONTHS = ["None", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
STATUSES = [:applied_in_future, :applied, :rejected, :approved, :disbursed, :outstanding, :repaid, :written_off, :claim_settlement, :preclosed]
EPSILON  = 0.01
INACTIVE_REASONS = ['', 'no_further_loans', 'death_of_client', 'death_of_spouse']
ModelsWithDocuments = ['Area', 'Region', 'Branch', 'Center', 'Client', 'Loan', 'ClientGroup', 'StaffMember', 'User', 'Mfi', 'Funder', 
                       'InsuranceCompany', 'InsurancePolicy', 'Claim']
CLAIM_DOCUMENTS = [:death_certificate, :center_declaration_form, :kyc_document]
LOANS_NOT_PAYABLE = [nil, :repaid, :pending, :written_off, :claim_settlement, :preclosed]
DUMP_FOLDER      = "db/daily"
MASS_ENTRY_FIELDS = {
  :client => [:spouse_name, :account_number, :type_of_account, :bank_name, :bank_branch, :join_holder, :number_of_family_members, 
              :caste, :religion, :occupation, :client_type], 
  :loan => [:scheduled_disbursal_date, :scheduled_first_payment_date, :loan_utilization, :purpose, :funding_line]
}
CLEANER_INTERVAL = 120
FUNDER_ACCESSIBLE_REPORTS = ["ConsolidatedReport", "GroupConsolidatedReport", "StaffConsolidatedReport", "RepaymentOverdue"]
INFINITY  = 1.0/0
REPORT_ACCESS_HASH = {
  "TransactionLedger" =>        ["data_entry", "mis_manager", "admin", "read_only", "staff_member", "accountant"],
  "LoanDisbursementRegister" => ["data_entry", "mis_manager", "admin", "read_only", "staff_member", "accountant"], 
  "IncentiveReport"          => ["mis_manager", "admin", "read_only"],
  "WeeklyReport"             => ["mis_manager", "admin", "read_only", "staff_member", "funder", "accountant"], 
  "LateDisbursalsReport"     => ["data_entry", "mis_manager", "admin", "read_only", "staff_member", "accountant"],
  "ParByLoanAgeingReport"    => ["mis_manager", "admin", "read_only", "staff_member"], 
  "GroupConsolidatedReport"  => ["mis_manager", "admin", "read_only", "staff_member"],
  "ParByCenterReport"        => ["mis_manager", "admin", "read_only", "staff_member", "accountant"], 
  "ProjectedReport"          => ["data_entry", "mis_manager", "admin", "read_only", "staff_member", "accountant"], 
  "RepaymentOverdue"         => ["mis_manager", "admin", "read_only", "staff_member"],
  "DailyReport"              => ["data_entry", "mis_manager", "admin", "read_only", "staff_member", "accountant"],
  "LoanPurposeReport"        => ["mis_manager", "admin", "read_only", "staff_member", "funder", "accountant"],
  "AggregateConsolidatedReport" => ["mis_manager", "admin", "read_only", "staff_member", "funder", "accountant"],
  "ClaimReport"             => ["data_entry", "mis_manager", "admin", "read_only", "staff_member", "accountant"],
  "TrialBalanceReport"      => ["admin", "accountant"], 
  "StaffConsolidatedReport" => ["mis_manager", "admin", "read_only", "staff_member", "funder", "accountant"],
  "ParByStaffReport"        => ["mis_manager", "admin", "read_only", "staff_member"], 
  "GeneralLedgerReport"     => ["admin", "accountant"], 
  "DayBook"                 => ["admin", "accountant"], 
  "BankBook"                => ["admin", "accountant"],
  "DelinquentLoanReport"    => ["mis_manager", "admin", "read_only", "staff_member"], 
  "NonDisbursedClientsAfterGroupRecognitionTest" => ["mis_manager", "admin", "read_only", "staff_member"],
  "ClosedLoanReport"       => ["mis_manager", "admin", "read_only", "staff_member", "accountant"],
  "StaffTargetReport"      => ["mis_manager", "admin", "read_only", "staff_member"], 
  "CashBook"               => ["admin", "accountant"],
  "DailyTransactionSummary" => ["mis_manager", "admin", "read_only", "staff_member", "funder", "accountant"],
  "ConsolidatedReport"     => ["mis_manager", "admin", "read_only", "staff_member", "funder", "accountant"], 
  "ScheduledDisbursementRegister" => ["data_entry", "mis_manager", "admin", "read_only", "staff_member", "accountant"],
  "QuarterConsolidatedReport" => ["mis_manager", "admin", "read_only", "staff_member", "accountant"], 
  "InsuranceRegister"      => ["mis_manager", "admin", "read_only", "staff_member", "accountant"], 
  "TargetReport"           => ["mis_manager", "admin", "read_only", "staff_member"], 
  "ClientAbsenteeismReport"=> ["mis_manager", "admin", "read_only", "staff_member"], 
  "DuplicateClientsReport" => ["mis_manager", "admin", "read_only", "staff_member"], 
  "LoanSanctionRegister"   => ["data_entry", "mis_manager", "admin", "read_only", "staff_member", "accountant"], 
  "LoanSizePerManagerReport" => ["mis_manager", "admin", "read_only"], 
  "ClientOccupationReport" => ["mis_manager", "admin", "read_only"]
}
PAYMENT_TYPES = [:principal, :interest, :fees]
NORMAL_REPAYMENT_STYLE = :normal
PRORATA_REPAYMENT_STYLE = :prorata
REPAYMENT_STYLES = [NORMAL_REPAYMENT_STYLE, PRORATA_REPAYMENT_STYLE, :sequential]
API_SUPPORT_FORMAT = ["xml"]
LOAN_AGEING_BUCKETS = [0, 30, 60, 90, 180, 365, :older]
LOSS_PROVISION_PERCENTAGES_BY_BUCKET = [0, 10, 25, 50, 75, 90, 100]
DEFAULT_LOCALE = 'en'
LOCALES = [["en","English"],["hi","Hindi"]]
DEFAULT_ORIGIN = "server"
#Date format initializers
#PREFERED_DATE_PATTERNS = ["%d-%m-%y", "%m-%d-%y", "%y-%m-%d", "%y-%d-%m", "%d-%m-%Y", "%m-%d-%Y", "%Y-%m-%d", "%Y-%d-%m"]
DEFAULT_DATE_PATTERN = "%d-%m-%Y"
PREFERED_DATE_PATTERNS = [DEFAULT_DATE_PATTERN, "%Y-%m-%d"]
PREFERED_DATE_SEPARATORS = { :hypen => "-", :slash => "/", :period => "." }
PREFERED_DATE_STYLES = [[:SHORT, "31-12-2001"],[:MEDIUM, "Dec 31, 2001"],[:LONG, "December 31, 2001"], [:FULL,"Monday, December 31, 2001"]]
DEFAULT_DATE_SEPARATOR = "-"
DEFAULT_DATE_STYLE = "short"
MEDIUM_DATE_PATTERN = "%b %d, %Y"
LONG_DATE_PATTERN = "%B %d, %Y"
FULL_DATE_PATTERN = "%A, %B %d, %Y"
FORMAT_REG_EXP = /[- . \/]/

# Bookmark Constants
BookmarkTypes   = [:custom_reports, :system]
MethodNames = [:get, :post, :put, :delete]

# Audit
AUDITABLES = ["Branch","Center","Client","ClientGroup","Loan","Payment","StaffMember"]

# Targets
TargetOf    = [:center_creation, :group_creation, :client_registration, :loan_disbursement_by_amount, :loan_disbursements_by_number]
TargetType  = [:relative, :absolute]

# Caches
# in order to avoid overrunning the SQL max packet size, we split the cacher update into chunks
# 2500 should be good for the standard SQL max_packet_size of 16MB
CHUNK_SIZE = 2500 
