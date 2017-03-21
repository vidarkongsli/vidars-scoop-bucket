function ConnectSQL {
    Param ($server, $query, $database)
    Write-debug "Server: $server, Database: $database, Query: $query"
    $conn = new-object ('System.Data.SqlClient.SqlConnection')
    $connString = "Server=$server;Integrated Security=SSPI;Database=$database"
    $conn.ConnectionString = $connString
    $conn.Open()
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlCmd.CommandText = $query
    $sqlCmd.Connection = $conn
    $Rset = $sqlCmd.ExecuteReader()
    ,$Rset ## The comma is used to create an outer array, which PS strips off automatically when returning the $Rset
}

function Read-SqlQuery {
    Param ($server, $query, $database = "master")
    $data = ConnectSQL $server $query $database
    while ($data.read() -eq $true) {
        $max = $data.FieldCount -1
        $obj = New-Object Object
        For ($i = 0; $i -le $max; $i++) {
            $name = $data.GetName($i)
	        if ($name) {
                $obj | Add-Member Noteproperty $name -value $data.GetValue($i)
	        } else {
                $obj = $data.GetValue($i)
	        }
        }
        $obj
    }
}

function Write-SqlNonQuery {
    Param ($server, $stmt, $database = "master")
    $conn = new-object ('System.Data.SqlClient.SqlConnection')
    $connString = "Server=$server;Integrated Security=SSPI;Database=$database"
    $conn.ConnectionString = $connString
    $conn.Open()
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlCmd.CommandText = $stmt
    $sqlCmd.Connection = $conn
    $sqlCmd.ExecuteNonQuery()
}

function Add-sqldb {
    PARAM (
    [Parameter(Mandatory=$true)]
    $dbname,
    [Parameter(Mandatory=$true)]
    [ValidateScript({ -not(test-Path $_)})]
    $dbpath,
    [Parameter(Mandatory=$true)]
    $server
    )

    if (-not(Read-SqlQuery $server "SELECT * from sysdatabases" | Where-Object { $_.name -eq $dbname })) {
        Write-Host "Creating $dbname"
        $createStmt = @"
        CREATE DATABASE
            [$dbname]
        ON PRIMARY (
           NAME=Test_data,
           FILENAME = '$($dbpath).mdf'
        )
        LOG ON (
            NAME=Test_log,
            FILENAME = '$($dbpath).ldf'
        )
"@
        Write-Debug $createStmt
        Write-SqlNonQuery $server $createStmt
    }
}

function Add-sqllogin($server, $login='IIS APPPOOL\DefaultAppPool') {
    if (-not(Read-SqlQuery $server "SELECT * from sys.syslogins where loginname = '$login'")) {
        $createStmt = @"
            CREATE LOGIN [$login] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
"@
        Write-debug $createStmt
        Write-SqlNonQuery $server $createStmt | out-null
    }
}

function Add-sqluser($server, $dbname, $user='IIS APPPOOL\DefaultAppPool') {
    $qry = "SELECT * FROM sys.sysusers"# where name = '$user'"
    $res = Read-SqlQuery $server $qry $dbname
    if (-not($res | where-object { $_.name -eq $user }))
    { 
        $createStmt = @"
            CREATE USER [$user] FOR LOGIN [$user] WITH DEFAULT_SCHEMA=[dbo]
"@
        Write-debug $createStmt
        Write-SqlNonQuery $server $createStmt $dbname | out-null
    }
}

Export-modulemember -function Add-sqluser,Add-sqllogin,Add-sqldb,Read-SqlQuery,Write-SqlNonQuery
