locals {
  default_plan = {
        "plans": {
            "aws_organization_${var.name}": {
                "rules": {
                    # overlapping backup schedules to make costs predictable and backups consistent
                    "7DayRule": merge({
                        "schedule_expression": {"@@assign": "cron(50 5 ? * * *)"}, # daily at 05:50
                        "target_backup_vault_name": {"@@assign": module.backup_vault.backup_vault_name },
                        "start_backup_window_minutes": {"@@assign": "300"}, # daily backups at most so ok, avoid collisions with RDS / FSx
                        "start_backup_window_minutes": {"@@assign": "60"}, # daily backups at most so ok, avoid collisions with RDS / FSx
                        "complete_backup_window_minutes": {"@@assign": "2880"}, # max 2 days then fail
                        "enable_continuous_backup": {"@@assign": true},
                        "recovery_point_tags": { for k, v in merge(data.aws_default_tags.current.tags, { "Inherited": "True" }) :
                            k => { "tag_key": {"@@assign": k} , "tag_value": {"@@assign": v} }
                        },
                        "lifecycle": {
                            # "move_to_cold_storage_after_days": {"@@assign": "0"},
                            "delete_after_days": {"@@assign": "10"} # 1 week + 3 day margin
                        }}, length(module.backup_vault_external) > 0 ? {
                                "copy_actions": {
                                    "${module.backup_vault_external[0].backup_vault_arn}": {
                                        "target_backup_vault_arn": {
                                            "@@assign": module.backup_vault_external[0].backup_vault_arn
                                        },
                                        "lifecycle": {
                                            # "move_to_cold_storage_after_days": {"@@assign": "180"},
                                            "delete_after_days": {"@@assign": "10"}
                                        }
                                    }
                                }
                            } : {})
                    "40DayRule": merge({
                        "schedule_expression": {"@@assign": "cron(50 5 ? * 2 *)"}, # every week on Monday at 05:50
                        "target_backup_vault_name": {"@@assign": module.backup_vault.backup_vault_name },
                        "start_backup_window_minutes": {"@@assign": "300"}, # daily backups at most so ok, avoid collisions with RDS / FSx
                        "start_backup_window_minutes": {"@@assign": "60"}, # daily backups at most so ok, avoid collisions with RDS / FSx
                        "complete_backup_window_minutes": {"@@assign": "2880"}, # max 2 days then fail
                        "enable_continuous_backup": {"@@assign": true},
                        "recovery_point_tags": { for k, v in merge(data.aws_default_tags.current.tags, { "Inherited": "True" }) :
                            k => { "tag_key": {"@@assign": k} , "tag_value": {"@@assign": v} }
                        },
                        "lifecycle": {
                            # "move_to_cold_storage_after_days": {"@@assign": "0"},
                            "delete_after_days": {"@@assign": "40"} # 1 week + 3 day margin
                        }}, length(module.backup_vault_external) > 0 ? {
                                "copy_actions": {
                                    "${module.backup_vault_external[0].backup_vault_arn}": {
                                        "target_backup_vault_arn": {
                                            "@@assign": module.backup_vault_external[0].backup_vault_arn
                                        },
                                        "lifecycle": {
                                            # "move_to_cold_storage_after_days": {"@@assign": "180"},
                                            "delete_after_days": {"@@assign": "40"}
                                        }
                                    }
                                }
                            } : {})
                    "370DayRule": merge({
                        "schedule_expression": {"@@assign": "cron(50 5 ? * 2#1 *)"}, # every first Monday at the month at 05:50
                        "target_backup_vault_name": {"@@assign": module.backup_vault.backup_vault_name },
                        "start_backup_window_minutes": {"@@assign": "300"}, # daily backups at most so ok, avoid collisions with RDS / FSx
                        "start_backup_window_minutes": {"@@assign": "60"}, # daily backups at most so ok, avoid collisions with RDS / FSx
                        "complete_backup_window_minutes": {"@@assign": "2880"}, # max 2 days then fail
                        "enable_continuous_backup": {"@@assign": true},
                        "recovery_point_tags": { for k, v in merge(data.aws_default_tags.current.tags, { "Inherited": "True" }) :
                            k => { "tag_key": {"@@assign": k} , "tag_value": {"@@assign": v} }
                        },
                        "lifecycle": {
                            # "move_to_cold_storage_after_days": {"@@assign": "0"},
                            "delete_after_days": {"@@assign": "370"} # 1 week + 3 day margin
                        }}, length(module.backup_vault_external) > 0 ? {
                                "copy_actions": {
                                    "${module.backup_vault_external[0].backup_vault_arn}": {
                                        "target_backup_vault_arn": {
                                            "@@assign": module.backup_vault_external[0].backup_vault_arn
                                        },
                                        "lifecycle": {
                                            # "move_to_cold_storage_after_days": {"@@assign": "180"},
                                            "delete_after_days": {"@@assign": "370"}
                                        }
                                    }
                                }
                            } : {})
                },
                "regions": {
                    "@@assign": [ data.aws_region.current.name ]
                },
                "selections": {
                    "tags": {
                        "BackupEnabled": {
                            "iam_role_arn": {"@@assign": replace(module.iam_role.role_arn, data.aws_caller_identity.current.account_id, "$account")},
                            "tag_key": {"@@assign": "BackupEnabled"},
                            "tag_value": {
                                "@@assign": [ "True" ]
                            }
                        }
                    }
                },
                "advanced_backup_settings": {
                    "ec2": {
                        "windows_vss": {"@@assign": "enabled"}
                    }
                },
                "backup_plan_tags": { for k, v in data.aws_default_tags.current.tags :
                    k => { "tag_key": {"@@assign": k} , "tag_value": {"@@assign": v} }
                }
            }
        }
    }
}
