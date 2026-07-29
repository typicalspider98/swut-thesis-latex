# Word-to-LaTeX quality checklist

Read this file before the final visual pass.

## 1. Content fidelity

- [ ] Title, subtitle, author, student ID, college, major, dates, and every
      supervisor match the Word source or confirmed user corrections.
- [ ] Chinese and English abstracts are complete.
- [ ] Keyword counts, separators, spelling, and order are preserved.
- [ ] Chapter, section, and subsection titles are complete and ordered.
- [ ] No prose paragraph disappeared, duplicated, or moved to the wrong section.
- [ ] All intentional lists retain every item and original order.
- [ ] Tables preserve headers, rows, values, units, notes, and merged-cell meaning.
- [ ] Figures use the best available original media and have correct captions.
- [ ] Equations preserve symbols, subscripts, superscripts, and numbering.
- [ ] Citations point to the intended bibliography entries.
- [ ] References are complete and not duplicated.
- [ ] Acknowledgements and appendices are complete.
- [ ] Text stored in Word text boxes, shapes, headers, or footers was reviewed.

## 2. Structural correctness

- [ ] Word formatting did not determine LaTeX structure by itself.
- [ ] Manual heading numbers were removed before `\chapter`, `\section`, and
      `\subsection`.
- [ ] No unsupported fourth-level heading remains.
- [ ] “（1）” is a list label, not a heading.
- [ ] Figures, tables, equations, and references use automatic numbering.
- [ ] Captions precede/follow content according to the target template.
- [ ] Cross-references use labels rather than hard-coded numbers.
- [ ] Code and colored text panels remain selectable text when recoverable.
- [ ] Migration notes are absent from the thesis body.

## 3. Obvious content-quality flags

Report these separately unless content editing is authorized:

- repeated words, malformed punctuation, broken spaces, or obvious OCR errors;
- contradictory names, dates, model versions, statistics, or terminology;
- informal or conversational passages inconsistent with academic prose;
- claims with missing citations;
- acknowledgements containing placeholder names or incomplete sentences;
- captions that do not describe their figure/table;
- appendix content repeated without a clear reason.

## 4. Compilation

- [ ] The documented engine and build command complete successfully.
- [ ] Bibliography generation completes successfully.
- [ ] A final no-op rebuild reports all targets up to date.
- [ ] No undefined references or citations remain.
- [ ] No `Missing character` warning remains.
- [ ] No `Overfull \hbox` or `Overfull \vbox` remains unexplained.
- [ ] Font warnings do not indicate an unintended fallback.
- [ ] Page count and numbered front/main/back matter are plausible.

## 5. PDF visual QA

### Cover and front matter

- [ ] Cover title wraps intentionally and is not clipped.
- [ ] One or two supervisor names have correct spacing and underline placement.
- [ ] Declaration dates and signature areas are present.
- [ ] Chinese/English abstract titles and keyword labels have template sizes.
- [ ] Headers and page numbers begin on the correct pages.

### Contents and lists

- [ ] Contents entries match actual headings.
- [ ] No unsupported heading level appears.
- [ ] Dotted leaders are continuous and visually close to page numbers.
- [ ] One-, two-, and three-digit page numbers align at the right edge.
- [ ] Figure/table list entries have no accidental blank lines.

### Main text

- [ ] Chapter, section, and subsection spacing is consistent.
- [ ] Paragraphs have no accidental blank strips or manual line breaks.
- [ ] List label spacing and continuation indentation match the template.
- [ ] Headings are not stranded at the bottom of a page.
- [ ] Tables fit the text width and use the template's rule style.
- [ ] Long tables repeat the intended heading and continuation caption.
- [ ] Figures are legible and not stretched.
- [ ] Equations and equation numbers do not collide.
- [ ] Code remains legible, selectable, and inside the text area.

### Back matter

- [ ] Bibliography numbering appears exactly once.
- [ ] Bibliography entries do not overlap or leave unexplained blank pages.
- [ ] Appendix titles, contents entries, and page headers are correct.
- [ ] Repeated appendix material is intentional.

## 6. Migration report

Record:

1. Source DOCX and target template.
2. Output source directory and PDF path.
3. Counts of chapters, tables, figures, equations, references, and appendices.
4. Structural transformations performed.
5. Obvious formatting/content issues corrected.
6. Unresolved uncertainties requiring human confirmation.
7. Compiler, page count, log status, and pages visually checked.
