# PowerBI Network Map Dashboard — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a PowerBI dashboard with an interactive map showing the company's global facility network, with COGP visibility for manufacturing sites and contract manufacturers.

**Architecture:** A single-page PowerBI report backed by a 4-sheet Excel workbook. The map uses PowerBI's native Bing Maps visual with city/country geocoding. DAX measures handle YTD calculations and conditional tooltip logic. The Excel workbook lives in this repo as a template with sample data.

**Tech Stack:** PowerBI Desktop, Excel (.xlsx), DAX

---

### Task 1: Create the Excel Workbook with Sample Data

Create a template workbook with all four sheets populated with realistic sample data so the dashboard can be built and tested before real data is entered.

**Files:**
- Create: `data/NetworkMap.xlsx`

- [ ] **Step 1: Create the `Sites` sheet**

Open Excel and create a new workbook. Name the first sheet `Sites`. Enter the following headers in row 1 and sample data starting in row 2:

| SiteID  | SiteName               | FacilityType          | City          | Country        | Region         |
|---------|------------------------|-----------------------|---------------|----------------|----------------|
| MFG-001 | Springfield Plant      | Manufacturing Site    | Springfield   | United States  | North America  |
| MFG-002 | Munich Factory         | Manufacturing Site    | Munich        | Germany        | Europe         |
| MFG-003 | Shanghai Works         | Manufacturing Site    | Shanghai      | China          | Asia Pacific   |
| DC-001  | Atlanta Hub            | Distribution Center   | Atlanta       | United States  | North America  |
| DC-002  | Rotterdam Hub          | Distribution Center   | Rotterdam     | Netherlands    | Europe         |
| WH-001  | Dallas Warehouse       | Warehouse             | Dallas        | United States  | North America  |
| WH-002  | Singapore Warehouse    | Warehouse             | Singapore     | Singapore      | Asia Pacific   |
| SC-001  | Toronto Service Center | Service Center        | Toronto       | Canada         | North America  |
| SC-002  | London Service Center  | Service Center        | London        | United Kingdom | Europe         |
| CM-001  | Guadalajara CM         | Contract Manufacturer | Guadalajara   | Mexico         | North America  |
| CM-002  | Shenzhen CM            | Contract Manufacturer | Shenzhen      | China          | Asia Pacific   |

- [ ] **Step 2: Create the `COGP_Monthly` sheet**

Add a new sheet named `COGP_Monthly`. Enter the following headers and sample data. Include 12 months for 2024 and 3 months for 2025 for each COGP-eligible site (MFG-001, MFG-002, MFG-003, CM-001, CM-002).

