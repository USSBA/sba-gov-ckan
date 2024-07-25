# Log Cleaner

The log cleaner is a task that runs daily and triggered via GitHub Actons CRON schedule.

The purpose of this task is to remove expired log streams (e.g. streams that no longer have logs) as CloudWatch Logs does not handle this natively.
It will also put a retention policy of 90 days on CloudWatch LogGroups that do not have a retention period configured.

