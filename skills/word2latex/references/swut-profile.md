# SWUT thesis template profile

Use this profile only when the target contains `swutthesis.cls`.

## Build and project handling

- Create a new project directory for each thesis. Do not edit the reusable
  template while migrating a student manuscript.
- Compile with `latexmk -xelatex main.tex`; bibliography uses Biber.
- Keep `swutthesis.cls`, `latexmkrc`, `fonts/`, and the template's required
  resources in the new project.

## Metadata

Fill the commands demonstrated in the template `main.tex`, including:

```tex
\thesistitle{...}
\coverthesistitle{...}
\thesissubtitle{...} % only when present
\studentname{...}
\studentid{...}
\college{...}
\major{...}
\supervisor{...}
\coverdate{...}
\commitmentdate{...}{...}{...}
\authorizationdate{...}{...}{...}
```

For two supervisors, pass both names separated by an English comma:

```tex
\supervisor{秦朋,司熙昊}
```

Do not omit the second name merely because Word stores it on another line or in
a separate text box.

## Structure

- Use only `\chapter`, `\section`, and `\subsection`.
- Strip manual numbers from heading text.
- Do not use `\subsubsection` or `\paragraph` as a fourth-level heading.
- Convert “（1）” parallel items to first-level `enumerate`.
- Let the class control list labels, spacing, and continuation indentation.
- Use `\swuttableofcontents` and `\listoffiguresandtables`; never type entries
  manually.

## Tables

For ordinary tables, follow the template example:

```tex
\begin{table}[htbp]
  \centering
  \caption{表题}
  \label{tab:example}
  \begin{swuttable}
    \begin{swuttabular}{ccc}
      \toprule
      列一 & 列二 & 列三 \\
      \midrule
      ... \\
      \bottomrule
    \end{swuttabular}
  \end{swuttable}
\end{table}
```

Use `swutlongtable` and the demonstrated repeated-head/continued-caption pattern
for multipage tables. Do not replace these wrappers with an unstyled raw
`tabular`.

## Figures, equations, and code

- Follow the figure example in the template; keep caption and label placement
  consistent.
- Use automatic equation numbering and labels.
- Convert recoverable Word code/text panels to `lstlisting`.
- Use images only for genuinely graphical content.

## Bibliography and appendices

- Add references to `references.bib`.
- Cite with the template's configured citation commands.
- Remove manual `[1]`, `[2]`, and duplicated reference numbers.
- Use `\appendix` followed by `\chapter{...}`.
- Do not insert explanatory sentences about how Word stored appendix content.

## High-risk visual checks

Inspect these even when compilation succeeds:

- physical sizes of abstract titles and keyword labels;
- cover title wrapping and both supervisor lines;
- contents/list dotted leaders, blank rows, and right-aligned page numbers;
- list label gap and wrapped-line indentation;
- template-native table rules and captions;
- bibliography numbering exactly once;
- appendix code blocks and page breaks.