| SiteID  | Year | Month | COGP_Actual |
|---------|------|-------|-------------|
| MFG-001 | 2024 | 1     | 1100000     |
| MFG-001 | 2024 | 2     | 1150000     |
| MFG-001 | 2024 | 3     | 1250000     |
| MFG-001 | 2024 | 4     | 1200000     |
| MFG-001 | 2024 | 5     | 1300000     |
| MFG-001 | 2024 | 6     | 1280000     |
| MFG-001 | 2024 | 7     | 1100000     |
| MFG-001 | 2024 | 8     | 1350000     |
| MFG-001 | 2024 | 9     | 1400000     |
| MFG-001 | 2024 | 10    | 1250000     |
| MFG-001 | 2024 | 11    | 1200000     |
| MFG-001 | 2024 | 12    | 1420000     |
| MFG-001 | 2025 | 1     | 1180000     |
| MFG-001 | 2025 | 2     | 1220000     |
| MFG-001 | 2025 | 3     | 1310000     |
| MFG-002 | 2024 | 1     | 950000      |
| MFG-002 | 2024 | 2     | 980000      |
| MFG-002 | 2024 | 3     | 1010000     |
| MFG-002 | 2024 | 4     | 970000      |
| MFG-002 | 2024 | 5     | 1020000     |
| MFG-002 | 2024 | 6     | 1050000     |
| MFG-002 | 2024 | 7     | 900000      |
| MFG-002 | 2024 | 8     | 1080000     |
| MFG-002 | 2024 | 9     | 1100000     |
| MFG-002 | 2024 | 10    | 1040000     |
| MFG-002 | 2024 | 11    | 990000      |
| MFG-002 | 2024 | 12    | 1110000     |
| MFG-002 | 2025 | 1     | 960000      |
| MFG-002 | 2025 | 2     | 1000000     |
| MFG-002 | 2025 | 3     | 1050000     |
| MFG-003 | 2024 | 1     | 1500000     |
| MFG-003 | 2024 | 2     | 1550000     |
| MFG-003 | 2024 | 3     | 1600000     |
| MFG-003 | 2024 | 4     | 1480000     |
| MFG-003 | 2024 | 5     | 1620000     |
| MFG-003 | 2024 | 6     | 1580000     |
| MFG-003 | 2024 | 7     | 1450000     |
| MFG-003 | 2024 | 8     | 1700000     |
| MFG-003 | 2024 | 9     | 1650000     |
| MFG-003 | 2024 | 10    | 1600000     |
| MFG-003 | 2024 | 11    | 1520000     |
| MFG-003 | 2024 | 12    | 1750000     |
| MFG-003 | 2025 | 1     | 1530000     |
| MFG-003 | 2025 | 2     | 1580000     |
| MFG-003 | 2025 | 3     | 1620000     |
| CM-001  | 2024 | 1     | 680000      |
| CM-001  | 2024 | 2     | 710000      |
| CM-001  | 2024 | 3     | 730000      |
| CM-001  | 2024 | 4     | 700000      |
| CM-001  | 2024 | 5     | 750000      |
| CM-001  | 2024 | 6     | 740000      |
| CM-001  | 2024 | 7     | 660000      |
| CM-001  | 2024 | 8     | 780000      |
| CM-001  | 2024 | 9     | 790000      |
| CM-001  | 2024 | 10    | 720000      |
| CM-001  | 2024 | 11    | 700000      |
| CM-001  | 2024 | 12    | 810000      |
| CM-001  | 2025 | 1     | 700000      |
| CM-001  | 2025 | 2     | 720000      |
| CM-001  | 2025 | 3     | 750000      |
| CM-002  | 2024 | 1     | 820000      |
| CM-002  | 2024 | 2     | 850000      |
| CM-002  | 2024 | 3     | 870000      |
| CM-002  | 2024 | 4     | 840000      |
| CM-002  | 2024 | 5     | 890000      |
| CM-002  | 2024 | 6     | 880000      |
| CM-002  | 2024 | 7     | 800000      |
| CM-002  | 2024 | 8     | 920000      |
| CM-002  | 2024 | 9     | 910000      |
| CM-002  | 2024 | 10    | 870000      |
| CM-002  | 2024 | 11    | 840000      |
| CM-002  | 2024 | 12    | 950000      |
| CM-002  | 2025 | 1     | 830000      |
| CM-002  | 2025 | 2     | 860000      |
| CM-002  | 2025 | 3     | 900000      |

- [ ] **Step 3: Create the `ProfitCenters` sheet**

Add a new sheet named `ProfitCenters`. Enter the following headers and sample data:

| ProfitCenter | Description           | BusinessSegment |
|--------------|-----------------------|-----------------|
| IC-4010      | Hydraulic Components  | Industrial      |
| IC-4020      | Power Systems         | Industrial      |
| IC-4030      | Control Units         | Industrial      |
| CM-5010      | HVAC Systems          | Commercial      |
| CM-5020      | Building Controls     | Commercial      |
| AG-6010      | Irrigation Equipment  | Agricultural    |

- [ ] **Step 4: Create the `COGP_Plan` sheet**

Add a new sheet named `COGP_Plan`. Enter the following headers and sample data. Each COGP-eligible site gets rows for multiple profit centers across 2024 and 2025:

| SiteID  | Year | ProfitCenter | COGP_Plan |
|---------|------|--------------|-----------|
| MFG-001 | 2024 | IC-4010      | 5200000   |
| MFG-001 | 2024 | IC-4020      | 4300000   |
| MFG-001 | 2024 | CM-5010      | 5500000   |
| MFG-001 | 2025 | IC-4010      | 5500000   |
| MFG-001 | 2025 | IC-4020      | 4500000   |
| MFG-001 | 2025 | CM-5010      | 5800000   |
| MFG-002 | 2024 | IC-4010      | 3800000   |
| MFG-002 | 2024 | IC-4030      | 3200000   |
| MFG-002 | 2024 | CM-5020      | 5200000   |
| MFG-002 | 2025 | IC-4010      | 4000000   |
| MFG-002 | 2025 | IC-4030      | 3400000   |
| MFG-002 | 2025 | CM-5020      | 5400000   |
| MFG-003 | 2024 | IC-4020      | 6000000   |
| MFG-003 | 2024 | CM-5010      | 5800000   |
| MFG-003 | 2024 | AG-6010      | 7200000   |
| MFG-003 | 2025 | IC-4020      | 6300000   |
| MFG-003 | 2025 | CM-5010      | 6100000   |
| MFG-003 | 2025 | AG-6010      | 7500000   |
| CM-001  | 2024 | IC-4010      | 4200000   |
| CM-001  | 2024 | CM-5010      | 4600000   |
| CM-001  | 2025 | IC-4010      | 4400000   |
| CM-001  | 2025 | CM-5010      | 4800000   |
| CM-002  | 2024 | IC-4030      | 5100000   |
| CM-002  | 2024 | AG-6010      | 5400000   |
| CM-002  | 2025 | IC-4030      | 5300000   |
| CM-002  | 2025 | AG-6010      | 5600000   |

