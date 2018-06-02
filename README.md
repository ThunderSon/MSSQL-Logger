# ![logo][] MSSQL-Logger
A power-shell script that extracts Logon and Transactional Logs to CSV files. It gathers logs for the past day. The log file name will contain the day that the script was ran on.

[logo]: https://raw.githubusercontent.com/PowerShell/PowerShell/master/assets/ps_black_64.svg?sanitize=true

### Prerequisites

* [PowerShell](https://github.com/PowerShell/PowerShell)

* [MSSQL server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads).
Download the express edition if you need it for free local developement.
* [Sqlserver](https://docs.microsoft.com/en-us/powershell/module/sqlserver/?view=sqlserver-ps) Powershell Module.  
Run the following command in a PowerShell Terminal: 
```
Install-Module -Name SqlServer
```
For reference, check https://docs.microsoft.com/en-us/sql/powershell/download-sql-server-ps-module

## Built With

* [PowerShell](https://github.com/PowerShell/PowerShell) - The scripting language used

## Authors

* **Thunder Son** - *Initial work* - [ThunderSon](https://github.com/ThunderSon)

## License

This project is licensed under the MIT License.
