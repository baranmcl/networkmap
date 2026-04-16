## Create NetworkMap.xlsx with all 4 sheets and sample data
## Uses Excel COM automation — requires Excel to be installed

$ErrorActionPreference = "Stop"

$outputPath = Join-Path $PSScriptRoot "..\data\NetworkMap.xlsx"
$outputPath = [System.IO.Path]::GetFullPath($outputPath)

# Clean up existing file
if (Test-Path $outputPath) { Remove-Item $outputPath -Force }

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    $workbook = $excel.Workbooks.Add()

    # =========================================================
    # Sheet 1: Sites
    # =========================================================
    $ws = $workbook.Sheets.Item(1)
    $ws.Name = "Sites"

    $headers = @("SiteID", "SiteName", "FacilityType", "City", "Country", "Region")
    for ($i = 0; $i -lt $headers.Length; $i++) {
        $ws.Cells.Item(1, $i + 1).Value2 = $headers[$i]
    }

    $sites = @(
        @("MFG-001", "Springfield Plant",      "Manufacturing Site",    "Springfield",   "United States",  "North America"),
        @("MFG-002", "Munich Factory",          "Manufacturing Site",    "Munich",        "Germany",        "Europe"),
        @("MFG-003", "Shanghai Works",          "Manufacturing Site",    "Shanghai",      "China",          "Asia Pacific"),
        @("DC-001",  "Atlanta Hub",             "Distribution Center",   "Atlanta",       "United States",  "North America"),
        @("DC-002",  "Rotterdam Hub",           "Distribution Center",   "Rotterdam",     "Netherlands",    "Europe"),
        @("WH-001",  "Dallas Warehouse",        "Warehouse",             "Dallas",        "United States",  "North America"),
        @("WH-002",  "Singapore Warehouse",     "Warehouse",             "Singapore",     "Singapore",      "Asia Pacific"),
        @("SC-001",  "Toronto Service Center",  "Service Center",        "Toronto",       "Canada",         "North America"),
        @("SC-002",  "London Service Center",   "Service Center",        "London",        "United Kingdom", "Europe"),
        @("CM-001",  "Guadalajara CM",          "Contract Manufacturer", "Guadalajara",   "Mexico",         "North America"),
        @("CM-002",  "Shenzhen CM",             "Contract Manufacturer", "Shenzhen",      "China",          "Asia Pacific")
    )

    for ($r = 0; $r -lt $sites.Length; $r++) {
        for ($c = 0; $c -lt $sites[$r].Length; $c++) {
            $ws.Cells.Item($r + 2, $c + 1).Value2 = $sites[$r][$c]
        }
    }

    # Format as table
    $lastRow = $sites.Length + 1
    $range = $ws.Range("A1:F$lastRow")
    $table = $ws.ListObjects.Add(1, $range, $null, 1) # xlSrcRange=1, xlYes=1
    $table.Name = "tblSites"

    # Auto-fit columns
    $range.EntireColumn.AutoFit() | Out-Null

    # =========================================================
    # Sheet 2: COGP_Monthly
    # =========================================================
    $ws2 = $workbook.Sheets.Add([System.Reflection.Missing]::Value, $workbook.Sheets.Item($workbook.Sheets.Count))
    $ws2.Name = "COGP_Monthly"

    $headers2 = @("SiteID", "Year", "Month", "COGP_Actual")
    for ($i = 0; $i -lt $headers2.Length; $i++) {
        $ws2.Cells.Item(1, $i + 1).Value2 = $headers2[$i]
    }

    # COGP-eligible sites with monthly base values
    $cogpSites = @{
        "MFG-001" = @(1100000, 1150000, 1250000, 1200000, 1300000, 1280000, 1100000, 1350000, 1400000, 1250000, 1200000, 1420000)
        "MFG-002" = @(950000,  980000,  1010000, 970000,  1020000, 1050000, 900000,  1080000, 1100000, 1040000, 990000,  1110000)
        "MFG-003" = @(1500000, 1550000, 1600000, 1480000, 1620000, 1580000, 1450000, 1700000, 1650000, 1600000, 1520000, 1750000)
        "CM-001"  = @(680000,  710000,  730000,  700000,  750000,  740000,  660000,  780000,  790000,  720000,  700000,  810000)
        "CM-002"  = @(820000,  850000,  870000,  840000,  890000,  880000,  800000,  920000,  910000,  870000,  840000,  950000)
    }

    $row = 2
    foreach ($siteId in @("MFG-001", "MFG-002", "MFG-003", "CM-001", "CM-002")) {
        $baseValues = $cogpSites[$siteId]

        # 2024: 12 months
        for ($m = 1; $m -le 12; $m++) {
            $ws2.Cells.Item($row, 1).Value2 = $siteId
            $ws2.Cells.Item($row, 2).Value2 = [double]2024
            $ws2.Cells.Item($row, 3).Value2 = [double]$m
            $ws2.Cells.Item($row, 4).Value2 = [double]$baseValues[$m - 1]
            $row++
        }

        # 2025: 3 months (slightly adjusted values)
        $adjustments = @(80000, 70000, 60000)
        for ($m = 1; $m -le 3; $m++) {
            $ws2.Cells.Item($row, 1).Value2 = $siteId
            $ws2.Cells.Item($row, 2).Value2 = [double]2025
            $ws2.Cells.Item($row, 3).Value2 = [double]$m
            $val = $baseValues[$m - 1] + $adjustments[$m - 1]
            $ws2.Cells.Item($row, 4).Value2 = [double]$val
            $row++
        }
    }

    # Format as table
    $lastRow2 = $row - 1
    $range2 = $ws2.Range("A1:D$lastRow2")
    $table2 = $ws2.ListObjects.Add(1, $range2, $null, 1)
    $table2.Name = "tblCOGP_Monthly"

    # Format COGP_Actual as number with no decimals
    $ws2.Range("D2:D$lastRow2").NumberFormat = "#,##0"
    $range2.EntireColumn.AutoFit() | Out-Null

    # =========================================================
    # Sheet 3: ProfitCenters
    # =========================================================
    $ws3 = $workbook.Sheets.Add([System.Reflection.Missing]::Value, $workbook.Sheets.Item($workbook.Sheets.Count))
    $ws3.Name = "ProfitCenters"

    $headers3 = @("ProfitCenter", "Description", "BusinessSegment")
    for ($i = 0; $i -lt $headers3.Length; $i++) {
        $ws3.Cells.Item(1, $i + 1).Value2 = $headers3[$i]
    }

    $pcs = @(
        @("IC-4010", "Hydraulic Components", "Industrial"),
        @("IC-4020", "Power Systems",        "Industrial"),
        @("IC-4030", "Control Units",        "Industrial"),
        @("CM-5010", "HVAC Systems",         "Commercial"),
        @("CM-5020", "Building Controls",    "Commercial"),
        @("AG-6010", "Irrigation Equipment", "Agricultural")
    )

    for ($r = 0; $r -lt $pcs.Length; $r++) {
        for ($c = 0; $c -lt $pcs[$r].Length; $c++) {
            $ws3.Cells.Item($r + 2, $c + 1).Value2 = $pcs[$r][$c]
        }
    }

    $lastRow3 = $pcs.Length + 1
    $range3 = $ws3.Range("A1:C$lastRow3")
    $table3 = $ws3.ListObjects.Add(1, $range3, $null, 1)
    $table3.Name = "tblProfitCenters"
    $range3.EntireColumn.AutoFit() | Out-Null

    # =========================================================
    # Sheet 4: COGP_Plan
    # =========================================================
    $ws4 = $workbook.Sheets.Add([System.Reflection.Missing]::Value, $workbook.Sheets.Item($workbook.Sheets.Count))
    $ws4.Name = "COGP_Plan"

    $headers4 = @("SiteID", "Year", "ProfitCenter", "COGP_Plan")
    for ($i = 0; $i -lt $headers4.Length; $i++) {
        $ws4.Cells.Item(1, $i + 1).Value2 = $headers4[$i]
    }

    $plans = @(
        @("MFG-001", 2024, "IC-4010", 5200000),
        @("MFG-001", 2024, "IC-4020", 4300000),
        @("MFG-001", 2024, "CM-5010", 5500000),
        @("MFG-001", 2025, "IC-4010", 5500000),
        @("MFG-001", 2025, "IC-4020", 4500000),
        @("MFG-001", 2025, "CM-5010", 5800000),
        @("MFG-002", 2024, "IC-4010", 3800000),
        @("MFG-002", 2024, "IC-4030", 3200000),
        @("MFG-002", 2024, "CM-5020", 5200000),
        @("MFG-002", 2025, "IC-4010", 4000000),
        @("MFG-002", 2025, "IC-4030", 3400000),
        @("MFG-002", 2025, "CM-5020", 5400000),
        @("MFG-003", 2024, "IC-4020", 6000000),
        @("MFG-003", 2024, "CM-5010", 5800000),
        @("MFG-003", 2024, "AG-6010", 7200000),
        @("MFG-003", 2025, "IC-4020", 6300000),
        @("MFG-003", 2025, "CM-5010", 6100000),
        @("MFG-003", 2025, "AG-6010", 7500000),
        @("CM-001",  2024, "IC-4010", 4200000),
        @("CM-001",  2024, "CM-5010", 4600000),
        @("CM-001",  2025, "IC-4010", 4400000),
        @("CM-001",  2025, "CM-5010", 4800000),
        @("CM-002",  2024, "IC-4030", 5100000),
        @("CM-002",  2024, "AG-6010", 5400000),
        @("CM-002",  2025, "IC-4030", 5300000),
        @("CM-002",  2025, "AG-6010", 5600000)
    )

    for ($r = 0; $r -lt $plans.Length; $r++) {
        $ws4.Cells.Item($r + 2, 1).Value2 = [string]$plans[$r][0]
        $ws4.Cells.Item($r + 2, 2).Value2 = [double]$plans[$r][1]
        $ws4.Cells.Item($r + 2, 3).Value2 = [string]$plans[$r][2]
        $ws4.Cells.Item($r + 2, 4).Value2 = [double]$plans[$r][3]
    }

    $lastRow4 = $plans.Length + 1
    $range4 = $ws4.Range("A1:D$lastRow4")
    $table4 = $ws4.ListObjects.Add(1, $range4, $null, 1)
    $table4.Name = "tblCOGP_Plan"

    $ws4.Range("D2:D$lastRow4").NumberFormat = "#,##0"
    $range4.EntireColumn.AutoFit() | Out-Null

    # =========================================================
    # Remove default Sheet1 if extra sheets exist
    # =========================================================
    # Excel creates default sheets — remove any unnamed extras
    foreach ($sheet in $workbook.Sheets) {
        if ($sheet.Name -match "^Sheet\d+$" -and $workbook.Sheets.Count -gt 4) {
            $sheet.Delete()
        }
    }

    # Reorder sheets: Sites, COGP_Monthly, ProfitCenters, COGP_Plan
    $workbook.Sheets.Item("Sites").Move($workbook.Sheets.Item(1))

    # Save
    $workbook.SaveAs($outputPath, 51) # 51 = xlOpenXMLWorkbook (.xlsx)
    Write-Host "Workbook saved to: $outputPath"
    Write-Host ""
    Write-Host "Sheet summary:"
    foreach ($sheet in $workbook.Sheets) {
        $tbl = $sheet.ListObjects.Item(1)
        $rowCount = $tbl.ListRows.Count
        Write-Host "  $($sheet.Name): $rowCount data rows (table: $($tbl.Name))"
    }

} finally {
    $workbook.Close($false)
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
}
