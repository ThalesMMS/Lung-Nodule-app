# Logic Tables - Fleischner 2017 & Lung-RADS v2022

Reference document for calculator implementation logic.

---

## Fleischner Society 2017 Guidelines

### Solitary Solid Nodules

| Size (mm) | Low Risk | High Risk |
|-----------|----------|-----------|
| < 6 | No routine follow-up | Optional CT at 12mo |
| 6-8 | CT at 6-12mo, then consider CT at 18-24mo | CT at 6-12mo, then CT at 18-24mo |
| > 8 | Consider CT at 3mo, PET/CT, or tissue sampling | Consider CT at 3mo, PET/CT, or tissue sampling |

### Multiple Solid Nodules

| Size (mm) | Low Risk | High Risk |
|-----------|----------|-----------|
| < 6 | No routine follow-up | Optional CT at 12mo |
| ≥ 6 (most suspicious) | CT at 3-6mo, then consider CT at 18-24mo | CT at 3-6mo, then CT at 18-24mo |

**Note**: For multiple nodules, base management on the most suspicious nodule; if similar, use the largest size.

### Solitary Pure Ground-Glass Nodules (GGN/GGO)

| Size (mm) | Recommendation |
|-----------|----------------|
| < 6 | No routine follow-up |
| ≥ 6 | CT at 6-12mo to confirm persistence, then CT every 2 years until 5 years |

### Solitary Part-Solid Nodules

| Size (mm) | Recommendation |
|-----------|----------------|
| < 6 (total) | No routine follow-up |
| ≥ 6 (total), solid < 6 | CT at 3-6mo to confirm persistence. If unchanged and solid component < 6mm, annual CT for 5 years |
| ≥ 6 (total), solid ≥ 6 | CT at 3-6mo to confirm persistence. If solid component ≥ 6mm, consider PET/CT or tissue sampling |

### Multiple Subsolid Nodules

| Scenario | Recommendation |
|----------|----------------|
| < 6mm pure GGN | CT at 3-6mo. If stable, consider CT at 2 and 4 years |
| ≥ 6mm pure GGN OR any part-solid | CT at 3-6mo. Subsequent management based on most suspicious nodule |

### Risk Factors (High Risk)

- History of smoking (current or former)
- Asbestos/radon/uranium exposure
- Family history of lung cancer (first-degree relative)
- Personal history of lung cancer
- COPD or pulmonary fibrosis

### Key Notes

1. Size = mean of long-axis and short-axis diameters on same axial image
2. Nodules < 3mm should not be measured (use "micronodule" descriptor)
3. For nodules ≥ 10mm, report both long and short axis
4. Round to nearest whole millimeter
5. Guidelines apply to incidentally detected nodules in adults ≥ 35 years
6. Does NOT apply to: lung cancer screening, immunocompromised patients, known primary cancer

---

## Lung-RADS v2022 Classification

### Categories Overview

| Category | Risk Level | Probability of Malignancy | Management |
|----------|------------|---------------------------|------------|
| 0 | Incomplete | N/A | Prior CT required or recall |
| 1 | Negative | < 1% | Continue annual LDCT |
| 2 | Benign appearance/behavior | < 1% | Continue annual LDCT |
| 3 | Probably Benign | 1-2% | 6-month LDCT |
| 4A | Suspicious | 5-15% | 3-month LDCT; PET/CT may be used |
| 4B | Very Suspicious | > 15% | Chest CT ± contrast, PET/CT, and/or tissue sampling |
| 4X | Highly Suspicious (4A/4B + additional features) | > 15% | As per 4A/4B + additional workup |
| S | Other clinically significant findings | N/A | As clinically indicated |

### Category 1 (Negative)

- No lung nodules
- Nodule with complete/central/popcorn/concentric ring calcification (benign)
- Nodule containing fat (hamartoma)

### Category 2 (Benign)

- Perifissural nodule < 10mm (baseline) or unchanged (follow-up)

**Solid Nodules:**
| Scenario | Baseline | New |
|----------|----------|-----|
| < 6mm | Cat 2 | Cat 2 |
| Stable ≥ 3 months | Cat 2 | N/A |

**Part-Solid Nodules:**
| Scenario | Baseline/Unchanged |
|----------|-------------------|
| Total < 6mm | Cat 2 |
| Solid component resolved | Cat 2 |

**Non-Solid (GGO) Nodules:**
| Scenario | Baseline |
|----------|----------|
| < 30mm | Cat 2 |
| ≥ 30mm, unchanged or slow-growing | Cat 2 |

### Category 3 (Probably Benign)

