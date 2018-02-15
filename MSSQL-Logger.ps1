# Copyright (c) Elie Saad. All rights reserved.
# Licensed under the MIT License.

Import-Module SqlServer
# SMO SQL Server Object
$Server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $env:COMPUTERNAME
# Gather data for the past day
$logDate = (get-date).AddDays(-1)
$todays_date = Get-Date -Format yyy_MM_dd
# Path to the logon log file
$logon_logs_path = "C:\Users\${env:USERNAME}\Desktop\Logs\Logon"
# Check if the path to the file exists
If(!(test-path $logon_logs_path))
{
    New-Item -ItemType Directory -Force -Path $logon_logs_path | Out-Null
}
# Check for only Logon logs
(Get-SqlErrorLog -After $logDate -ServerInstance $env:COMPUTERNAME |
Where-Object {$_.Source -match 'Logon'} ) |
Export-Csv ${logon_logs_path}\logon_logs_${todays_date}.csv -NoTypeInformation

# This Query is to gather transactional log data from MSSQL Databases
$SQLQuery = @"
	SET NOCOUNT ON
	DECLARE @LSN NVARCHAR(46)
	DECLARE @LSN_HEX NVARCHAR(25)
	DECLARE @tbl TABLE (id INT identity(1,1), i VARCHAR(10))
	DECLARE @stmt VARCHAR(256)
	SET @LSN = (SELECT TOP 1 [Current LSN] FROM fn_dblog(NULL, NULL)  where [Begin Time] > DATEADD(hh, -24, GETDATE()))
	SET @stmt = 'SELECT CAST(0x' + SUBSTRING(@LSN, 1, 8) + ' AS INT)'
	INSERT @tbl EXEC(@stmt)
	SET @stmt = 'SELECT CAST(0x' + SUBSTRING(@LSN, 10, 8) + ' AS INT)'
	INSERT @tbl EXEC(@stmt)
	SET @stmt = 'SELECT CAST(0x' + SUBSTRING(@LSN, 19, 4) + ' AS INT)'
	INSERT @tbl EXEC(@stmt)
	SET @LSN_HEX =
	(SELECT i FROM @tbl WHERE id = 1) + ':' + (SELECT i FROM @tbl WHERE id = 2) + ':' + (SELECT i FROM @tbl WHERE id = 3)

	SELECT [Current LSN], SUSER_SNAME ([Transaction SID]) AS [User], [Operation], 
	[Context], [Transaction ID], [AllocUnitName], [Page ID], [Transaction Name], 
	[Parent Transaction ID], [Description],
	[Num Elements], CAST([RowLog Contents 0] AS VARCHAR) AS [RowLog Contents 0],
	CAST([RowLog Contents 1] AS VARCHAR) AS [RowLog Contents 1], CAST([RowLog Contents 2] AS VARCHAR) AS [RowLog Contents 2]
	FROM fn_dblog(@LSN_HEX, NULL)
	WHERE [Transaction ID] IN (SELECT [Transaction ID] FROM fn_dblog(@LSN_HEX, NULL) WHERE [Transaction Name] IN ('INSERT','DELETE','DROPOBJ','CREATE TABLE','user_transaction','UPDATE'))
"@
# Gather the master and all user made databases
$databases = Invoke-Sqlcmd -ServerInstance $Server -Query 'SELECT name FROM master.dbo.sysdatabases where dbid >4 or dbid = 1'
# Path of the transactions log file
$transaction_logs_path = "C:\Users\${env:USERNAME}\Desktop\Logs\transactions"
# Check if the path to the files exists
If(!(test-path $transaction_logs_path))
{
      New-Item -ItemType Directory -Force -Path $transaction_logs_path | Out-Null
}
# Remove the header made by powershell
$databases = $databases.ItemArray
# Gather the data into $logs of each database in the server
$logs = foreach ($db IN $databases)
{Invoke-Sqlcmd -ServerInstance $Server -Query $SQLQuery -database $db}
# Export that data to a CSV in the created folder
$logs | Export-Csv ${transaction_logs_path}\transaction_logs_${todays_date}.csv -NoTypeInformation
