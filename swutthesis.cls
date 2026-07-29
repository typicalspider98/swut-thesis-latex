\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\ProvidesClass{swutthesis}[2026/07/29 v0.2.4 SWUT undergraduate thesis class]

% ============================================================================
% Internal implementation of the SWUT undergraduate thesis template.
% Students normally edit main.tex and chapters/*.tex, not this class file.
% Dimensions copied from Word are written in bp (PostScript points).
% ============================================================================

% ----------------------------------------------------------------------------
% 1. Engine, base class and dependencies
% ----------------------------------------------------------------------------
\RequirePackage{iftex}
\ifXeTeX\else
  \ClassError{swutthesis}
    {This class requires XeLaTeX}
    {Please compile with xelatex.}
\fi

\LoadClass[a4paper,UTF8,zihao=-4,twoside,openany,fontset=none]{ctexbook}

% Page geometry
\RequirePackage{geometry}
\geometry{
  a4paper,
  top=2.5cm,
  % Word records a 2 cm bottom margin, but its line layout leaves the final
  % body line above that boundary. Reserve a small visible safety strip so
  % text and shaded code blocks cannot approach the page number too closely.
  bottom=2.3cm,
  inner=2.0cm,
  outer=2.0cm,
  bindingoffset=0.5cm,
  headheight=15pt,
  headsep=0.35cm,
  % Keep the page-number baseline at Word's original 1.5 cm from the paper
  % edge after adding the 0.3 cm body safety strip above it.
  footskip=0.74cm
}

% Fonts and graphics
\RequirePackage{fontspec}
\RequirePackage{xeCJK}
\RequirePackage{graphicx}
\RequirePackage{tikz}

% Paragraphs, headings and navigation
\RequirePackage{setspace}
\RequirePackage{indentfirst}
\RequirePackage{fancyhdr}
\RequirePackage{tocloft}

% Figures, tables, mathematics and lists
\RequirePackage{caption}
\RequirePackage{booktabs}
\RequirePackage{array}
\RequirePackage{tabularx}
\RequirePackage{longtable}
\RequirePackage{amsmath}
\RequirePackage{amssymb}
\RequirePackage{mathtools}
\RequirePackage{enumitem}
\RequirePackage{perpage}
\RequirePackage{etoolbox}
\RequirePackage{placeins}

% Code, links and bibliography
\RequirePackage{xcolor}
\RequirePackage{listings}
\RequirePackage{hyperref}
\RequirePackage{bookmark}
\RequirePackage[
  backend=biber,
  style=gb7714-2015,
  sorting=none,
  giveninits=true,
  url=true,
  doi=true
]{biblatex}

% ----------------------------------------------------------------------------
% 2. Font selection and fallbacks
% ----------------------------------------------------------------------------
% Word point sizes must remain physical point sizes in the generated PDF.
% MatchLowercase silently shrinks Times New Roman and the selected CJK fonts,
% so a nominal 15 bp abstract heading is rendered smaller than the 15 pt Word
% reference. Keep every document font unscaled unless a family explicitly
% requests a different scale.
\defaultfontfeatures{Ligatures=TeX,Scale=1}

% Western fonts: prefer the fonts named by the Word specification, then use
% metrically compatible TeX Live fonts.  Cache the Times New Roman probe
% because the same decision is reused for the page-number family.
\newif\ifswut@hastimesnewroman
\newif\ifswut@westernfontfallback
\IfFontExistsTF{Times New Roman}
  {\swut@hastimesnewromantrue}
  {
    \swut@hastimesnewromanfalse
    \swut@westernfontfallbacktrue
  }
\ifswut@hastimesnewroman
  \setmainfont{Times New Roman}
\else
  \setmainfont{TeX Gyre Termes}
\fi
\IfFontExistsTF{Arial}
  {\setsansfont{Arial}}
  {
    \setsansfont{TeX Gyre Heros}
    \swut@westernfontfallbacktrue
  }
\IfFontExistsTF{Courier New}
  {\setmonofont{Courier New}}
  {\setmonofont{TeX Gyre Cursor}}
% Keep a dedicated Times New Roman family for the 10.5 pt page number.
\ifswut@hastimesnewroman
  \newfontfamily\swutpagefont[Scale=1]{Times New Roman}
\else
  \newfontfamily\swutpagefont[Scale=1]{TeX Gyre Termes}
\fi

% Load exactly one complete Chinese font set.  ctexbook is loaded with
% fontset=none above, so it does not initialize a platform default that would
% immediately be replaced here.  One probe selects the Windows set, a second
% selects the macOS set, and TeX Live's Fandol set is the portable fallback.
\newif\ifswut@windowscjk
\newif\ifswut@maccjk
\newif\ifswut@cjkfontfallback
\IfFontExistsTF{SimSun}
  {\swut@windowscjktrue}
  {
    \IfFontExistsTF{STSong}
      {\swut@maccjktrue}
      {}
  }

\ifswut@windowscjk
  \setCJKmainfont[AutoFakeBold=2.5]{SimSun}
  \setCJKsansfont[AutoFakeBold=2.5]{SimHei}
  \setCJKmonofont{FangSong}
  \newCJKfontfamily\swutheaderfont[Scale=1]{SimSun}
  \IfFileExists{fonts/FangSongGB2312.ttf}
    {\setCJKfamilyfont{zhfs}[Path={fonts/}]{FangSongGB2312.ttf}}
    {\setCJKfamilyfont{zhfs}{FangSong}}
  \IfFileExists{fonts/KaiTiGB2312.ttf}
    {\setCJKfamilyfont{zhkai}[Path={fonts/}]{KaiTiGB2312.ttf}}
    {\setCJKfamilyfont{zhkai}{KaiTi}}
\else
  \ifswut@maccjk
    \setCJKmainfont[AutoFakeBold=2.5]{STSong}
    \setCJKsansfont[AutoFakeBold=2.5]{STHeiti}
    \setCJKmonofont{STFangsong}
    \newCJKfontfamily\swutheaderfont[Scale=1]{STSong}
    \IfFileExists{fonts/FangSongGB2312.ttf}
      {\setCJKfamilyfont{zhfs}[Path={fonts/}]{FangSongGB2312.ttf}}
      {\setCJKfamilyfont{zhfs}{STFangsong}}
    \IfFileExists{fonts/KaiTiGB2312.ttf}
      {\setCJKfamilyfont{zhkai}[Path={fonts/}]{KaiTiGB2312.ttf}}
      {\setCJKfamilyfont{zhkai}{Kaiti SC}}
  \else
    \swut@cjkfontfallbacktrue
    \setCJKmainfont[AutoFakeBold=2.5]{FandolSong-Regular}
    \setCJKsansfont[AutoFakeBold=2.5]{FandolHei-Regular}
    \setCJKmonofont{FandolFang-Regular}
    \newCJKfontfamily\swutheaderfont[Scale=1]{FandolSong-Regular}
    \IfFileExists{fonts/FangSongGB2312.ttf}
      {\setCJKfamilyfont{zhfs}[Path={fonts/}]{FangSongGB2312.ttf}}
      {\setCJKfamilyfont{zhfs}{FandolFang-Regular}}
    \IfFileExists{fonts/KaiTiGB2312.ttf}
      {\setCJKfamilyfont{zhkai}[Path={fonts/}]{KaiTiGB2312.ttf}}
      {\setCJKfamilyfont{zhkai}{FandolKai-Regular}}
  \fi
\fi
\providecommand{\songti}{\CJKfamily{\CJKrmdefault}}
\providecommand{\heiti}{\CJKfamily{\CJKsfdefault}}
\providecommand{\fangsong}{\CJKfamily{zhfs}}
\providecommand{\kaishu}{\CJKfamily{zhkai}}
% The Founder title font is loaded directly from the private project without
% installation. If it is missing, compilation continues but the PDF carries a
% visible reminder so a fallback-font draft is not submitted accidentally.
\newif\ifswut@schoolfontfallback
\IfFileExists{fonts/FZXBS.ttf}
  {
    \swut@schoolfontfallbackfalse
    \newCJKfontfamily\swutschoolfont[Path={fonts/},Scale=1]{FZXBS.ttf}
  }
  {
    \swut@schoolfontfallbacktrue
    \newcommand{\swutschoolfont}{\songti}
    \ClassWarningNoLine{swutthesis}
      {FZXBS.ttf not found; the fixed cover heading uses a fallback font}
  }

% ----------------------------------------------------------------------------
% 3. PDF options and document-wide paragraph defaults
% ----------------------------------------------------------------------------
\hypersetup{
  unicode=true,
  hypertexnames=false,
  colorlinks=false,
  pdfborder={0 0 0},
  bookmarksnumbered=true,
  bookmarksopen=true
}

% Word's 1.5-line paragraphs are snapped to its 317-twip document grid.
% With the 12 bp body font this renders at about 23.4 bp baseline-to-baseline,
% rather than setspace's default onehalfspacing value of about 17.9 bp.
\setstretch{1.625}
\setlength{\parindent}{2em}
\setlength{\parskip}{0pt}
% Lists use the body baseline without an additional blank strip between items.
% Keep the normal top/bottom separation so a list remains distinct from prose.
\setlist[enumerate,itemize]{
  topsep=0pt,
  itemsep=0pt,
  parsep=0pt,
  partopsep=0pt
}
\setlist[enumerate,1]{
  label=（\arabic*）,
  labelindent=2em,
  leftmargin=2em,
  itemindent=*,
  labelsep=0.25em,
  align=left
}
% The school specification ends at the third heading level
% (chapter, section and subsection). Parenthesized numbers belong to lists.
\setcounter{secnumdepth}{2}
\setcounter{tocdepth}{2}
\emergencystretch=2em
\raggedbottom

% ----------------------------------------------------------------------------
% 4. Public metadata commands
% ----------------------------------------------------------------------------
% These commands form the stable user-facing API used in main.tex.
% \thesistitle is the canonical title for headers/bookmarks. The cover-only
% title may contain explicit line breaks; the optional subtitle is separate.
\newcommand{\swut@title}{}
\newcommand{\swut@covertitle}{}
\newcommand{\swut@subtitle}{}
\newcommand{\swut@author}{}
\newcommand{\swut@studentid}{}
\newcommand{\swut@college}{}
\newcommand{\swut@major}{}
\newcommand{\swut@date}{二〇二六年六月}
\newcommand{\swut@commitmentyear}{}
\newcommand{\swut@commitmentmonth}{}
\newcommand{\swut@commitmentday}{}
\newcommand{\swut@authorizationyear}{}
\newcommand{\swut@authorizationmonth}{}
\newcommand{\swut@authorizationday}{}

\newcommand{\thesistitle}[1]{%
  \gdef\swut@title{#1}%
  \gdef\swut@covertitle{#1}%
  \title{#1}}
\newcommand{\coverthesistitle}[1]{\gdef\swut@covertitle{#1}}
\newcommand{\thesissubtitle}[1]{\gdef\swut@subtitle{#1}}
\newcommand{\studentname}[1]{\gdef\swut@author{#1}\author{#1}}
\newcommand{\studentid}[1]{\gdef\swut@studentid{#1}}
\newcommand{\college}[1]{\gdef\swut@college{#1}}
\newcommand{\major}[1]{\gdef\swut@major{#1}}
\newcommand{\coverdate}[1]{\gdef\swut@date{#1}\date{#1}}
\newcommand{\commitmentdate}[3]{%
  \gdef\swut@commitmentyear{#1}%
  \gdef\swut@commitmentmonth{#2}%
  \gdef\swut@commitmentday{#3}}
\newcommand{\authorizationdate}[3]{%
  \gdef\swut@authorizationyear{#1}%
  \gdef\swut@authorizationmonth{#2}%
  \gdef\swut@authorizationday{#3}}

% \supervisor accepts one name or a comma-separated pair. Chinese semicolons
% and enumeration commas are normalized as separators as a convenience.
% Two-character names receive one ideographic character of internal spacing;
% names of any other length are left unchanged.
\newif\ifswut@twosupervisors
\ExplSyntaxOn
\clist_new:N \g_swut_supervisor_clist

\NewDocumentCommand{\supervisor}{m}
  {
    \tl_set:Nn \l_tmpa_tl {#1}
    \tl_replace_all:Nnn \l_tmpa_tl {；} {,}
    \tl_replace_all:Nnn \l_tmpa_tl {、} {,}
    \clist_gset:Nx \g_swut_supervisor_clist {\tl_use:N \l_tmpa_tl}
    \int_compare:nNnTF
      {\clist_count:N \g_swut_supervisor_clist} > {1}
      {\global\swut@twosupervisorstrue}
      {\global\swut@twosupervisorsfalse}
    \int_compare:nNnT
      {\clist_count:N \g_swut_supervisor_clist} > {2}
      {
        \ClassWarning{swutthesis}
          {More~than~two~supervisors~were~provided;
           ~the~cover~is~designed~for~at~most~two}
      }
  }

\cs_new_protected:Npn \swut_format_supervisor_name:n #1
  {
    \tl_set:Nn \l_tmpa_tl {#1}
    \tl_trim_spaces:N \l_tmpa_tl
    \regex_replace_all:nnN {\s+} {} \l_tmpa_tl
    \int_compare:nNnTF {\tl_count:N \l_tmpa_tl} = {2}
      {
        \tl_item:Nn \l_tmpa_tl {1}
        \hspace{1em}
        \tl_item:Nn \l_tmpa_tl {2}
      }
      {\tl_use:N \l_tmpa_tl}
  }

\NewDocumentCommand{\swutformatsupervisors}{}
  {
    \bool_set_true:N \l_tmpa_bool
    \clist_map_inline:Nn \g_swut_supervisor_clist
      {
        \bool_if:NTF \l_tmpa_bool
          {\bool_set_false:N \l_tmpa_bool}
          {\\[-2bp]}
        \swut_format_supervisor_name:n {##1}
      }
  }
\ExplSyntaxOff

% ----------------------------------------------------------------------------
% 5. Cover and declaration pages
% ----------------------------------------------------------------------------
% In Word, 2 pt character spacing is present at both the paragraph and run
% levels, so the fixed cover heading has an effective 4 pt gap between glyphs.
\newcommand{\swut@coverheading}{%
  毕\kern4bp 业\kern4bp 设\kern4bp 计\kern4bp
  （\kern4bp 论\kern4bp 文\kern4bp ）}

% #1 label, #2 value, #3 text vertical coordinate, #4 underline coordinate.
\newcommand{\swut@coverrow}[4]{%
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=108bp,yshift=-#3]current page.north west)
    {{\heiti\sffamily\fontsize{15bp}{18bp}\selectfont
      \makebox[78bp][l]{#1}}};
  \node[anchor=north,inner sep=0pt,text width=318.5bp,align=center]
    at ([xshift=347.25bp,yshift=-#3]current page.north west)
    {{\heiti\sffamily\fontsize{15bp}{18bp}\selectfont #2}};
  % Word renders these form lines as 1.44 pt filled rules.
  \draw[line width=1.44bp]
    ([xshift=188bp,yshift=-#4]current page.north west) --
    ([xshift=506.5bp,yshift=-#4]current page.north west);
}

\renewcommand{\maketitle}{%
  \begin{titlepage}
    \thispagestyle{empty}
    \begin{tikzpicture}[remember picture,overlay]
      % The group is exported unchanged from Word's two-picture Group 13.
      % Its rendered Word bounds are 397.95 pt × 83.45 pt at
      % x=105.75 pt, y=94.92 pt.
      \node[anchor=north west,inner sep=0pt]
        at ([xshift=105.75bp,yshift=-94.72bp]current page.north west)
        {\includegraphics[width=397.95bp,height=83.45bp]
          {assets/swut-wordmark.png}};

      % Word contains three leading spaces before this heading.  The 30 pt
      % horizontal shift reproduces its rendered position without preserving
      % those invisible placeholder characters.
      \node[anchor=north,inner sep=0pt]
        at ([xshift=30bp,yshift=-211.00bp]current page.north)
        {{\swutschoolfont\fontsize{36bp}{43.2bp}\selectfont
          \swut@coverheading}};
      \ifswut@schoolfontfallback
        \node[anchor=north,inner sep=0pt,text=red!80!black]
          at ([yshift=-258bp]current page.north)
          {{\songti\rmfamily\fontsize{8.5bp}{10.5bp}\selectfont
            字体提示：当前未检测到方正小标宋简体，以上标题已使用宋体回退；
            请将合法取得的 \texttt{FZXBS.ttf} 放入 \texttt{fonts/}
            文件夹后重新编译。}};
      \fi

      \node[anchor=north west,inner sep=0pt]
        at ([xshift=76.50bp,yshift=-337.00bp]current page.north west)
        {{\heiti\sffamily\fontsize{22bp}{33bp}\selectfont
          题\hspace{20bp}目}};

      % The first one or two lines come from \coverthesistitle; the optional
      % third line comes from \thesissubtitle. Keeping them in one paragraph
      % box guarantees identical alignment, font and baseline spacing.
      \node[anchor=north,inner sep=0pt]
        at ([xshift=345bp,yshift=-294.50bp]current page.north west)
        {\parbox[t]{323bp}{%
          \centering
          \setstretch{1}%
          \setlength{\parindent}{0pt}%
          \setlength{\parskip}{0pt}%
          \heiti\fontsize{22bp}{33bp}\selectfont
          \swut@covertitle\par
          \ifx\swut@subtitle\@empty\else
            \swut@subtitle\par
          \fi
        }};

      % The five form rows share a strict 38.5 bp vertical grid.
      \swut@coverrow{学生姓名：}{\swut@author}{469.00bp}{498.00bp}
      \swut@coverrow{学\hspace{18bp}号：}{\swut@studentid}{507.50bp}{536.50bp}
      \swut@coverrow{学\hspace{18bp}院：}{\swut@college}{546.00bp}{575.00bp}
      \swut@coverrow{专\hspace{18bp}业：}{\swut@major}{584.50bp}{613.50bp}
      \ifswut@twosupervisors
        % Use a compact 16 bp baseline gap for two names while preserving the
        % same visual clearance between the second name and the underline.
        \swut@coverrow{指导教师：}{\swutformatsupervisors}{623.00bp}{660.00bp}
      \else
        \swut@coverrow{指导教师：}{\swutformatsupervisors}{623.00bp}{652.00bp}
      \fi

      \node[anchor=north,inner sep=0pt]
        at ([yshift=-742.50bp]current page.north)
        {{\heiti\sffamily\fontsize{15bp}{22.5bp}\selectfont\swut@date}};
      \ifswut@cjkfontfallback
        \node[anchor=north,inner sep=0pt,text=red!80!black]
          at ([yshift=-779bp]current page.north)
          {{\songti\rmfamily\fontsize{8.5bp}{10.5bp}\selectfont
            字体提示：未检测到学校版式使用的宋体、黑体等 Windows 中文字体，
            当前已使用系统或 Fandol 字体回退。}};
      \fi
      \ifswut@westernfontfallback
        \node[anchor=north,inner sep=0pt,text=red!80!black]
          at ([yshift=-792bp]current page.north)
          {{\songti\rmfamily\fontsize{8.5bp}{10.5bp}\selectfont
            字体提示：未检测到 Times New Roman 或 Arial，
            当前西文已使用 TeX Gyre 字体回退。}};
      \fi
    \end{tikzpicture}
    \null
  \end{titlepage}
}

\newcommand{\swutblankpage}{%
  \clearpage
  \thispagestyle{empty}
  \null
  \clearpage
}

% #1 signature row coordinate; #2 underline/date reference coordinate;
% #3 year; #4 month; #5 day. Empty date fields leave room for handwriting.
\newcommand{\swut@declarationsignature}[5]{%
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=317.5bp,yshift=-#1]current page.north west)
    {{\songti\rmfamily\fontsize{12bp}{18bp}\selectfont 作者签名：}};
  % 原 Word 模板提示：“（手签）（完稿请删除）”。
  % 该内容仅用于提醒作者在打印稿上手写签名，不输出到最终 PDF。
  \draw[line width=0.5bp]
    ([xshift=382.5bp,yshift=-#2]current page.north west) --
    ([xshift=539bp,yshift=-#2]current page.north west);
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=317.5bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\songti\rmfamily\fontsize{12bp}{18bp}\selectfont
      日\hspace{24bp}期：}};
  \node[anchor=north west,inner sep=0pt,text width=34.5bp,align=center]
    at ([xshift=388.5bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\rmfamily\fontsize{12bp}{18bp}\selectfont #3}};
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=424bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\songti\fontsize{12bp}{18bp}\selectfont 年}};
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=470bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\songti\fontsize{12bp}{18bp}\selectfont 月}};
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=516bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\songti\fontsize{12bp}{18bp}\selectfont 日}};
  \node[anchor=north west,inner sep=0pt,text width=31bp,align=center]
    at ([xshift=438bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\rmfamily\fontsize{12bp}{18bp}\selectfont #4}};
  \node[anchor=north west,inner sep=0pt,text width=31bp,align=center]
    at ([xshift=484bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\rmfamily\fontsize{12bp}{18bp}\selectfont #5}};
  \draw[line width=0.5bp]
    ([xshift=388.5bp,yshift=-\dimexpr#2+34bp\relax]current page.north west) --
    ([xshift=423bp,yshift=-\dimexpr#2+34bp\relax]current page.north west);
  \draw[line width=0.5bp]
    ([xshift=438bp,yshift=-\dimexpr#2+34bp\relax]current page.north west) --
    ([xshift=469bp,yshift=-\dimexpr#2+34bp\relax]current page.north west);
  \draw[line width=0.5bp]
    ([xshift=484bp,yshift=-\dimexpr#2+34bp\relax]current page.north west) --
    ([xshift=515bp,yshift=-\dimexpr#2+34bp\relax]current page.north west);
}

\newcommand{\makecopyrightstatements}{%
  \clearpage
  \thispagestyle{empty}
  \begin{tikzpicture}[remember picture,overlay]
    \node[anchor=north,inner sep=0pt]
      at ([yshift=-71bp]current page.north)
      {{\heiti\sffamily\fontsize{15bp}{18bp}\selectfont 诚信承诺书}};
    \node[anchor=north west,inner sep=0pt]
      at ([xshift=71bp,yshift=-118bp]current page.north west)
      {\parbox[t]{453.5bp}{%
        \songti\rmfamily\fontsize{12bp}{18bp}\selectfont
        \setlength{\parindent}{24bp}%
        本人郑重声明：所呈交的毕业设计（论文）是本人在指导教师的指导下
        独立开展工作所取得的成果。尽我所知，除了文中特别加以标注和致谢
        的内容外，本设计（论文）不包含任何其他个人或集体已经发表或撰写
        的成果作品。对本设计（论文）所涉及的研究工作作出贡献的其他个人
        和集体，均已在文中以明确方式标明。\par}};
    \swut@declarationsignature{241.5bp}{275bp}
      {\swut@commitmentyear}{\swut@commitmentmonth}{\swut@commitmentday}

    \node[anchor=north,inner sep=0pt]
      at ([yshift=-360.5bp]current page.north)
      {{\heiti\sffamily\fontsize{15bp}{18bp}\selectfont 版权使用授权声明}};
    \node[anchor=north west,inner sep=0pt]
      at ([xshift=71bp,yshift=-407.5bp]current page.north west)
      {\parbox[t]{453.5bp}{%
        \songti\rmfamily\fontsize{12bp}{18bp}\selectfont
        \setlength{\parindent}{24bp}%
        本人授权山东外国语职业技术大学，将本人毕业设计（论文）的全部或
        部分内容编入有关数据库进行检索；有权保留毕业设计（论文）相关材
        料并向国家主管部门或其指定机构送交论文的电子版和纸质版，允许论
        文被查阅和借阅；有权可以采用影印、缩印或扫描等复制手段保存、汇
        编学位论文。\par}};
    \swut@declarationsignature{531.5bp}{565bp}
      {\swut@authorizationyear}{\swut@authorizationmonth}
      {\swut@authorizationday}
  \end{tikzpicture}
  \null
  \clearpage
}

% ----------------------------------------------------------------------------
% 6. Page styles and matter transitions
% ----------------------------------------------------------------------------
% Front matter has page numbers only; main/back matter also show the thesis
% title in the running header.
\newcommand{\swut@pagenumber}{%
  \swutpagefont\fontsize{10.5bp}{10.5bp}\selectfont\thepage}
\newcommand{\swut@runningheader}{%
  \begingroup
  \setstretch{1}%
  \rmfamily\swutheaderfont\fontsize{10.5bp}{10.5bp}\selectfont
  \swut@title
  \endgroup}

\fancypagestyle{swut-front}{%
  \fancyhf{}
  % Extend into the binding offset so the footer is centered on the paper,
  % rather than alternately following the shifted odd/even text blocks.
  \fancyfootoffset[LO,RE]{0.5cm}
  \renewcommand{\headrulewidth}{0pt}
  \fancyfoot[C]{\swut@pagenumber}
}

\fancypagestyle{swut-main}{%
  \fancyhf{}
  \fancyfootoffset[LO,RE]{0.5cm}
  \fancyhead[C]{\swut@runningheader}
  \fancyfoot[C]{\swut@pagenumber}
  \renewcommand{\headrulewidth}{0.4pt}
}

% Keep chapter-opening pages consistent with the active matter style.
\newcommand{\swut@setfrontplain}{%
  \fancypagestyle{plain}{%
    \fancyhf{}
    \fancyfootoffset[LO,RE]{0.5cm}
    \renewcommand{\headrulewidth}{0pt}
    \fancyfoot[C]{\swut@pagenumber}
  }%
}

\newcommand{\swut@setmainplain}{%
  \fancypagestyle{plain}{%
    \fancyhf{}
    \fancyfootoffset[LO,RE]{0.5cm}
    \fancyhead[C]{\swut@runningheader}
    \fancyfoot[C]{\swut@pagenumber}
    \renewcommand{\headrulewidth}{0.4pt}
  }%
}

\renewcommand{\frontmatter}{%
  \clearpage
  \@mainmatterfalse
  \pagenumbering{roman}
  \pagestyle{swut-front}
  \swut@setfrontplain
}

\renewcommand{\mainmatter}{%
  \clearpage
  \@mainmattertrue
  \pagenumbering{arabic}
  \pagestyle{swut-main}
  \swut@setmainplain
}

\renewcommand{\backmatter}{%
  \clearpage
  \@mainmatterfalse
  \pagestyle{swut-main}
  \swut@setmainplain
}

\let\swut@originalappendix\appendix
\renewcommand{\appendix}{%
  \clearpage
  \@mainmattertrue
  \swut@originalappendix
  % The Word template keeps one 18 bp body line between the appendix title
  % and its first paragraph.
  \ctexset{chapter/afterskip=18bp}%
  \pagestyle{swut-main}
  \swut@setmainplain
}

% ----------------------------------------------------------------------------
% 7. Heading hierarchy
% ----------------------------------------------------------------------------
% A single measured gap is shared by all heading number/title combinations.
\newlength{\swut@headingnumbergap}
\setlength{\swut@headingnumbergap}{3bp}
\newcommand{\swut@headingnumberseparator}{%
  \hspace{\swut@headingnumbergap}}
\ctexset{
  chapter = {
    name = {第,章},
    number = \chinese{chapter},
    aftername = \swut@headingnumberseparator,
    format = \setstretch{1}\centering\heiti\sffamily
      \fontsize{15bp}{22.5bp}\selectfont,
    beforeskip = 12bp,
    % Match the measured 12.3 bp visible gap before a following section.
    afterskip = 13.3bp,
    fixskip = true,
    pagestyle = swut-main
  },
  section = {
    aftername = \swut@headingnumberseparator,
    format = \setstretch{1}\heiti\sffamily
      \fontsize{14bp}{21bp}\selectfont,
    % The measured upper gap was about 4 bp narrower than the lower gap.
    beforeskip = 4bp,
    % Fine adjustment from the rendered Word/PDF title-to-body comparison.
    aftertitle = \par\nobreak\vspace{0.95bp}\nobreak,
    afterskip = 0pt,
    afterindent = true
  },
  subsection = {
    aftername = \swut@headingnumberseparator,
    format = \setstretch{1}\heiti\sffamily
      \fontsize{12bp}{18bp}\selectfont,
    % Keep the title one normal body-line step away on both sides.
    beforeskip = 4bp,
    % Match the measured 10.1 bp visible gap before body text.
    aftertitle = \par\nobreak\vspace{-1.29bp}\nobreak,
    afterskip = 0pt,
    afterindent = true
  },
  paragraph = {
    format = \setstretch{1}\bfseries\songti
      \fontsize{12bp}{18bp}\selectfont,
    beforeskip = 0pt,
    afterskip = 0pt,
    afterindent = true,
    runin = false
  },
  contentsname = {目\quad 录},
  listfigurename = {图表清单},
  listtablename = {图表清单},
  figurename = {图},
  tablename = {表},
  appendixname = {附录}
}
% LaTeX suppresses a subsection's normal beforeskip when it immediately
% follows another heading. Restore the same body-line gap in that case only.
\pretocmd{\subsection}{%
  \if@nobreak\vspace{4bp}\fi
}{}{%
  \ClassWarning{swutthesis}{Unable to patch adjacent subsection spacing}%
}

% ----------------------------------------------------------------------------
% 8. Abstracts, keywords, contents and lists
% ----------------------------------------------------------------------------
\newenvironment{cnabstract}{%
  \frontmatter
  \thispagestyle{swut-front}
  \begingroup
  \setstretch{1}
  \vspace*{12bp}
  \noindent\makebox[\textwidth][c]{%
    \heiti\sffamily\fontsize{15bp}{22.5bp}\selectfont 摘\quad 要}\par
  \vspace{18bp}
  \songti\rmfamily\fontsize{12bp}{18bp}\selectfont
  \setlength{\parindent}{24bp}
  \setlength{\parskip}{0pt}
  \indent\ignorespaces
}{\par\endgroup}

% Warn about keyword counts without blocking compilation.
\ExplSyntaxOn
\NewDocumentCommand{\swutcheckcnkeywords}{m}
  {
    \seq_set_split:Nnn \l_tmpa_seq {；} {#1}
    \int_compare:nNnT {\seq_count:N \l_tmpa_seq} < {3}
      {
        \ClassWarning{swutthesis}
          {Chinese~keyword~count~is~\int_eval:n{\seq_count:N\l_tmpa_seq};
           expected~3--5}
      }
    \int_compare:nNnT {\seq_count:N \l_tmpa_seq} > {5}
      {
        \ClassWarning{swutthesis}
          {Chinese~keyword~count~is~\int_eval:n{\seq_count:N\l_tmpa_seq};
           expected~3--5}
      }
  }
\NewDocumentCommand{\swutcheckenkeywords}{m}
  {
    \seq_set_split:Nnn \l_tmpa_seq {;} {#1}
    \int_compare:nNnT {\seq_count:N \l_tmpa_seq} < {3}
      {
        \ClassWarning{swutthesis}
          {English~keyword~count~is~\int_eval:n{\seq_count:N\l_tmpa_seq};
           expected~3--5}
      }
    \int_compare:nNnT {\seq_count:N \l_tmpa_seq} > {5}
      {
        \ClassWarning{swutthesis}
          {English~keyword~count~is~\int_eval:n{\seq_count:N\l_tmpa_seq};
           expected~3--5}
      }
  }
\ExplSyntaxOff

\newcommand{\cnkeywords}[1]{%
  \swutcheckcnkeywords{#1}%
  \par\vspace{18bp}
  \noindent{\heiti\sffamily\fontsize{15bp}{22.5bp}\selectfont 关键词：}%
  {\songti\rmfamily\fontsize{12bp}{18bp}\selectfont #1}\par
}

\newenvironment{enabstract}{%
  \clearpage
  \thispagestyle{swut-front}
  \begingroup
  \setstretch{1}
  \vspace*{12bp}
  \noindent\makebox[\textwidth][c]{%
    \bfseries\rmfamily\fontsize{15bp}{22.5bp}\selectfont ABSTRACT}\par
  \vspace{18bp}
  \normalfont\rmfamily\fontsize{12bp}{18bp}\selectfont
  \setlength{\parindent}{24bp}
  \setlength{\parskip}{0pt}
  \indent\ignorespaces
}{\par\endgroup}

\newcommand{\enkeywords}[1]{%
  \swutcheckenkeywords{#1}%
  \par\vspace{18bp}
  \noindent{\normalfont\rmfamily\fontsize{15bp}{22.5bp}\selectfont Keywords: }%
  {\normalfont\rmfamily\fontsize{12bp}{18bp}\selectfont #1}\par
}

% Table of contents typography and number/title alignment.
\renewcommand{\cfttoctitlefont}{%
  \hfill\heiti\sffamily\fontsize{15bp}{22.5bp}\selectfont}
\renewcommand{\cftaftertoctitle}{\hfill}
\setlength{\cftbeforetoctitleskip}{12bp}
\setlength{\cftaftertoctitleskip}{18bp}
\renewcommand{\cftchapfont}{\songti\rmfamily\fontsize{12bp}{18bp}\selectfont}
\renewcommand{\cftchappagefont}{\rmfamily\fontsize{12bp}{18bp}\selectfont}
\renewcommand{\cftsecfont}{\songti\rmfamily\fontsize{12bp}{18bp}\selectfont}
\renewcommand{\cftsecpagefont}{\rmfamily\fontsize{12bp}{18bp}\selectfont}
\renewcommand{\cftsubsecfont}{\songti\rmfamily\fontsize{12bp}{18bp}\selectfont}
\renewcommand{\cftsubsecpagefont}{\rmfamily\fontsize{12bp}{18bp}\selectfont}
\newlength{\swut@tocnumbergap}
\setlength{\swut@tocnumbergap}{3bp}
% XeCJK supplies a 6 bp inter-script space after the normalized number box;
% one shared 3 bp pullback leaves the Word-style 3 bp ordinary space.
\newcommand{\swut@tocnumberseparator}{\hspace{-\swut@tocnumbergap}}
\newcommand{\swut@tocchapternormalization}{\hspace{-.3em}}
\renewcommand{\cftchapaftersnumb}{%
  \swut@tocchapternormalization\swut@tocnumberseparator}
\renewcommand{\cftsecaftersnumb}{\swut@tocnumberseparator}
\renewcommand{\cftsubsecaftersnumb}{\swut@tocnumberseparator}
\setlength{\cftbeforechapskip}{0pt}
\setlength{\cftbeforesecskip}{0pt}
\setlength{\cftbeforesubsecskip}{0pt}
\renewcommand{\cftdotsep}{1}
\renewcommand{\cftchapleader}{\cftdotfill{\cftdotsep}}
\renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}}
\renewcommand{\cftsubsecleader}{\cftdotfill{\cftdotsep}}
% Use one uninterrupted leader followed by a fixed gap and the page number.
% Drawing a second leader inside tocloft's fixed page-number box restarts the
% dot pattern and creates a visibly irregular gap before one-digit pages.
\newcommand{\swut@tocfillnum}[4]{%
  {#1}\nobreak\hspace{-.1em}\nobreak{#2#3}#4\par}
\renewcommand{\cftchapfillnum}[1]{%
  \swut@tocfillnum{\cftchapleader}{\cftchappagefont}{#1}%
    {\cftchapafterpnum}}
\renewcommand{\cftsecfillnum}[1]{%
  \swut@tocfillnum{\cftsecleader}{\cftsecpagefont}{#1}%
    {\cftsecafterpnum}}
\renewcommand{\cftsubsecfillnum}[1]{%
  \swut@tocfillnum{\cftsubsecleader}{\cftsubsecpagefont}{#1}%
    {\cftsubsecafterpnum}}
\renewcommand{\cftfigfillnum}[1]{%
  \swut@tocfillnum{\cftfigleader}{\cftfigpagefont}{#1}%
    {\cftfigafterpnum}}
\renewcommand{\cfttabfillnum}[1]{%
  \swut@tocfillnum{\cfttableader}{\cfttabpagefont}{#1}%
    {\cfttabafterpnum}}
\renewcommand{\cftfigpresnum}{图~}
\renewcommand{\cfttabpresnum}{表~}
% A single-digit chapter/item number such as "图 4.1" or "表 4.1" is followed
% by the same approximately 3 bp gap used by numbered headings.
\setlength{\cftfignumwidth}{2.78em}
\setlength{\cfttabnumwidth}{2.78em}

\newcommand{\swuttableofcontents}{%
  \clearpage
  % The contents form an independent front-matter sequence and therefore
  % restart at roman page i; subsequent figure/table lists continue from it.
  \setcounter{page}{1}
  \pagestyle{swut-front}
  \swut@setfrontplain
  {\setstretch{1}\songti\rmfamily\fontsize{12bp}{18bp}\selectfont
    % Normalize each number box to the actual number width.  CTeX's chapter
    % label carries an extra .3 em space, cancelled separately by
    % \swut@tocchapternormalization; the actual separator is shared.
    \settowidth{\cftchapnumwidth}{第一章}%
    \settowidth{\cftsecnumwidth}{1.1}%
    \settowidth{\cftsubsecnumwidth}{1.1.1}%
    \tableofcontents}
}

\newcommand{\listoffiguresandtables}{%
  \clearpage
  \chapter*{图表清单}
  \thispagestyle{swut-front}
  \@starttoc{lof}
  \vspace{\baselineskip}
  \@starttoc{lot}
}

% ----------------------------------------------------------------------------
% 9. Figures, tables, equations, footnotes and code
% ----------------------------------------------------------------------------
\DeclareCaptionFont{swutcaption}{\heiti\sffamily\zihao{5}}
\captionsetup{
  font=swutcaption,
  labelsep=space,
  justification=centering,
  singlelinecheck=true
}
\captionsetup[figure]{position=bottom,skip=6pt}
\captionsetup[table]{position=top,skip=0pt}
\captionsetup[longtable]{position=top,skip=0pt}
\setlength{\heavyrulewidth}{1.5pt}
\setlength{\lightrulewidth}{0.75pt}
\setlength{\cmidrulewidth}{0.75pt}
\renewcommand{\arraystretch}{1.2}
\newenvironment{swuttable}{\zihao{5}\singlespacing}{}
% Full-width three-line table. The stretchable inter-column space keeps the
% first and last rules aligned with the text block instead of the cell content.
\newenvironment{swuttabular}[1]{%
  \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}#1@{}}%
}{%
  \end{tabular*}%
}
\newenvironment{swutlongtable}[1]{%
  \begingroup
  \zihao{5}\singlespacing
  \begin{longtable}{#1}%
}{%
  \end{longtable}
  \endgroup
}
% Use in the repeated longtable head. The empty optional caption prevents a
% duplicate list-of-tables entry while retaining the original table number.
\newcommand{\swutcontinuedcaption}[1]{\caption[]{#1（续表）}\\}

% Keep the source order around large objects. If a figure or table does not
% fit, it moves forward as a whole and later paragraphs cannot overtake it.
\AfterEndEnvironment{figure}{\FloatBarrier}
\AfterEndEnvironment{table}{\FloatBarrier}

\numberwithin{equation}{chapter}
\MakePerPage{footnote}
\renewcommand{\thefootnote}{\arabic{footnote}}
\renewcommand{\footnotesize}{\zihao{-5}\singlespacing}

\lstset{
  basicstyle=\ttfamily\zihao{5}\singlespacing,
  backgroundcolor=\color{black!5},
  frame=none,
  numbers=none,
  breaklines=true,
  columns=fullflexible,
  keepspaces=true,
  showstringspaces=false,
  tabsize=4,
  xleftmargin=0.5em,
  xrightmargin=0.5em,
  % Pull the listing contents slightly into the float's empty top strip.
  % The float's lower edge moves by the same amount, so the already-correct
  % gap below the code block remains unchanged.
  aboveskip=-0.3\baselineskip,
  belowskip=0pt,
  % listings needs both a concrete float initialization and a persistent
  % default. The order is significant: initialize the float commands first,
  % then retain that placement for every subsequent listing.
  floatplacement=htbp,
  float=htbp,
  float=true
}
% A floating listing otherwise receives both the listing skip and LaTeX's
% comparatively large generic float separation.  Keep code visually attached
% to its explanation while retaining the whole-block page-breaking behaviour.
\AtBeginEnvironment{lstlisting}{%
  \setlength{\intextsep}{0pt}%
  \setlength{\textfloatsep}{0pt}%
}
\AfterEndEnvironment{lstlisting}{\FloatBarrier}

% ----------------------------------------------------------------------------
% 10. Bibliography and acknowledgements
% ----------------------------------------------------------------------------
\defbibheading{bibliography}[\bibname]{%
  \chapter*{#1}
  \thispagestyle{swut-main}
  \phantomsection
  \addcontentsline{toc}{chapter}{#1}
}
\AtBeginBibliography{\zihao{5}\singlespacing}
\setlength{\bibitemsep}{0pt}

\newenvironment{acknowledgements}{%
  \clearpage
  \begingroup
  \chapter*{致\hspace{2em}谢}
  \thispagestyle{swut-main}
  \phantomsection
  \addcontentsline{toc}{chapter}{致谢}
  % Complete the title's 22.5 bp line box before the 18 bp body text begins.
  % Without this compensation, a zero chapter after-skip places the first
  % body baseline only about 11 bp below the title baseline.
  \vspace{11.5bp}%
  \setstretch{1}%
  \songti\rmfamily\fontsize{12bp}{18bp}\selectfont
  \setlength{\parindent}{24bp}%
  \setlength{\parskip}{0pt}%
  \indent\ignorespaces
}{\par\endgroup}

% ----------------------------------------------------------------------------
% 11. PDF metadata
% ----------------------------------------------------------------------------
\AtBeginDocument{%
  \hypersetup{
    pdftitle={\swut@title},
    pdfauthor={\swut@author},
    pdfsubject={山东外国语职业技术大学本科毕业设计（论文）}
  }
}

\endinput