- [ ] **Step 5: Format and save the workbook**

1. For each sheet, select all data and format as an Excel Table (Ctrl+T). Name the tables:
   - `Sites` sheet → table name `tblSites`
   - `COGP_Monthly` sheet → table name `tblCOGP_Monthly`
   - `COGP_Plan` sheet → table name `tblCOGP_Plan`
   - `ProfitCenters` sheet → table name `tblProfitCenters`
2. Format `COGP_Actual` and `COGP_Plan` columns as Number with no decimal places.
3. Save the workbook as `data/NetworkMap.xlsx`.

- [ ] **Step 6: Verify the workbook**

Open the workbook and confirm:
- 4 sheets exist: `Sites`, `COGP_Monthly`, `COGP_Plan`, `ProfitCenters`
- Each sheet has a named table
- `Sites` has 11 rows of data (5 facility types represented)
- `COGP_Monthly` has 75 rows (5 sites × 15 months)
- `COGP_Plan` has 24 rows (5 sites × varying profit centers × 2 years)
- `ProfitCenters` has 6 rows
- All SiteIDs in `COGP_Monthly` and `COGP_Plan` match entries in `Sites`
- All ProfitCenter codes in `COGP_Plan` match entries in `ProfitCenters`

- [ ] **Step 7: Commit**

```bash
git add data/NetworkMap.xlsx
git commit -m "feat: add Excel workbook template with sample data for all 4 sheets"
```

---

### Task 2: Load Data into PowerBI and Set Up Relationships

Connect PowerBI to the Excel workbook, import all four tables, and configure the data model relationships.

**Files:**
- Create: `NetworkMap.pbix` (PowerBI file, saved at repo root)

- [ ] **Step 1: Create a new PowerBI report and connect to Excel**

1. Open PowerBI Desktop.
2. Click **Get Data** → **Excel Workbook**.
3. Navigate to `data/NetworkMap.xlsx`.
4. In the Navigator pane, check all four tables: `tblSites`, `tblCOGP_Monthly`, `tblCOGP_Plan`, `tblProfitCenters`.
5. Click **Transform Data** to open Power Query Editor.

- [ ] **Step 2: Review and clean data types in Power Query**

In Power Query Editor, verify the column types for each table:

**tblSites:**
- SiteID → Text
- SiteName → Text
- FacilityType → Text
- City → Text
- Country → Text
- Region → Text

**tblCOGP_Monthly:**
- SiteID → Text
- Year → Whole Number
- Month → Whole Number
- COGP_Actual → Decimal Number

**tblCOGP_Plan:**
- SiteID → Text
- Year → Whole Number
- ProfitCenter → Text
- COGP_Plan → Decimal Number

**tblProfitCenters:**
- ProfitCenter → Text
- Description → Text
- BusinessSegment → Text

If any types are wrong, click the column header icon and change it. Click **Close & Apply** when done.

- [ ] **Step 3: Set up data model relationships**

1. Go to **Model view** (left sidebar, the diagram icon).
2. Create the following relationships by dragging fields between tables:

**Relationship 1:** `tblSites[SiteID]` → `tblCOGP_Monthly[SiteID]`
- Cardinality: One to Many
- Cross filter direction: Single
- Active: Yes

**Relationship 2:** `tblSites[SiteID]` → `tblCOGP_Plan[SiteID]`
- Cardinality: One to Many
- Cross filter direction: Single
- Active: Yes

**Relationship 3:** `tblProfitCenters[ProfitCenter]` → `tblCOGP_Plan[ProfitCenter]`
- Cardinality: One to Many
- Cross filter direction: Single
- Active: Yes

3. Verify no other auto-detected relationships exist. Delete any incorrect auto-relationships.

- [ ] **Step 4: Verify relationships**