**Solid Nodules:**
| Scenario | Size | Category |
|----------|------|----------|
| Baseline | 6-7.9mm | Cat 3 |
| New | 4-5.9mm | Cat 3 |

**Part-Solid Nodules:**
| Scenario | Category |
|----------|----------|
| Total ≥ 6mm, solid < 6mm (baseline or new) | Cat 3 |

**Non-Solid (GGO) Nodules:**
| Scenario | Category |
|----------|----------|
| ≥ 30mm on baseline OR new | Cat 3 |

### Category 4A (Suspicious)

**Solid Nodules:**
| Scenario | Size | Category |
|----------|------|----------|
| Baseline | 8-14.9mm | Cat 4A |
| New | 6-7.9mm | Cat 4A |
| Growing | < 8mm | Cat 4A |

**Part-Solid Nodules:**
| Scenario | Category |
|----------|----------|
| Solid component 6-7.9mm (baseline or growing) | Cat 4A |
| New part-solid, solid ≥ 4mm | Cat 4A |

### Category 4B (Very Suspicious)

**Solid Nodules:**
| Scenario | Size | Category |
|----------|------|----------|
| Baseline | ≥ 15mm | Cat 4B |
| New | ≥ 8mm | Cat 4B |
| Growing | ≥ 8mm | Cat 4B |

**Part-Solid Nodules:**
| Scenario | Category |
|----------|----------|
| Solid component ≥ 8mm | Cat 4B |

### Category 4X

Applied when category 4A or 4B nodules have additional features suggesting higher suspicion:
- Spiculation
- Lymphadenopathy
- Chest wall invasion
- Cystic/cavitary features
- Upper lobe location with emphysema

### Growth Definition

- **Significant growth**: Increase ≥ 1.5mm in mean diameter from prior
- **Volume doubling time (VDT)**: < 400 days considered suspicious

### Special Nodule Types

**Perifissural Nodules (PFN):**
- Triangular/lentiform, attached to fissure
- < 10mm at baseline or unchanged: Category 2
- ≥ 10mm or atypical: Manage as solid nodule

**Juxtapleural Nodules:**
- Use same thresholds as solid nodules
- May use volume for more accurate assessment

**Endobronchial/Airway Nodules:**
- Segmental or more proximal airway nodule: Category 4A
- If persistent at 3-month follow-up: Category 4B

**Atypical Pulmonary Cysts:**
- With associated wall thickening/nodularity
- ≥ 4mm wall/nodule: Category 4B

### Reclassification Rules

1. **Category 3 → 2**: Stable at 6-month follow-up
2. **Category 4A → 3**: Stable at 3-month follow-up (then 6-month LDCT)
3. **Category 4B → 2**: If findings suggest benign etiology (resolved/calcified)
4. Inflammatory findings: Short-term follow-up may downgrade if resolved

### S Modifier

Added to any category when OTHER clinically significant findings present:
- Coronary artery calcification
- Aortic aneurysm
- Pulmonary fibrosis
- Other potentially significant abnormality

---

## Implementation Notes

### Input Fields Required

**Fleischner:**
- Nodule type: Solid, Pure GGO, Part-Solid
- Size (mm): Total diameter for all; solid component for part-solid
- Patient risk: Low/High
- Multiple nodules: Yes/No

**Lung-RADS:**
- CT Status: Baseline, Follow-up, Awaiting comparison, Incomplete
- Nodule type: Solid, Part-Solid, Non-Solid (GGO), Juxtapleural, Airway, Atypical Cyst
- Size (mm): Total diameter; solid component for part-solid
- Benign calcification pattern: Yes/No
- Macroscopic fat: Yes/No
- New nodule: Yes/No (for follow-up)
- Growing: Yes/No (≥1.5mm increase)
- Perifissural: Yes/No (for solid)
- Inflammatory findings: Yes/No
- Additional suspicious features (4X): Yes/No

### Size Thresholds Summary

**Solid:**
- Fleischner: 6, 8 mm
- Lung-RADS: 4, 6, 8, 15 mm

**Part-Solid (total):**
- Fleischner: 6 mm
- Lung-RADS: 6 mm

**Part-Solid (solid component):**
- Fleischner: 6 mm
- Lung-RADS: 4, 6, 8 mm

**GGO:**
- Fleischner: 6 mm
- Lung-RADS: 30 mm

---

## References

1. MacMahon H, et al. Guidelines for Management of Incidental Pulmonary Nodules Detected on CT Images: From the Fleischner Society 2017. Radiology. 2017;284(1):228-243.
2. American College of Radiology. Lung-RADS® v2022. https://www.acr.org/Clinical-Resources/Reporting-and-Data-Systems/Lung-Rads
