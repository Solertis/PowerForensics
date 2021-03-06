<#function ConvertTo-ForensicTimeline
{
    [CmdletBinding()]
    param
    ( 
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PSObject[]]
        $InputObject
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        foreach($object in $InputObject)
        {
            switch ($object.TypeNames[0])
            {
                PowerForensics.Artifacts.Amcache
                {
                    break;
                }
                PowerForensics.Artifacts.Prefetch
                {
                    Write-Output ([PowerForensics.ForensicTimeline]::Get($object.BaseObject as Prefetch);
                    break;
                }
                PowerForensics.Artifacts.ScheduledJob
                {
                    Write-Output ([PowerForensics.Formats.ForensicTimeline]::Get(inputobject.BaseObject as ScheduledJob), $true);
                    break;
                }
                PowerForensics.Artifacts.ShellLink
                {
                    Write-Output ([PowerForensics.Formats.ForensicTimeline]::Get(inputobject.BaseObject as ShellLink), $true);
                    break;
                }
                PowerForensics.Artifacts.UserAssist
                {
                    Write-Output ([PowerForensics.Formats.ForensicTimeline]::Get(inputobject.BaseObject as UserAssist), $true);
                    break;
                }
                PowerForensics.EventLog.EventRecord
                {
                    Write-Output ([PowerForensics.Formats.ForensicTimeline]::Get(inputobject.BaseObject as EventRecord), $true);
                    break;
                }
                PowerForensics.Ntfs.FileRecord
                {
                    FileRecord r = inputobject.BaseObject as FileRecord;
                    try
                    {
                        Write-Output ([PowerForensics.Formats.ForensicTimeline]::Get(r), $true);
                    }
                    catch
                    {
                            
                    }
                    break;
                }
                PowerForensics.Ntfs.UsnJrnl
                {
                    Write-Output ([PowerForensics.Formats.ForensicTimeline]::Get(inputobject.BaseObject as UsnJrnl), $true);
                    break;
                }
                PowerForensics.Registry.NamedKey
                {
                    Write-Output ([PowerForensics.Formats.ForensicTimeline]::Get(inputobject.BaseObject as NamedKey), $true);
                    break;
                }
                default
                {
                    throw new Exception(String.Format('{0} type not supported by ConvertTo-ForensicTimeline', inputobject.TypeNames[0]));
                }
            }
        }
    }
}#>

function ConvertTo-Gource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ForensicTimeline[]]
        $InputObject
    )
    
    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        Write-Output ([PowerForensics.Formats.Gource]::GetInstances($InputObject))
    }
}

function Copy-ForensicFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByPath')]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'ByIndex')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByIndex')]
        [Int32]
        $Index,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $Destination
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByPath { $record = FileRecord.Get($Path, $true); break }
            ByVolume { $record = FileRecord.Get($VolumeName, $Index, $true); break }
        }

        # If user specifies the name of a stream then copy just that stream

        # Else check for multiple DATA attributes

        # If multiple DATA attributes, then copy them all

        # Else copy just the main DATA attribute
        $record.CopyFile($Destination)
    }
}

function Get-ForensicAlternateDataStream
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',
        
        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Ntfs.AlternateDataStream]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Ntfs.AlternateDataStream]::GetInstancesByPath($Path)); break }
        }
    }
}

function Get-ForensicAmcache
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.Amcache]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.Amcache]::GetInstancesByPath($HivePath)); break }
        }
    }
}

function Get-ForensicAttrDef
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByitVolume { Write-Output ([PowerForensics.Ntfs.AttrDef]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Ntfs.AttrDef]::GetInstancesByPath($Path)); break }
        }
    }
}

function Get-ForensicBitmap
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',
     
        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path,
     
        [Parameter(Mandatory = $true)]
        [Int64]
        $Cluster
    )
    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Object ([PowerForensics.Ntfs.Bitmap]::Get($VolumeName, $Cluster)); break }
            ByPath { Write-Object ([PowerForensics.Ntfs.Bitmap]::GetByPath($Path, $Cluster)); break }
        }
    }
}

function Get-ForensicBootSector
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('DrivePath')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $AsBytes
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        $mbr = [PowerForensics.MasterBootRecord]::Get($Path)

        if ($mbr.PartitionTable[0].SystemId -eq 'EFI_GPT_DISK')
        {
            if ($AsBytes)
            {
                Write-Output ([PowerForensics.GuidPartitionTable]::GetBytes($Path))
            }
            else
            {
                Write-Output ([PowerForensics.GuidPartitionTable]::Get($Path))
            }
        }
        else
        {
            if ($AsBytes)
            {
                Write-Output ([PowerForensics.MasterBootRecord]::GetBytes($Path))
            }
            else
            {
                Write-Output $mbr
            }
        }
    }
}

