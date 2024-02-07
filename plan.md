# AWS-Organization-backup plan

The standard backup plan comes with three different  "rules"

For rule parameters see: [Creating a backup plan](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_backup_syntax.html)
## Setup

### 7 day rule

- Daily backup at 05:50 (cron(50 5 ? * * *))

- Starts within 300 minutes

- Must finish in 2 days or it fails

- Continuous backup enabled for available resources

- Delete after 14 days

- cross account backup enabled

### 40 day rule

- weekly backup at 05:50 on monday cron(50 5 ? * 2 *))

- Starts within 300 minutes

- Must finish in 2 days or it fails

- Continuous backup disabled

- Delete after 42 days

- cross account backup enabled

### 370 day rule

- monthly backup at 05:50 on the first monday (cron(50 5 ? * 2 *))

- Starts within 300 minutes

- Must finish in 2 days or it fails

- Continuous backup disabled

- Delete after 420 days

- cross account backup enabled

### overall rules:

- windows (EC2) backup enabled