In Model view, confirm:
- 3 relationships shown as lines between tables
- `tblSites` connects to both `tblCOGP_Monthly` and `tblCOGP_Plan`
- `tblProfitCenters` connects to `tblCOGP_Plan`
- All arrows point from the "one" side to the "many" side

- [ ] **Step 5: Save the PowerBI file**

Save the file as `NetworkMap.pbix` in the repo root.

- [ ] **Step 6: Commit**

```bash
git add NetworkMap.pbix
git commit -m "feat: add PowerBI file with data connection and model relationships"
```

---

### Task 3: Create DAX Measures

Add calculated measures for YTD COGP, selected month COGP, total plan COGP, and site counts.

**Files:**
- Modify: `NetworkMap.pbix`

- [ ] **Step 1: Create a Measures table**

In PowerBI Desktop, go to **Report view**. Click **Modeling** → **New Table**. Enter:

```dax
_Measures = ROW("Placeholder", 0)
```

This creates a dedicated table to hold all measures (keeps the model organized). Hide the `Placeholder` column by right-clicking it → **Hide in report view**.

- [ ] **Step 2: Create the YTD COGP Actual measure**

Right-click the `_Measures` table → **New Measure**. Enter:

```dax
YTD COGP Actual = 
VAR SelectedYear = SELECTEDVALUE(tblCOGP_Monthly[Year])
VAR SelectedMonth = SELECTEDVALUE(tblCOGP_Monthly[Month])
RETURN
    IF(
        ISBLANK(SelectedMonth),
        CALCULATE(
            SUM(tblCOGP_Monthly[COGP_Actual]),
            tblCOGP_Monthly[Year] = SelectedYear
        ),
        CALCULATE(
            SUM(tblCOGP_Monthly[COGP_Actual]),
            tblCOGP_Monthly[Year] = SelectedYear,
            tblCOGP_Monthly[Month] <= SelectedMonth
        )
    )
```

Format the measure: In the **Properties** pane, set Format to **Currency ($)** with 0 decimal places.

- [ ] **Step 3: Verify YTD COGP Actual**

1. Add a temporary Table visual to the canvas.
2. Add `tblSites[SiteName]` and `YTD COGP Actual` to the table.
3. Confirm values appear for MFG and CM sites only.
4. Values should show full-year totals since no month filter is applied yet.
5. Delete the temporary table when verified.

- [ ] **Step 4: Create the Selected Month COGP measure**

Right-click the `_Measures` table → **New Measure**. Enter:

```dax
Selected Month COGP = 
VAR SelectedYear = SELECTEDVALUE(tblCOGP_Monthly[Year])
VAR SelectedMonth = SELECTEDVALUE(tblCOGP_Monthly[Month])
RETURN
    IF(
        NOT ISBLANK(SelectedMonth),
        CALCULATE(
            SUM(tblCOGP_Monthly[COGP_Actual]),
            tblCOGP_Monthly[Year] = SelectedYear,
            tblCOGP_Monthly[Month] = SelectedMonth
        )
    )
```

Format as **Currency ($)** with 0 decimal places.

- [ ] **Step 5: Create the Total COGP Plan measure**

Right-click the `_Measures` table → **New Measure**. Enter:

```dax
Total COGP Plan = 
VAR SelectedYear = SELECTEDVALUE(tblCOGP_Plan[Year])
RETURN
    CALCULATE(
        SUM(tblCOGP_Plan[COGP_Plan]),
        tblCOGP_Plan[Year] = SelectedYear
    )
```

Format as **Currency ($)** with 0 decimal places.

- [ ] **Step 6: Create the Site Count measure**

Right-click the `_Measures` table → **New Measure**. Enter:

```dax
Site Count = DISTINCTCOUNT(tblSites[SiteID])
```

Format as **Whole Number**.

- [ ] **Step 7: Verify all measures**

Add a temporary Table visual. Add `tblSites[FacilityType]`, `Site Count`, `YTD COGP Actual`, and `Total COGP Plan`. Confirm:
- Site Count shows the correct count per type (3 Mfg, 2 DC, 2 WH, 2 SC, 2 CM)
- YTD COGP Actual and Total COGP Plan show values only for Manufacturing Site and Contract Manufacturer rows
- Other facility types show blank for COGP columns

Delete the temporary table when verified.

- [ ] **Step 8: Save and commit**

Save the PowerBI file.

```bash
git add NetworkMap.pbix
git commit -m "feat: add DAX measures for YTD COGP, monthly COGP, plan COGP, and site count"
```

---

### Task 4: Build the Filters Bar

Add slicers for Facility Type, Year, Month, Region, and Business Segment across the top of the report page.