function Get-ForensicChildItem
{
    [CmdletBinding()]
    param
    ( 
        [Parameter(Position = 0)]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        if (!($PSBoundParameters.ContainsKey('Path')))
        {
            path = this.SessionState.Path.CurrentFileSystemLocation.Path;
        }
        try
        {
            switch([PowerForensics.Helper]::GetFileSystemType([PowerForensics.Helper]::GetVolumeFromPath($Path)))
            {
                EXFAT
                {
                    throw "EXFAT File System not yet implemented."
                }
                FAT
                {
                    [PowerForensics.Fat.DirectoryEntry]::GetChildItem($Path)
                }
                NTFS
                {
                    [PowerForensics.Ntfs.IndexEntry]::GetInstances($Path)
                }
            }
        }
        catch
        {
            Write-Output $null
        }
    }
}

function Get-ForensicContent
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0 , ParameterSetName = 'ByPath')]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'ByIndex')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByIndex')]
        [Int32]
        $Index,

        [Parameter()]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]
        $Encoding,

        [Parameter()]
        [Alias('First', 'Head')]
        [Int64]
        $TotalCount,

        [Parameter()]
        [Alias('Last')]
        [Int64]
        $Tail
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        #region Encoding

        if ($PSBoundParameters.ContainsKey('Encoding'))
        {
            if ($Encoding -eq [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::Ascii)
            {
                $contentEncoding = [System.Text.Encoding]::ASCII
            }
            elseif ($Encoding -eq [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::BigEndianUnicode)
            {
                $contentEncoding = [System.Text.Encoding]::BigEndianUnicode
            }
            elseif ($Encoding -eq [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::Byte)
            {
                $asBytes = $true
            }
            elseif ($Encoding -eq [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::String)
            {
                $contentEncoding = [System.Text.Encoding]::Unicode
            }
            elseif ($Encoding -eq [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::Unicode)
            {
                $contentEncoding = [System.Text.Encoding]::Unicode
            }
            elseif ($Encoding -eq [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::Unknown)
            {
                $asBytes = $true
            }
            elseif ($Encoding -eq [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::UTF7)
            {
                $contentEncoding = [System.Text.Encoding]::UTF7
            }
            elseif ($Encoding -eq [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::UTF8)
            {
                $contentEncoding = [System.Text.Encoding]::UTF8
            }
        }

        if ($PSBoundParameters.ContainsKey('Path'))
        {
            $contentArray = [PowerForensics.Ntfs.FileRecord]::Get($filePath, $true).GetContent()
        }

        elseif($PSBoundParameters.ContainsKey('Index'))
        {
            $contentArray = [PowerForensics.Ntfs.FileRecord]::Get($VolumeName, $Index, $true).GetContent()
        }

        if ($asBytes)
        {
            Write-Output $contentArray
        }
        else
        {
            $outputArray = $contentEncoding.GetString($contentArray).Split('\n')

            if ($PSBoundParameters.ContainsKey('TotalCount') -and $PSBoundParameters.ContainsKey('Tail'))
            {
                throw (New-Object -TypeName InvalidOperationException('The parameters TotalCount and Tail cannot be used together. Please specify only one parameter.'))
            }
            elseif ($PSBoundParameters.ContainsKey('TotalCount'))
            {
                for ($i = 0; ($i -lt $TotalCount) -and ($i -lt $outputArray.Length); $i++)
                {
                    Write-Output $outputArray[$i]
                }
            }
            elseif ($PSBoundParameters.ContainsKey('Tail'))
            {
                for ($i = $Tail; ($i -gt 0); $i--)
                {
                    if ($i > $outputArray.Length)
                    {
                        $i = $outputArray.Length
                    }

                    Write-Output $outputArray[$outputArray.Length - $i]
                }
            }
            else
            {
                Write-Output $outputArray
            }
        }
    }
}

function Get-ForensicEventLog
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.EventLog.EventRecord]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.EventLog.EventRecord]::Get($Path)); break }
        }
    }
}

