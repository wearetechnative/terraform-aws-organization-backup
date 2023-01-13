# AWS-Organization-backup plan

The standard backup plan comes with three different  "rules"

Rules are defined with the following parametres:

`rule_name` - The name of the backup rule. It should be unique within the backup plan.

`schedule_expression` - This is the freqeuncy the backup expressed in [AWS Schedule Expressions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html)

`target_backup_vault_name` - The name of the backup vault where the backups will be stored. It should be unique within the AWS account.

`start_backup_window_minutes` - The number of minutes after the scheduled time that a backup is started.

`complete_backup_window_minutes` - The number of minutes after the start backup window that the backup should be completed.

`enable_continuous_backup` - A Boolean flag indicating whether to enable continuous backups or not.

`recovery_point_tags` - A map of tags to add to the recovery point.

`lifecycle` - A map of lifecycle rules applied to backups.

`move_to_cold_storage_after_days` - The number of days after creation that a backup is moved to cold storage.

`delete_after_days` - The number of days after creation that a backup is deleted.

`copy_actions` - A list of maps of copy actions applied to backups.

`target_backup_vault_arn` - The ARN of the backup vault where the copied backup will be stored.

`lifecycle` - A map of lifecycle rules applied to copied backups.

`move_to_cold_storage_after_days` - The number of days after creation that a copied backup is moved to cold storage.

`delete_after_days` - The number of days after creation that a copied backup is deleted.

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