function Show-CustomVhdxDriveEditor {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Drives,

        [Parameter(Mandatory)]
        [string]$ConfigPath
    )
    #$Drives = @(Get-DefaultCustomVhdxDrive);# + $Drives;
    Assert-CustomVhdxDrive -Drives $Drives
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    $form = [System.Windows.Forms.Form]::new()
    try {
        $form.Text = 'Custom VHDX drive settings'
        $form.Size = [System.Drawing.Size]::new(1100, 420)
        $form.MinimumSize = [System.Drawing.Size]::new(650, 300)
        $form.StartPosition = 'CenterScreen'

        $label = [System.Windows.Forms.Label]::new()
        $label.Text = 'Check drives to enable them. Save changes settings only; run Sync separately to mount or dismount.'
        $label.SetBounds(12, 12, 1050, 30)
        $label.Anchor = 'Top, Left, Right'

        $list = [System.Windows.Forms.CheckedListBox]::new()
        $list.Name = 'Drives'
        $list.SetBounds(12, 48, 1060, 270)
        $list.Anchor = 'Top, Bottom, Left, Right'
        $list.CheckOnClick = $true
        $list.HorizontalScrollbar = $true
        $list.DisplayMember = 'Path'
        foreach ($drive in $Drives) {
            if ([bool]$drive.IsEnabled) {
                $checkState = [System.Windows.Forms.CheckState]::Checked;
            }
            else {
                $checkState = [System.Windows.Forms.CheckState]::Unchecked;
            }
            [void]$list.Items.Add($drive, $checkState);
        }

        $PathSortButton = [System.Windows.Forms.Button]::new();
        $PathSortButton.Name = 'Sort'
        $PathSortButton.Text = 'Sort by path'
        $PathSortButton.SetBounds(780, 335, 90, 30)
        $PathSortButton.Anchor = 'Bottom, Right'
        $PathSortButton.Add_Click({
                $Drives = $Drives | Sort-Object -Property Path
                $list.Items.Clear()
                foreach ($drive in $Drives) {
                    $checkState = if ([bool]$drive.IsEnabled) { [System.Windows.Forms.CheckState]::Checked } else { [System.Windows.Forms.CheckState]::Unchecked }
                    [void]$list.Items.Add($drive, $checkState)
                }
            })

        $EnabledSortButton = [System.Windows.Forms.Button]::new()
        $EnabledSortButton.Name = 'SortEnabled'
        $EnabledSortButton.Text = 'Sort by Enabled'
        $EnabledSortButton.SetBounds(640, 335, 100, 30)
        $EnabledSortButton.Anchor = 'Bottom, Right'
        $EnabledSortButton.Add_Click({
                $Drives = $Drives | Sort-Object -Property IsEnabled  -Descending
                $list.Items.Clear()
                foreach ($drive in $Drives) {
                    $checkState = if ([bool]$drive.IsEnabled) { [System.Windows.Forms.CheckState]::Checked } else { [System.Windows.Forms.CheckState]::Unchecked }
                    [void]$list.Items.Add($drive, $checkState)
                }
            })

        $save = [System.Windows.Forms.Button]::new()
        $save.Name = 'Save'
        $save.Text = 'Save'
        $save.SetBounds(880, 335, 90, 30)
        $save.Anchor = 'Bottom, Right'
        $save.Add_Click({
                try {
                    $updated = @(
                        for ($index = 0; $index -lt $list.Items.Count; $index++) {
                            [pscustomobject]@{
                                Path      = $list.Items[$index].Path
                                IsEnabled = $list.GetItemChecked($index)
                            }
                        }
                    )
                    Save-CustomVhdxDrive -Drives $updated -ConfigPath $ConfigPath
                    $form.Tag = $updated
                    $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $form.Close()
                }
                catch {
                    Write-Error -ErrorRecord $_ -ErrorAction Continue
                    [void][System.Windows.Forms.MessageBox]::Show(
                        $form, $_.Exception.Message, 'Unable to save drive settings',
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Error
                    )
                }
            })

        $cancel = [System.Windows.Forms.Button]::new()
        $cancel.Name = 'Cancel'
        $cancel.Text = 'Cancel'
        $cancel.SetBounds(982, 335, 90, 30)
        $cancel.Anchor = 'Bottom, Right'
        $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.AcceptButton = $save
        $form.CancelButton = $cancel
        $form.Controls.AddRange(@($label, $list, $PathSortButton, $EnabledSortButton, $save, $cancel))

        if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $form.Tag
        }
        else {
            $Drives
        }
    }
    finally {
        $form.Dispose()
    }
}