function Get-ForensicExplorerTypedPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.TypedPaths]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.TypedPaths]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicFileRecord
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'ByIndex')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Position = 0, ParameterSetName = 'ByIndex')]
        [Int32]
        $Index,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByMftPath')]
        [string]
        $MftPath,

        [Parameter(ParameterSetName = 'ByIndex')]
        [Parameter(ParameterSetName = 'ByPath')]
        [switch]
        $AsBytes
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByIndex
            {
                if ($PSBoundParameters.ContainsKey('Index'))
                {
                    if ($AsBytes)
                    {
                        Write-Output ([PowerForensics.Ntfs.FileRecord]::GetRecordBytes($VolumeName, $Index));
                    }
                    else
                    {
                        Write-Output ([PowerForensics.Ntfs.FileRecord]::Get($VolumeName, $Index, $false));
                    }
                }
                else
                {
                    Write-Output ([PowerForensics.Ntfs.FileRecord]::GetInstances($VolumeName));
                }
                break;
            }
            ByPath
            {
                if ($AsBytes)
                {
                    Write-Output ([PowerForensics.Ntfs.FileRecord]::GetRecordBytes($Path));
                }
                else
                {
                    Write-Output ([PowerForensic.Ntfs.FileRecord]::Get($Path, $false));
                }
                break;
            }
            MFTPathByPath
            {
                if ($AsBytes)
                {

                }
                else
                {

                }
                break;
            }
            ByMftPath
            {
                Write-Output ([PowerForensics.Ntfs.FileRecord]::GetInstancesByPath($MftPath));
                break;
            }
        }
    }
}

function Get-ForensicFileRecordIndex
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        Write-Output ([PowerForensics.Ntfs.IndexEntry]::Get($Path).RecordNumber)
    }
}

function Get-ForensicFileSlack
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'ByIndex')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Position = 0, ParameterSetName = 'ByIndex')]
        [Int32] 
        $Index,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByIndex
            {
                if ($PSBoundParameters.ContainsKey('Index'))
                {
                    Write-Output ([PowerForensics.Ntfs.FileRecord]::Get($VolumeName, $Index, $true).GetSlack())
                }
                else
                {
                    foreach ($record in ([PowerForensics.Ntfs.FileRecord]::GetInstances($VolumeName)))
                    {
                        Write-Output ($record.GetSlack())
                    }
                }
                break
            }
            ByPath
            {
                Write-Output ([PowerForensics.Ntfs.FileRecord]::Get($Path, $true).GetSlack())
                break
            }
        }
    }
}

function Get-ForensicGuidPartitionTable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('DrivePath')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $AsBytes
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        if ($AsBytes)
        {
            Write-Output ([PowerForensics.GuidPartitionTable]::GetBytes($Path))
        }
        else
        {
            Write-Output ([PowerForensics.GuidPartitionTable]::Get($Path))
        }
    }
}

function Get-ForensicMasterBootRecord
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('DrivePath')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $AsBytes
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        if ($AsBytes)
        {
            Write-Output ([PowerForensics.MasterBootRecord]::GetBytes($Path))
        }
        else
        {
            Write-Output ([PowerForensics.MasterBootRecord]::Get($Path))
        }
    }
}

function Get-ForensicMftSlack
{
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'ByIndex')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Position = 0, ParameterSetName = 'ByIndex')]
        [Int32]
        $Index,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByMftPath')]
        [string]
        $MftPath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByIndex
            {
                if ($PSBoundParameters.ContainsKey('Index'))
                {
                    Write-Output ([PowerForensics.Ntfs.FileRecord]::Get($VolumeName, $Index, $true).GetMftSlack())
                }
                else
                {
                    Write-Output ([PowerForensics.Ntfs.MasterFileTable]::GetSlack($VolumeName))
                }
                break
            }
            ByPath
            {
                Write-Output ([PowerForensics.Ntfs.FileRecord]::Get($Path, $true).GetMftSlack())
                break
            }
            MFTPath
            {
                Write-Output ([PowerForensics.Ntfs.MasterFileTable]::GetSlackByPath($MftPath))
                break
            }
        }
    }
}

function Get-ForensicNetworkList
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.NetworkList]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.NetworkList]::GetInstancesByPath($HivePath)); break }
        }
    }
}

