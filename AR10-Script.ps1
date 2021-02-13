

Param (
    [int]$RetrievalPeriod = 2
) 

$Date              = (Get-Date).AddHours(-($RetrievalPeriod))
$SongFolder        = "$env:APPDATA\osu!\Songs" 
$FoldersToProcess  = Get-ChildItem $SongFolder | Where-Object {$_.LastWriteTime -gt $Date}
$MinimumDifficulty =  8 #This does not mean 8 stars - OverallDifficulty 8 means somewhere around 5 stars in-game
$MinimumuAR        = 10
$Suffix            = "[AR$($MinimumuAR)]"


ForEach ($Folder in $FoldersToProcess) {

    Get-ChildItem "$SongFolder\$Folder" | Where-Object {$_.Name.EndsWith(".osu")} |
    ForEach-Object {
        [string]$Difficulty = (Get-Content -LiteralPath "$SongFolder\$Folder\$_" | Select-String "OverallDifficulty").ToString()
        [decimal]$DiffNumb  = $Difficulty -replace "[^0-9, '.']" , ''

        If ($DiffNumb -gt $MinimumDifficulty) {
            
            [string]$ApproachRate     = (Get-Content -LiteralPath "$SongFolder\$Folder\$_" | Select-String "ApproachRate").ToString()
            [decimal]$ApproachRateNum = $ApproachRate -replace "[^0-9, '.']" , ''
            [string]$Version          = (Get-Content -LiteralPath "$SongFolder\$Folder\$_" | Select-String "Version").ToString()

            If ($ApproachRateNum -lt $MinimumuAR) {
                $FileToEdit = $_
                $ShortName  = $FileToEdit -replace (".osu", "")
                $NewItem    = "$($ShortName)$($Suffix).osu"
                $Path       = "$SongFolder\$Folder"

                If (!(Get-Item -LiteralPath "$Path\$NewItem")) {
                    Write-Output "`n`n----------------------------------------------------------------------------------------"
                    Write-Output "$($FileToEdit.Name)"
                    Write-Output "AR10 Version does not exist "
                    Write-Output "Current AR: ApproachRate:$ApproachRateNum"
                    Write-Output "Current Diff: OverallDifficulty:$DiffNumb"
                    Write-Output "Copying to new file: $NewItem"
                    Write-Output ""
                    
               
                    Copy-Item -LiteralPath "$Path\$FileToEdit" -Destination "$Path\$NewItem" -Force

                    ((Get-Content -LiteralPath "$Path\$NewItem").Replace("$ApproachRate", "ApproachRate:$MinimumuAR").Replace($Version,"$($Version)$Suffix") `
                        | Set-Content -LiteralPath "$Path\$NewItem")
                }
                Else {
                    Write-Output "`n`n----------------------------------------------------------------------------------------"
                    Write-Output "AR10 Version already exists, skipping:"
                    Write-Output (Get-Item -LiteralPath "$Path\$NewItem").Name
                }
            }
        }
    }
}






















