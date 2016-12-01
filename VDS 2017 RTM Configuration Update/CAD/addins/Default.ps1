
function InitializeWindow
{
	#begin rules applying commonly
    $dsWindow.Title = SetWindowTitle		
    if ($Prop["_CreateMode"].Value)
    {		
		if (-not $Prop["_SaveCopyAsMode"].Value)
		{
			$Prop["_Category"].add_PropertyChanged({
				if ($_.PropertyName -eq "Value")
				{
					$Prop["_NumSchm"].Value = $Prop["_Category"].Value
				}	
			})
            $Prop["_Category"].Value = $UIString["CAT1"]
        }
		else
        {
            $Prop["_NumSchm"].Value = "None"
        }
        $mappedRootPath = $Prop["_VaultVirtualPath"].Value + $Prop["_WorkspacePath"].Value
    	$mappedRootPath = $mappedRootPath -replace "\\", "/" -replace "//", "/"
        if ($mappedRootPath -eq '')
        {
            $mappedRootPath = '$'
        }
    	$rootFolder = $vault.DocumentService.GetFolderByPath($mappedRootPath)
    	$root = New-Object PSObject -Property @{ Name = $rootFolder.Name; ID=$rootFolder.Id }	
    	AddCombo -data $root
    }
	#end rules applying commonly
	$mWindowName = $dsWindow.Name
	switch($mWindowName)
	{
		"InventorWindow"
		{
			If ($Prop["_CreateMode"].Value) 
			{
				$Prop["Part Number"].Value = "" #reset the part number for new files as Inventor writes the file name (no extension) as a default.
			}
						
		}
		"AutoCADWindow"
		{
			#rules applying for AutoCAD
		}
	}	
}

function AddinLoaded
{
	#Executed when DataStandard is loaded in Inventor/AutoCAD
}
function AddinUnloaded
{
	#Executed when DataStandard is unloaded in Inventor/AutoCAD
}

function SetWindowTitle
{
	if ($Prop["_CreateMode"].Value)
    {
		if ($Prop["_CopyMode"].Value)
		{
			$windowTitle = "$($UIString["LBL60"]) - $($Prop["_OriginalFileName"].Value)"
		}
		elseif ($Prop["_SaveCopyAsMode"].Value)
		{
			$windowTitle = "$($UIString["LBL72"]) - $($Prop["_OriginalFileName"].Value)"
		}else
		{
			$windowTitle = "$($UIString["LBL24"]) - $($Prop["_OriginalFileName"].Value)"
		}
	}
	else
	{
		$windowTitle = "$($UIString["LBL25"]) - $($Prop["_FileName"].Value)"
	}
	return $windowTitle
}

function GetNumSchms
{
	try
	{
		if (-Not $Prop["_EditMode"].Value)
        {
            [System.Collections.ArrayList]$numSchems = @($vault.DocumentService.GetNumberingSchemesByType('Activated'))
            if ($numSchems.Count -gt 1)
			{
				$numSchems = $numSchems | Sort-Object -Property IsDflt -Descending
			}
            if ($Prop["_SaveCopyAsMode"].Value)
            {
                $noneNumSchm = New-Object 'Autodesk.Connectivity.WebServices.NumSchm'
                $noneNumSchm.Name = "None"
                $numSchems.Add($noneNumSchm) | Out-Null
            }    
            return $numSchems
        }
	}
	catch [System.Exception]
	{		
		#[System.Windows.MessageBox]::Show($error)
	}	
}

function GetCategories
{
	return $vault.CategoryService.GetCategoriesByEntityClassId("FILE", $true)
}

function OnPostCloseDialog
{
	$mWindowName = $dsWindow.Name
	switch($mWindowName)
	{
		"InventorWindow"
		{
			#rules applying for Inventor
		}
		"AutoCADWindow"
		{
			#rules applying for AutoCAD
		}
		default
		{
			#rules applying commonly
		}
	}
}