function Get-ForensicOfficeFileMru
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.MicrosoftOffice.FileMRU]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.MicrosoftOffice.FileMRU]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicOfficeOutlookCatalog
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.MicrosoftOffice.OutlookCatalog]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.MicrosoftOffice.OutlookCatalog]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicsOfficePlaceMru
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.MicrosoftOffice.PlaceMRU]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.MicrosoftOffice.PlaceMRU]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicOfficeTrustRecord
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.MicrosoftOffice.TrustRecord]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.MicrosoftOffice.TrustRecord]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicPartitionTable
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('DrivePath')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        $mbr = [PowerForensics.MasterBootRecord]::Get($Path)

        if ($mbr.PartitionTable[0].SystemId -eq 'EFI_GPT_DISK')
        {
            Write-Output ([PowerForensics.GuidPartitionTable]::Get($Path).GetPartitionTable())
        }
        else
        {
            Write-Output $mbr.GetPartitionTable()
        }
    }
}

function Get-ForensicPrefetch
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Fast
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume
            {
                if ($Fast)
                {
                    Write-Output ([PowerForensics.Artifacts.Prefetch]::GetInstances($VolumeName, $Fast))
                }
                else
                {
                    Write-Output ([PowerForensics.Artifacts.Prefetch]::GetInstances($VolumeName))
                }
                break
            }
            ByPath
            {
                if ($Fast)
                {
                    # Output the Prefetch object for the corresponding file
                    Write-Output ([PowerForensics.Artifacts.Prefetch]::Get($Path, $Fast))
                }
                else
                {
                    # Output the Prefetch object for the corresponding file
                    Write-Output ([PowerForensics.Artifacts.Prefetch]::Get($Path))
                }
                break
            }
        }
    }
}

function Get-ForensicRecentFileCache
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.RecentFileCache]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.RecentFileCache]::GetInstancesByPath($Path)); break }
        }
    }
}

function Get-ForensicRegistryKey
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Path')]
        [string]
        $HivePath,

        [Parameter(ParameterSetName = 'ByKey')]
        [string]
        $Key,

        [Parameter(Mandatory = $true, ParameterSetName = 'Recursive')]
        [switch]
        $Recurse
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        if ($Recurse)
        {
            Write-Output ([PowerForensics.Registry.NamedKey]::GetInstancesRecurse($HivePath))
        }
        else
        {
            if (!($PSBoundParameters.ContainsKey('Key')))
            {
                $Key = $null
            }

            Write-Output ([PowerForensics.Registry.NamedKey]::GetInstances($HivePath, $Key))
        }
    }
}

function Get-ForensicRegistryValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Path')]
        [string]
        $HivePath,

        [Parameter()]
        [string]
        $Key,

        [Parameter()]
        [string]
        $Value
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        if (!($PSBoundParameters.ContainsKey('Key')))
        {
            $Key = $null
        }

        if ($PSBoundParameters.ContainsKey('Value'))
        {
            Write-Output ([PowerForensics.Registry.ValueKey]::Get($HivePath, $Key, $Value))
        }
        else
        {
            foreach ($vk in ([PowerForensics.Registry.ValueKey]::GetInstances($HivePath, $Key)))
            {
                Write-Output $vk
            }
        }
    }
}

function Get-ForensicRunMru
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.RunMRU]::GetInstances($VolumeName), $true); break }
            ByPath {Write-Output ([PowerForensics.Artifacts.RunMRU]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicRunKey
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.Persistence.RunKey]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.Persistence.RunKey]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicScheduledJob
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.ScheduledJob]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.ScheduledJob]::Get($Path)); break }
        }
    }
}

function Get-ForensicShellLink
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('FullName')]
        [string]$Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.ShellLink]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.ShellLink]::Get($Path)); break }
        }
    }
}

function Get-ForensicShimcache
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )
    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output  ([PowerForensics.Artifacts.Shimcache]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.Shimcache]::GetInstancesByPath($HivePath)); break }
        }
    }
}

function Get-ForensicSid
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.Sid]::Get($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.Sid]::GetByPath($HivePath)); break }
        }
    }
}

function Get-ForensicTimeline
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]
        [string]
        $VolumeName = '\\.\C:'
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        [PowerForensics.Formats.ForensicTimeline]::GetInstances($VolumeName)
    }
}

function Get-ForensicTimezone
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]        
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )
    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.Timezone]::Get($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.Timezone]::GetByPath($HivePath)); break }
        }
    }
}

function Get-ForensicTypedUrl
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Alias('Path')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.TypedUrls]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.TypedUrls]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicUnallocatedSpace
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0)]        
        [string]
        $VolumeName = '\\.\C:',

        [Parameter()]
        [Alias('FullName')]
        [UInt64]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        foreach ($b in [PowerForensics.Ntfs.Bitmap]::GetInstances($VolumeName))
        {
            if (!($b.InUse))
            {
                Write-Output $b
            }
        }
    }
}