**Files:**
- Modify: `NetworkMap.pbix`

- [ ] **Step 1: Set up the page layout**

1. In Report view, click on the canvas background.
2. In **Format** pane → **Canvas settings**, set:
   - Type: Custom
   - Width: 1280
   - Height: 720
3. This gives a standard 16:9 layout.

- [ ] **Step 2: Add the Facility Type slicer**

1. Click **Visualizations** → **Slicer**.
2. Drag `tblSites[FacilityType]` into the **Field** well.
3. In the **Format** pane → **Slicer settings** → **Selection**: enable **Multi-select with CTRL** (this is default for list slicers).
4. Change slicer style to **Dropdown** (click the down-arrow icon at the top of the slicer).
5. Position: top-left of the canvas. Approximate size: 200px wide × 40px tall.
6. Set the header text to "Facility Type".

- [ ] **Step 3: Add the Year slicer**

1. Add a new **Slicer** visual.
2. Drag `tblCOGP_Monthly[Year]` into the **Field** well.
3. Set style to **Dropdown**.
4. In **Slicer settings** → **Selection**: set to single-select.
5. Position: to the right of the Facility Type slicer. Size: 120px wide × 40px tall.
6. Set header text to "Year".

- [ ] **Step 4: Add the Month slicer**

1. Add a new **Slicer** visual.
2. Drag `tblCOGP_Monthly[Month]` into the **Field** well.
3. Set style to **Dropdown**.
4. In **Slicer settings** → **Selection**: set to single-select.
5. Position: to the right of the Year slicer. Size: 120px wide × 40px tall.
6. Set header text to "Month".

Note: When no month is selected, the YTD measure returns full-year totals. This is the "All" default behavior.

- [ ] **Step 5: Add the Region slicer**

1. Add a new **Slicer** visual.
2. Drag `tblSites[Region]` into the **Field** well.
3. Set style to **Dropdown**.
4. Position: to the right of the Month slicer. Size: 160px wide × 40px tall.
5. Set header text to "Region".

- [ ] **Step 6: Add the Business Segment slicer**

1. Add a new **Slicer** visual.
2. Drag `tblProfitCenters[BusinessSegment]` into the **Field** well.
3. Set style to **Dropdown**.
4. Position: to the right of the Region slicer. Size: 180px wide × 40px tall.
5. Set header text to "Business Segment".

- [ ] **Step 7: Verify filters**

