# PowerBI Network Map Dashboard — Design Spec

## Overview

An interactive PowerBI dashboard displaying the company's global network of manufacturing sites, distribution centers, warehouses, service centers, and contract manufacturers on a map. The dashboard is sourced from a manually maintained Excel workbook and provides COGP (Cost of Goods Produced) visibility for production facilities.

## Facility Types

Five facility types, each color-coded on the map:

1. Manufacturing Site
2. Distribution Center
3. Warehouse
4. Service Center
5. Contract Manufacturer

Fewer than 50 locations total, spread internationally.

## Data Model

### Excel Workbook — 4 Sheets

#### Sheet 1: `Sites`

| Column       | Type   | Description                          | Example             |
|--------------|--------|--------------------------------------|---------------------|
| SiteID       | Text   | Unique identifier                    | MFG-001             |
| SiteName     | Text   | Display name                         | Springfield Plant   |
| FacilityType | Text   | One of the 5 facility types          | Manufacturing Site  |
| City         | Text   | City name (used for geocoding)       | Springfield         |
| Country      | Text   | Country name (used for geocoding)    | United States       |
| Region       | Text   | Geographic grouping for filtering    | North America       |

All five facility types have rows in this sheet.

#### Sheet 2: `COGP_Monthly`

| Column      | Type    | Description              | Example    |
|-------------|---------|--------------------------|------------|
| SiteID      | Text    | FK to Sites              | MFG-001    |
| Year        | Integer | Fiscal year              | 2025       |
| Month       | Integer | Month number (1-12)      | 3          |
| COGP_Actual | Number  | Monthly actual COGP      | 1250000    |

Only manufacturing sites and contract manufacturers have rows in this sheet.

#### Sheet 3: `COGP_Plan`

| Column       | Type    | Description                        | Example    |
|--------------|---------|-------------------------------------|------------|
| SiteID       | Text    | FK to Sites                        | MFG-001    |
| Year         | Integer | Plan year                          | 2025       |
| ProfitCenter | Text    | FK to ProfitCenters                | IC-4010    |
| COGP_Plan    | Number  | Annual plan COGP for this PC split | 5000000    |

Only manufacturing sites and contract manufacturers have rows in this sheet. Each site will have multiple rows — one per profit center.

#### Sheet 4: `ProfitCenters`

| Column          | Type | Description                          | Example              |
|-----------------|------|--------------------------------------|----------------------|
| ProfitCenter    | Text | Unique profit center code            | IC-4010              |
| Description     | Text | Human-readable name                  | Hydraulic Components |
| BusinessSegment | Text | Parent grouping of the profit center | Industrial           |

Lookup table — single source of truth for profit center metadata. Business segment is a parent grouping of profit centers (each profit center belongs to exactly one business segment).

### Data Relationships (in PowerBI)

```
Sites (SiteID) ──1:M──> COGP_Monthly (SiteID)
Sites (SiteID) ──1:M──> COGP_Plan (SiteID)
ProfitCenters (ProfitCenter) ──1:M──> COGP_Plan (ProfitCenter)
```

## Dashboard Layout

Single-page dashboard with four zones:

```
┌──────────────────────────────────────────────────────────┐
│  FILTERS BAR                                             │
│  [Facility Type ▼]  [Year ▼]  [Month ▼]  [Region ▼]     │
│                     [Business Segment ▼]                 │
├──────────────────────────────────────────────────────────┤
│  SUMMARY CARDS                                           │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐               │
│  │ Mfg │ │ DC  │ │ WH  │ │ SC  │ │ CM  │               │
│  │  12 │ │  8  │ │  10 │ │  6  │ │  5  │               │
│  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘               │
├────────────────────────────┬─────────────────────────────┤
│                            │                             │
│                            │  COGP BAR CHART             │
│       MAP VISUAL           │  (COGP by site,             │
│   (color-coded markers)    │   horizontal bars)          │
│                            │                             │
│                            ├─────────────────────────────┤
│                            │                             │
│                            │  COGP DETAIL TABLE          │
│                            │  (appears on site click,    │
│                            │   segment > profit center   │
│                            │   with subtotals)           │
│                            │                             │
└────────────────────────────┴─────────────────────────────┘
```

### Filters Bar

