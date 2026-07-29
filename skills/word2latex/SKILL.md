---
name: word2latex
description: Convert academic Word manuscripts (.docx) into a new LaTeX project based on an existing template, preserving the manuscript's correct content while replacing incorrect Word formatting with template-native structure. Use for Word-to-LaTeX thesis migration, template adaptation, thesis reproduction, DOCX content extraction, bibliography/table/figure/appendix transfer, XeLaTeX compilation, and checks for obvious migration or formatting errors in the resulting PDF.
---

# Word to LaTeX

Migrate content from Word into an isolated copy of the target LaTeX template.
Treat the Word document as the content source and the LaTeX template as the
format source.

## Required inputs

Resolve these before editing:

1. Source `.docx`.
2. Target LaTeX template directory.
3. A new output directory. Never modify the template source unless the user
   explicitly asks to improve the template itself.
4. The expected compiler and build command.

If information is missing, inspect nearby files and template examples first.
Ask only when a choice would materially change the result.

## Non-negotiable rules

- Preserve substantive content; do not silently invent, summarize, or rewrite.
- Correct obvious extraction artifacts and formatting errors, but report
  uncertain content issues instead of guessing.
- Do not copy Word formatting into LaTeX. Re-express structure using the
  template's commands and environments.
- Do not add migration commentary such as “the original Word used a text box”
  to the thesis body.
- Do not turn colored text boxes or code blocks into screenshots when their
  text can be recovered.
- Do not use a heading level forbidden by the template.
- Do not hand-number headings, figures, tables, equations, or references.
- Compile and inspect the PDF; source-only completion is insufficient.

## Workflow

### 1. Inspect the template before the manuscript

Read the class file, example `main.tex`, example chapters, bibliography,
table/figure/code examples, build configuration, and bundled fonts. Record:

- metadata commands and front-matter order;
- allowed heading levels and numbering;
- paragraph/list conventions;
- native table, long-table, figure, equation, and code environments;
- bibliography backend and citation commands;
- appendix conventions;
- compiler, bibliography tool, and expected number of passes.

When the template contains `swutthesis.cls`, read
[references/swut-profile.md](references/swut-profile.md).

### 2. Inventory the Word package

Run:

```bash
python3 scripts/inspect_docx.py manuscript.docx \
  --output docx-manifest.md
```

Also render or open the Word document when tooling permits. OOXML text
extraction alone can miss the visual role of floating text boxes, grouped
objects, equations, and colored code panels.

Use the manifest to count and locate:

- cover metadata and supervisors;
- Chinese and English abstracts and keywords;
- headings and manual numbering;
- normal paragraphs and intentional lists;
- tables, figures, captions, equations, footnotes, and hyperlinks;
- references and citations;
- appendices, text boxes, code, and embedded media;
- repeated or empty paragraphs.

### 3. Build a migration map

Create a short mapping before writing:

| Word source | LaTeX target | Treatment |
|---|---|---|
| title/author fields | template metadata commands | copy values |
| Heading 1–3 | template heading commands | strip manual numbers |
| “（1）” parallel items | `enumerate` | never create level-4 headings |
| Word table | template-native table environment | preserve data |
| text box containing code | code/listing environment | preserve text |
| bibliography paragraph | `.bib` entry | remove manual `[n]` |

Flag any Word block whose role is unclear. Do not choose based only on its
visual font size because the Word formatting may be wrong.

### 4. Create the isolated project

Copy the template to a new directory, excluding generated files such as
`.aux`, `.bcf`, `.bbl`, `.blg`, `.fls`, `.fdb_latexmk`, `.log`, `.out`,
`.run.xml`, `.synctex.gz`, `.toc`, `.lof`, `.lot`, `.xdv`, and old PDFs.
Keep fonts, class files, build configuration, examples needed by the class,
and bibliography configuration.

Split chapters into separate files following the template's existing layout.
Keep the main file focused on metadata, front matter, includes, bibliography,
acknowledgements, and appendices.

### 5. Migrate in structural order

1. Fill all cover and declaration metadata, including every supervisor.
2. Transfer abstracts and keywords without inheriting Word title formatting.
3. Transfer chapters and map only approved heading levels.
4. Convert parallel parenthesized numbers into semantic lists.
5. Rebuild tables using the template's demonstrated environments.
6. Extract media into a stable asset directory and add semantic captions and
   labels. Use the original image data when available.
7. Convert equations to LaTeX and verify symbols visually.
8. Convert references to `.bib`; deduplicate keys and entries.
9. Convert appendices by semantic type. Use listing/code environments for
   recoverable text, not raster images.

Escape LaTeX special characters only where required. Preserve code verbatim
inside the template's listing environment.

### 6. Remove conversion artifacts

Search the entire project for:

- duplicated paragraphs, references, captions, or appendix introductions;
- empty paragraphs and manual page-break remnants;
- heading numbers embedded in title text;
- parenthesized list numbers implemented as headings;
- raw Word notes or migration explanations;
- inconsistent spaces around Latin text, punctuation, units, and citations;
- tables rebuilt with generic syntax when the template provides wrappers;
- figures or tables missing captions, labels, or in-text references;
- bibliography numbers written both manually and automatically.

Do not “improve” the student's argument silently. Report obvious typos,
contradictions, casual wording, suspicious statistics, or missing citations
separately unless the user authorizes content editing.

### 7. Compile and run deterministic checks

Use the template's build command, normally:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex
python3 scripts/audit_latex_project.py /path/to/output-project
```

Resolve errors, undefined references/citations, missing glyphs, and overfull
boxes. Rebuild until the table of contents, lists, citations, and page numbers
are stable. Do not suppress a warning without understanding its effect.

### 8. Perform visual PDF QA

Read [references/quality-checklist.md](references/quality-checklist.md) before
the final pass. Render representative and high-risk pages:

- cover and declarations;
- both abstracts and keywords;
- every contents/list page;
- first page of each chapter;
- pages containing long lists, tables, figures, equations, or code;
- bibliography;
- every appendix page.

Inspect the whole PDF when page count is manageable. Compare content against
the Word inventory, not against Word's incorrect visual formatting.

### 9. Deliver

Provide:

- the independent LaTeX source directory;
- the compiled PDF;
- a concise migration report listing content preserved, corrections made,
  unresolved uncertainties, compile status, warnings, and pages visually
  checked.

Do not claim success from compilation alone.

## Bundled resources

- `scripts/inspect_docx.py`: produce a deterministic DOCX structure and media
  inventory using only Python's standard library.
- `scripts/audit_latex_project.py`: detect common LaTeX migration mistakes and
  important compile-log problems.
- `references/quality-checklist.md`: final content and format QA checklist.
- `references/swut-profile.md`: rules specific to the bundled SWUT thesis
  template.