1. Select "Manufacturing Site" in the Facility Type dropdown — confirm that only manufacturing sites would be affected (we don't have the map yet, but other slicers should still function).
2. Select "2024" in Year — confirm it constrains the month slicer to months available in 2024.
3. Clear all selections to reset.

- [ ] **Step 8: Save and commit**

Save the PowerBI file.

```bash
git add NetworkMap.pbix
git commit -m "feat: add filter bar with slicers for facility type, year, month, region, segment"
```

---

### Task 5: Build the Summary Cards

Add five card visuals showing site counts by facility type, configured to ignore the Facility Type slicer.

**Files:**
- Modify: `NetworkMap.pbix`

- [ ] **Step 1: Create a card for Manufacturing Site count**

1. Add a **Card** visual to the canvas.
2. Drag `Site Count` measure into the **Fields** well.
3. Position: below the filter bar, left side. Approximate size: 130px wide × 80px tall.
4. Add a visual-level filter: drag `tblSites[FacilityType]` to the **Filters on this visual** area. Select only "Manufacturing Site".
5. In the **Format** pane:
   - **Callout value** → Font size: 28
   - **Category label** → toggle On, text: "Manufacturing"

- [ ] **Step 2: Create cards for the remaining four facility types**

Duplicate the Manufacturing Site card (Ctrl+C, Ctrl+V) four times. For each copy, update the visual-level filter and category label:

**Card 2:**
- Filter: "Distribution Center"
- Label: "Distribution"

**Card 3:**
- Filter: "Warehouse"
- Label: "Warehouse"

**Card 4:**
- Filter: "Service Center"
- Label: "Service"

**Card 5:**
- Filter: "Contract Manufacturer"
- Label: "Contract Mfg"

Position all five cards in a horizontal row below the filter bar.

- [ ] **Step 3: Remove Facility Type slicer interaction from cards**

This ensures the cards always show the full network count regardless of the Facility Type filter:

1. Click the **Facility Type** slicer to select it.
2. Go to **Format** tab in the ribbon → **Edit interactions**.
3. For each of the five card visuals, click the **None** icon (circle with a line) above the card. This prevents the Facility Type slicer from filtering the cards.
4. Leave all other slicers (Year, Month, Region, Segment) with their default interaction (filter) on the cards.
5. Click **Edit interactions** again to exit interaction editing mode.

- [ ] **Step 4: Verify cards**

1. With no filters: confirm cards show 3, 2, 2, 2, 2 (matching the 11 sample sites).
2. Select "Manufacturing Site" in Facility Type slicer — confirm cards still show the same counts.
3. Select "North America" in Region slicer — confirm counts update (should show: Mfg 1, DC 1, WH 1, SC 1, CM 1).
4. Clear all filters.

- [ ] **Step 5: Save and commit**

Save the PowerBI file.

```bash
git add NetworkMap.pbix
git commit -m "feat: add summary cards for site count by facility type"
```

---

### Task 6: Build the Map Visual

Add the Bing Maps visual with color-coded markers by facility type and configure tooltips.

**Files:**
- Modify: `NetworkMap.pbix`

- [ ] **Step 1: Add the map visual**

1. Click **Visualizations** → **Map** (the globe icon — this is the Bing Maps visual).
2. Position: left half of the canvas below the summary cards. Approximate size: 600px wide × 400px tall.
3. Configure the field wells:
   - **Location**: drag `tblSites[City]`
   - **Legend**: drag `tblSites[FacilityType]` (this creates color-coded bubbles)
   - **Tooltips**: drag `tblSites[SiteName]`, `tblSites[FacilityType]`, `tblSites[City]`, `tblSites[Country]`

- [ ] **Step 2: Configure map formatting**

In the **Format** pane:
1. **Map settings**:
   - Style: Road (or Aerial, based on preference)
   - Auto-zoom: On
2. **Bubbles**:
   - Size: set to a fixed small size (since we're not encoding a size variable)
3. **Legend**:
   - Position: Bottom center
   - Font size: 10

- [ ] **Step 3: Add COGP measures to tooltips**

Add the following to the **Tooltips** field well:
- `YTD COGP Actual`
- `Selected Month COGP`
- `Total COGP Plan`

These will show blank for non-COGP facility types (DC, WH, SC) since those sites have no rows in the COGP tables — which is the correct conditional behavior.

- [ ] **Step 4: Verify the map**

1. Confirm all 11 sample sites appear on the map in their correct geographic locations.
2. Confirm the legend shows 5 colors (one per facility type).
3. Hover over a manufacturing site (e.g., Springfield) — confirm tooltip shows:
   - SiteName: Springfield Plant
   - FacilityType: Manufacturing Site
   - City: Springfield
   - Country: United States
   - YTD COGP Actual: a dollar value
   - Total COGP Plan: a dollar value
4. Hover over a non-COGP site (e.g., Atlanta Hub) — confirm tooltip shows:
   - SiteName, FacilityType, City, Country
   - COGP fields are blank or not shown
5. Select "Manufacturing Site" in Facility Type slicer — confirm only manufacturing sites show on map.
6. Clear the filter.

- [ ] **Step 5: Save and commit**

Save the PowerBI file.

```bash
git add NetworkMap.pbix
git commit -m "feat: add map visual with color-coded markers and COGP tooltips"
```

---

### Task 7: Build the COGP Bar Chart

Add a horizontal bar chart showing COGP by site for manufacturing sites and contract manufacturers.

**Files:**
- Modify: `NetworkMap.pbix`

- [ ] **Step 1: Add the bar chart visual**

1. Click **Visualizations** → **Clustered bar chart** (horizontal bars).
2. Position: top-right quadrant of the canvas (right of the map, below the cards). Approximate size: 500px wide × 200px tall.
3. Configure the field wells:
   - **Y-axis**: drag `tblSites[SiteName]`
   - **X-axis**: drag `YTD COGP Actual`

- [ ] **Step 2: Filter bar chart to COGP-eligible sites only**

1. Drag `tblSites[FacilityType]` to the **Filters on this visual** area.
2. Select only "Manufacturing Site" and "Contract Manufacturer".
3. This ensures the bar chart never shows DCs, warehouses, or service centers.

- [ ] **Step 3: Format the bar chart**

In the **Format** pane:
1. **Title**: toggle On, text: "COGP by Site (YTD Actual)"
2. **Data labels**: toggle On, display units: Millions, decimal places: 1
3. **Y-axis**: Sort by value descending (click the "..." menu on the visual → **Sort axis** → **YTD COGP Actual** → **Sort descending**)
4. **X-axis**: Display units: Millions

- [ ] **Step 4: Verify the bar chart**

1. Confirm 5 bars appear (MFG-001, MFG-002, MFG-003, CM-001, CM-002).
2. Select year "2024" — confirm values reflect 2024 data.
3. Select month "3" — confirm values show YTD through March (sum of months 1-3).
4. Select "Asia Pacific" in Region — confirm only Shanghai Works and Shenzhen CM appear.
5. Clear all filters.

- [ ] **Step 5: Save and commit**

Save the PowerBI file.

```bash
git add NetworkMap.pbix
git commit -m "feat: add horizontal bar chart for COGP by site"
```

---

### Task 8: Build the COGP Detail Table

Add a matrix visual that shows the COGP plan breakdown by business segment and profit center when a site is clicked on the map.

**Files:**
- Modify: `NetworkMap.pbix`

- [ ] **Step 1: Add the matrix visual**

1. Click **Visualizations** → **Matrix**.
2. Position: bottom-right quadrant of the canvas (below the bar chart). Approximate size: 500px wide × 200px tall.
3. Configure the field wells:
   - **Rows**: drag `tblProfitCenters[BusinessSegment]`, then drag `tblProfitCenters[ProfitCenter]` below it (creates the hierarchy), then drag `tblProfitCenters[Description]` below that
   - **Values**: drag `Total COGP Plan`

- [ ] **Step 2: Configure matrix formatting**

In the **Format** pane:
1. **Row subtotals**: toggle On (this shows subtotals per Business Segment)
2. **Column subtotals**: toggle Off
3. **Grand total**: toggle On (this shows the total row at the bottom)
4. **Stepped layout**: toggle On (indents profit centers under their segment)
5. **Values** → Format: Currency, 0 decimal places
6. **Title**: toggle On, text: "COGP Plan Breakdown"

- [ ] **Step 3: Expand the hierarchy by default**

1. Click the "..." menu on the matrix visual.
2. Select **Expand all down one level** to show profit centers expanded under segments by default.

- [ ] **Step 4: Configure map-to-table click interaction**

1. Click the **Map** visual to select it.
2. Go to **Format** tab in the ribbon → **Edit interactions**.
3. For the **Matrix** visual, make sure the **Filter** icon is selected (not Highlight or None). This means clicking a site on the map filters the matrix to show only that site's data.
4. Click **Edit interactions** again to exit.

- [ ] **Step 5: Filter matrix to COGP-eligible sites only**

1. Drag `tblSites[FacilityType]` to the **Filters on this visual** area of the matrix.
2. Select only "Manufacturing Site" and "Contract Manufacturer".

- [ ] **Step 6: Verify the detail table**

1. With no site selected: matrix shows all COGP-eligible sites' plan data aggregated by segment/profit center.
2. Click "Springfield Plant" on the map — matrix should filter to show only MFG-001's plan data:
   - Industrial > IC-4010, IC-4020 with subtotal
   - Commercial > CM-5010 with subtotal
   - Grand total at bottom
3. Click "Guadalajara CM" on the map — matrix should show CM-001's plan data:
   - Industrial > IC-4010 with subtotal
   - Commercial > CM-5010 with subtotal
4. Click a DC or warehouse on the map — matrix should show no data (filtered out by visual-level filter).
5. Change year to "2025" — confirm plan values update.
6. Click away from the map to deselect — matrix returns to showing all sites.

- [ ] **Step 7: Save and commit**

Save the PowerBI file.

```bash
git add NetworkMap.pbix
git commit -m "feat: add COGP detail matrix with segment/profit center breakdown"
```

---

### Task 9: Final Layout Polish and Cross-Visual Interaction Tuning

Align all visuals, tune cross-filter interactions, and apply consistent formatting.

**Files:**
- Modify: `NetworkMap.pbix`

- [ ] **Step 1: Align and size all visuals**

Use **Format** → **Align** tools in the ribbon to ensure:
1. All five slicers are top-aligned in a single row at the top.
2. All five cards are top-aligned in a row below the slicers.
3. The map fills the left half below the cards.
4. The bar chart and matrix fill the right half, stacked vertically.
5. No visuals overlap.

Approximate layout coordinates (X, Y, Width, Height):
- Slicers row: Y=10, H=40
- Cards row: Y=60, H=70
- Map: X=10, Y=140, W=600, H=400
- Bar chart: X=620, Y=140, W=500, H=190
- Matrix: X=620, Y=340, W=500, H=200

- [ ] **Step 2: Verify all filter interactions**

Test the following interaction matrix:

| Slicer → Visual         | Facility Type | Year | Month | Region | Segment |
|--------------------------|:---:|:---:|:---:|:---:|:---:|
| Summary Cards            | None | - | - | Filter | - |
| Map                      | Filter | Filter | Filter | Filter | Filter |
| Bar Chart                | Filter | Filter | Filter | Filter | Filter |
| Detail Matrix            | Filter | Filter | - | Filter | Filter |

Where "None" means no interaction (already configured in Task 5) and "Filter" means the slicer filters the visual. "-" means no relevant data connection (no action needed).

Adjust any interactions that don't match using **Edit interactions** mode.

- [ ] **Step 3: Apply consistent formatting**

1. Set a consistent font across all visuals: Segoe UI, size 10 for body text, 12 for titles.
2. Set the page background to a light gray (#F2F2F2) to provide contrast.
3. Ensure all currency values use the same format: $X.XM or $X,XXX,XXX.
4. Set the report title: add a **Text box** at the very top of the canvas with text "Network Map — Facility & COGP Dashboard". Font: Segoe UI, 16pt, bold.

- [ ] **Step 4: Final end-to-end verification**

Run through these test scenarios:

**Scenario 1 — Default view:**
- All filters clear
- Map shows all 11 sites, color-coded by type
- Cards show counts: 3, 2, 2, 2, 2
- Bar chart shows 5 bars (all COGP sites)
- Matrix shows all plan data

**Scenario 2 — Filter to Manufacturing Sites only:**
- Select "Manufacturing Site" in Facility Type
- Map shows only 3 manufacturing sites
- Cards still show 3, 2, 2, 2, 2 (unaffected)
- Bar chart shows only 3 manufacturing bars
- Matrix shows only manufacturing plan data

**Scenario 3 — Region + Month drill-down:**
- Select "Asia Pacific" in Region
- Select "2024" in Year, "6" in Month
- Map shows only Asia Pacific sites (Shanghai Works, Singapore Warehouse, Shenzhen CM)
- Cards update to reflect Asia Pacific counts (1, 0, 1, 0, 1)
- Bar chart shows YTD through June for Shanghai Works and Shenzhen CM
- Click Shanghai Works on map — matrix shows MFG-003 plan breakdown

**Scenario 4 — Business Segment filter:**
- Clear all filters, select "Industrial" in Business Segment
- Bar chart and matrix filter to Industrial segment data
- Map and cards still show all sites

- [ ] **Step 5: Save and commit**

Save the PowerBI file.

```bash
git add NetworkMap.pbix
git commit -m "feat: polish layout, tune interactions, complete dashboard"
```

---

### Task 10: Clean Up Repo and Update README

Remove the old sample CSV files and update the README to reflect the actual project.

**Files:**
- Delete: `data/nodes.csv`
- Delete: `data/edges.csv`
- Modify: `README.md`

- [ ] **Step 1: Delete old sample data**

```bash
git rm data/nodes.csv data/edges.csv
```

- [ ] **Step 2: Update README.md**

Replace the contents of `README.md` with:

```markdown
# Network Map — Facility & COGP Dashboard

A PowerBI dashboard visualizing the company's global network of manufacturing sites, distribution centers, warehouses, service centers, and contract manufacturers.

## Features

- Interactive map with color-coded markers by facility type
- COGP (Cost of Goods Produced) tooltips for manufacturing sites and contract manufacturers
- COGP detail table with business segment and profit center breakdown
- Site count summary cards
- COGP comparison bar chart
- Filters: facility type, year, month, region, business segment

## Files

- `NetworkMap.pbix` — PowerBI dashboard file
- `data/NetworkMap.xlsx` — Excel data source (template with sample data)

## Data Structure

The Excel workbook contains four sheets:

| Sheet | Purpose |
|-------|---------|
| `Sites` | All facility locations (name, type, city, country, region) |
| `COGP_Monthly` | Monthly actual COGP by site |
| `COGP_Plan` | Annual plan COGP by site and profit center |
| `ProfitCenters` | Profit center codes, descriptions, and business segment mapping |

## Setup

1. Install [PowerBI Desktop](https://powerbi.microsoft.com/desktop/).
2. Replace sample data in `data/NetworkMap.xlsx` with real facility and COGP data.
3. Open `NetworkMap.pbix` in PowerBI Desktop.
4. If prompted, update the data source path to point to your local copy of `NetworkMap.xlsx`.
5. Click **Refresh** to load the latest data.
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove old sample data and update README for network map dashboard"
```
