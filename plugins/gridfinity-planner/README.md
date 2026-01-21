# Gridfinity Planner

Plan and design gridfinity baseplates for 3D printing with optimal grid calculations and print slicing.

## Install

*Agents require the Claude marketplace to install.*

```bash
/plugin marketplace add dgalarza/claude-code-workflows
/plugin install gridfinity-planner@dgalarza-workflows
```

## What It Does

Helps you create gridfinity baseplates by:
- Calculating optimal grid sizes from measurements (metric or imperial)
- Slicing large grids into printable chunks based on printer bed size
- Calculating padding for non-exact fits
- Generating parameters for [gridfinity.perplexinglabs.com](https://gridfinity.perplexinglabs.com)

## Example Usage

```
User: I have a drawer that's 350mm x 250mm and my printer bed is 220mm x 220mm

Claude:
GRIDFINITY BASEPLATE PLAN
========================
Target Space: 350mm × 250mm
Grid Size: 42mm
Total Grid: 8 × 5 units
Actual Dimensions: 336mm × 210mm
Padding: 7mm left/right, 20mm top/bottom

PRINT SEGMENTS:
Segment 1 (Left): 5 × 5 units, padding on left edge
Segment 2 (Right): 3 × 5 units, padding on right edge

gridfinity.perplexinglabs.com settings:
  Segment 1: Base 210mm × 210mm, force padding left
  Segment 2: Base 126mm × 210mm, force padding right
```

## Features

### Unit Conversion
Accepts metric (mm, cm, m) or imperial (inches, feet) measurements.

### Grid Calculation
- Uses standard 42mm grid size (configurable)
- Rounds down to whole units
- Calculates exact padding needed

### Print Slicing
When total grid exceeds printer bed:
- Calculates optimal segment sizes
- Plans padding distribution (edges only)
- Provides assembly guidance

### Output
- Grid summary (X × Y units)
- Physical dimensions including padding
- Per-segment parameters for gridfinity.perplexinglabs.com

## Tips

- If padding exceeds 10mm on any side, consider adding another grid unit
- Account for 0.2-0.4mm printer tolerances for tight fits
- For multi-part prints, segments connect at grid boundaries

## When to Use

- Designing gridfinity storage for drawers
- Planning toolbox organization
- Custom shelf storage systems
- Any space you want to gridfinity-ize