function Get-ForensicUserAssist
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.UserAssist]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.UserAssist]::Get($HivePath)); break }
        }
    }
}

function Get-ForensicUsnJrnl
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter()]
        [Int64]
        $Usn
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume
            {
                if($PSBoundParameters.ContainsKey('Usn'))
                {
                    Write-Output ([PowerForensics.Ntfs.UsnJrnl]::Get($VolumeName, $Usn))
                }
                else
                {
                    Write-Output ([PowerForensics.Ntfs.UsnJrnl]::GetInstances($VolumeName))
                }
                break
            }
            ByPath
            {
                if($PSBoundParameters.ContainsKey('Usn'))
                {
                    Write-Output ([PowerForensics.Ntfs.UsnJrnl]::GetByPath($Path, $Usn))
                }
                else
                {
                    Write-Output ([PowerForensics.Ntfs.UsnJrnl]::GetInstancesByPath($Path))
                }
                break
            }
        }
    }
}

function Get-ForensicUsnJrnlInformation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $AsBytes
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume
            {
                if ($AsBytes)
                {
                    Write-Output ([PowerForensics.Ntfs.UsnJrnlInformation]::GetBytes($VolumeName))
                }
                else
                {
                    Write-Output ([PowerForensics.Ntfs.UsnJrnlInformation]::Get($VolumeName))
                }
                break
            }
            ByPath
            {
                if ($AsBytes)
                {
                    Write-Output ([PowerForensics.Ntfs.UsnJrnlInformation]::GetBytesByPath($Path))
                }
                else
                {
                    Write-Output ([PowerForensics.Ntfs.UsnJrnlInformation]::GetByPath($Path))
                }
                break
            }
        }
    }
}

function Get-ForensicVolumeBootRecord
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('FullName')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $AsBytes
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume
            {
                if ($Asbytes)
                {
                    Write-Output ([PowerForensics.Generic.VolumeBootRecord]::GetBytes($VolumeName));
                }
                else
                {
                    Write-Output ([PowerForensics.Generic.VolumeBootRecord]::Get($VolumeName));
                }
                break
            }
            ByPath
            {
                if ($Asbytes)
                {
                    Write-Object ([PowerForensics.Generic.VolumeBootRecord]::GetBytesByPath($Path));
                }
                else
                {
                    Write-Output ([PowerForensics.Generic.VolumeBootRecord]::GetByPath($Path));
                }
                break
            }
        }
    }
}

function Get-ForensicVolumeInformation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Ntfs.VolumeInformation]::Get($VolumeName)); break }
            ByPath { WriteOutput ([PowerForensics.Ntfs.VolumeInformation]::GetByPath($Path)); break }
        }
    }
}

function Get-ForensicVolumeName
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',


        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath', ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Ntfs.VolumeName]::Get($VolumeName)) }
            ByPath { Write-Output ([PowerForensics.Ntfs.VolumeName]::GetByPath($Path)); break}
        }
    }
}

function Get-ForensicWindowsSearchHistory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'ByVolume')]
        [string]
        $VolumeName = '\\.\C:',

        [Parameter(Mandatory = $true, ParameterSetName = 'ByPath')]
        [Alias('Path')]
        [string]
        $HivePath
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            ByVolume { Write-Output ([PowerForensics.Artifacts.WordWheelQuery]::GetInstances($VolumeName)); break }
            ByPath { Write-Output ([PowerForensics.Artifacts.WordWheelQuery]::Get($HivePath)); break }
        }
    }
}

function Invoke-ForensicDD
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $InFile,

        [Parameter()]
        [string]
        $OutFile,

        [Parameter()]
        [Int64]
        $Offset = 0,

        [Parameter()]
        [UInt32]
        $BlockSize = 512,

        [Parameter(Mandatory = $true)]
        [UInt32]
        $Count
    )

    begin
    {
        if (('PowerForensics.MasterBootRecord' -as [Type]) -eq $null)
        {

        }
    }

    process 
    {
        if ($PSBoundParameters.ContainsKey('OutFile'))
        {
            [PowerForensics.Utilities.DD]::Get($InFile, $OutFile, $Offset, $BlockSize, $Count)
        }
        else
        {
            Write-Output ([PowerForensics.Utilities.DD]::Get($InFile, $Offset, $BlockSize, $Count))
        }
    }
}