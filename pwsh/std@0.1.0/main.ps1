<#
    .synopsis
        standard library to pwsh

    .description
        ゆらぎ・迷いを減らし、理解しやすくするために、出力の形式を定める。
    
    .functions

        out-trace
        out-desc
        out-debug
        out-warn
        out-error
        out-log
    
    .todo
        モジュール化する。

#>
function write($message){
    switch($message.GetType().Name){
       'Match'           { Write-Host "`n"; $message | Format-List  }
       'Hashtable'       { Write-Host "`n"; $message | Format-List  }
       'PSCustomObject'  { Write-Host "`n"; $message | Format-Table }
       'Object[]'        {
            switch($message[0].GetType().Name){
               'PSCustomObject'  { Write-Host "`n"; $message | Format-Table }
                Default          { Write-Host "`n"; $message -join "`n" | Write-Host }
            }
       }
       Default  { Write-Host $message }
    }
}

function out-trace($message){
    Write-Host "TRCE:" -ForegroundColor Black -BackgroundColor White -NoNewline; 
    write $message
}
function out-desc($message){
    Write-Host "DESC:" -ForegroundColor Black -BackgroundColor Green -NoNewline; 
    write $message
}
function out-debug($message){
    Write-Host "DEBG:" -ForegroundColor Black -BackgroundColor Cyan -NoNewline; 
    write $message
}
function out-warn($message){
    Write-Host "WARN:" -ForegroundColor Black -BackgroundColor Yellow -NoNewline; 
    write $message
}
function out-error($message){
    Write-Host "EROR:" -ForegroundColor Black -BackgroundColor Magenta -NoNewline; 
    write $message
}

function out-log{
    [CmdletBinding()]
    Param(
        [ValidateSet("trace","debug","warning","error","other")]
        [string]$type
        ,
        [ValidateNotNullOrEmpty()]
        [string]$funcname
        ,
        [string]$title
        ,
        [Object]$outobj
        ,
        [string]$runtime = "powershell"
    )
    if(($env:LOG_LOCATION -eq $null) -and ( -not (Test-Path $env:LOG_LOCATION)) -and ( -not ((Get-Item lib) -is [System.IO.DirectoryInfo]))){
        out-error "invalid $env:LOG_LOCATION. $env:LOG_LOCATION is [Existing Directory]."
    }

    # define default auguments
    if($type -eq $null){ $type = "trace" }
    
    # set log file name
    if($type -ne "debug"){
        $logfile = Join-Path $env:LOG_LOCATION "$(Get-Date -Format "yyyyMMdd").$runtime.log.json"
    }else{
        $logfile = Join-Path $env:LOG_LOCATION "$(Get-Date -Format "yyyyMMdd").$runtime.debug.log.json"
    }

    # if fist time log then new header add. (if only one of the pscustomobject array then, cannot add new object to read exist converted json.)
    if(-not (Test-Path $logfile)){
        $log = @()
        $header = [PSCustomObject]@{
            date     = "invoke time for jis standard format"
            type     = "trace | debug | warning | error | other"
            function = "invoke function"
            title    = "short message"
            detail   = "detail items. can contain any psobjects."
            runtime  = "powershell"
        }
        $log += $header
    }else{
        # get exist log items from file on converted json
        $log = Get-Content $logfile -Raw | ConvertFrom-Json   
    }
    # creat new log object
    $new = [PSCustomObject]@{
        date     = Get-Date -Format "yyyy-MM-ddTHH:mm:ss+09:00";
        type     = $tyoe
        function = $funcname
        title    = $title
        detail   = $outobj
        runtime  = "powershell"
    }
    $log += $new
    $log | ConvertTo-Json | Out-File $logfile -Encoding utf8
}