- **Facility Type** — multi-select slicer. Controls which markers appear on the map. All visuals respond to this filter.
- **Year** — single-select slicer. Always visible. Controls which year of COGP data is displayed.
- **Month** — single-select slicer. Defaults to "All" (full year). When a month is selected, tooltip shows that month's COGP and YTD through that month.
- **Region** — single-select or multi-select slicer. Filters all visuals by geographic region.
- **Business Segment** — single-select or multi-select slicer. Filters the bar chart and detail table.

### Summary Cards

Five card visuals, one per facility type, each showing a count of sites.

- React to the **Region** filter.
- Do NOT react to the **Facility Type** filter — always show the full network picture regardless of which types are displayed on the map.

### Map Visual

- **Visual type:** Native Bing Maps (built-in PowerBI map visual).
- **Geocoding:** City + Country fields from the `Sites` table. No latitude/longitude required.
- **Markers:** Bubble markers, color-coded by facility type with a legend.
- **Facility type filter:** Multi-select slicer controls which types appear on the map.
- Responds to all filters (year, month, region, business segment).

### COGP Bar Chart

- **Visual type:** Horizontal bar chart.
- **Data:** COGP by site — shows only manufacturing sites and contract manufacturers.
- **Measure:** YTD actual COGP (or full-year if no month selected).
- Responds to year, month, region, and business segment filters.

### COGP Detail Table

- **Visual type:** Matrix visual with row grouping.
- **Default state:** Shows placeholder text — "Click a manufacturing site or contract manufacturer to see COGP breakdown."
- **On click of a manufacturing site or contract manufacturer:** Populates with annual plan COGP data for that site.
- **On click of a non-COGP facility type:** Shows "No COGP data for this facility type."

#### Detail Table Structure

```
┌──────────┬──────────────────────────┬────────────────────┐
│  Profit  │  Description             │  COGP Plan         │
│  Center  │                          │                    │
├──────────┼──────────────────────────┼────────────────────┤
│  ▼ Industrial                       │  $8,200,000        │
│  IC-4010 │  Hydraulic Components    │  $3,500,000        │
│  IC-4020 │  Power Systems           │  $2,700,000        │
│  IC-4030 │  Control Units           │  $2,000,000        │
├──────────┼──────────────────────────┼────────────────────┤
│  ▼ Commercial                       │  $4,100,000        │
│  CM-5010 │  HVAC Systems            │  $2,600,000        │
│  CM-5020 │  Building Controls       │  $1,500,000        │
├──────────┼──────────────────────────┼────────────────────┤
│  TOTAL                              │  $12,300,000       │
└──────────┴──────────────────────────┴────────────────────┘
```

- Rows grouped by **Business Segment** (expandable/collapsible).
- Each row shows **Profit Center** code, **Description**, and **COGP Plan** amount.
- **Subtotals** per business segment.
- **Grand total** row at the bottom.
- Table header displays the selected site name and year.
- Responds to the year filter.

## Tooltip Design

### All Facility Types (on hover)

- **Site name** (bold)
- **Facility type**
- **City, Country**

### Manufacturing Sites & Contract Manufacturers (additional fields on hover)

- **Selected month COGP actual** (if a month is selected)
- **YTD COGP actual**
- **Full year COGP plan**

## DAX Measures Required

The following calculated measures will be needed in PowerBI:

- **YTD COGP Actual** — sum of `COGP_Actual` from `COGP_Monthly` where month <= selected month, for the selected year. If no month is selected, sum all months for the year.
- **Selected Month COGP** — `COGP_Actual` for the specific selected month and year.
- **Total COGP Plan** — sum of `COGP_Plan` from `COGP_Plan` for the selected year and site.
- **Site Count by Type** — count of distinct `SiteID` grouped by `FacilityType`.

## Map Visual Approach

Using the native PowerBI Bing Maps visual (Approach A). Chosen for:

- Zero setup — built into PowerBI
- Native tooltip and geocoding support
- Color-coding by category is a standard feature
- Easy to maintain with no external dependencies

If richer cartography is needed in the future, can migrate to ArcGIS Maps for PowerBI.

## Data Source

- Single Excel workbook (`.xlsx`) maintained manually on the user's work computer.
- PowerBI connects to this file and refreshes on open or manual refresh.
- The workbook contains all four sheets described above.
