\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\ProvidesClass{swutthesis}[2026/07/24 v0.2 SWUT undergraduate thesis class]

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

\LoadClass[a4paper,UTF8,zihao=-4,twoside,openany]{ctexbook}

% Page geometry
\RequirePackage{geometry}
\geometry{
  a4paper,
  top=2.5cm,
  bottom=2.0cm,
  inner=2.0cm,
  outer=2.0cm,
  bindingoffset=0.5cm,
  headheight=15pt,
  headsep=0.35cm,
  % Word's 1.5 cm footer setting measures from the paper edge to the footer
  % baseline.  With a 2 cm LaTeX bottom margin, the equivalent footskip is
  % about 0.44 cm (text-area bottom to footer baseline).
  footskip=0.44cm
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
\defaultfontfeatures{Ligatures=TeX,Scale=MatchLowercase}

% Western fonts: prefer the fonts named by the Word specification, then use
% metrically compatible TeX Live fonts.
\IfFontExistsTF{Times New Roman}
  {\setmainfont{Times New Roman}}
  {\setmainfont{TeX Gyre Termes}}
\IfFontExistsTF{Arial}
  {\setsansfont{Arial}}
  {\setsansfont{TeX Gyre Heros}}
\IfFontExistsTF{Courier New}
  {\setmonofont{Courier New}}
  {\setmonofont{TeX Gyre Cursor}}
% Word uses an unscaled 10.5 pt Times New Roman page number.  Keep this family
% separate because the document's Western fonts use MatchLowercase scaling.
\IfFontExistsTF{Times New Roman}
  {\newfontfamily\swutpagefont[Scale=1]{Times New Roman}}
  {\newfontfamily\swutpagefont[Scale=1]{TeX Gyre Termes}}

% Chinese fonts: Windows -> macOS -> TeX Live fallback.
% CTeX has already installed platform defaults.  Replacing the main and sans
% defaults here is intentional, so suppress only its known redefinition notice.
\ExplSyntaxOn
\msg_redirect_name:nnn { xeCJK } { CJKfamily-redef } { none }
\ExplSyntaxOff
\IfFontExistsTF{SimSun}
  {\setCJKmainfont[AutoFakeBold=2.5]{SimSun}}
  {
    \IfFontExistsTF{STSong}
      {\setCJKmainfont[AutoFakeBold=2.5]{STSong}}
      {\setCJKmainfont[AutoFakeBold=2.5]{FandolSong-Regular}}
  }
\IfFontExistsTF{SimHei}
  {\setCJKsansfont[AutoFakeBold=2.5]{SimHei}}
  {
    \IfFontExistsTF{STHeiti}
      {\setCJKsansfont[AutoFakeBold=2.5]{STHeiti}}
      {\setCJKsansfont[AutoFakeBold=2.5]{FandolHei-Regular}}
  }
\ExplSyntaxOn
\msg_redirect_name:nnn { xeCJK } { CJKfamily-redef } { warning }
\ExplSyntaxOff
% The two supplied Founder fonts are loaded from the project without requiring
% installation. ASCII aliases avoid non-ASCII path issues in XeTeX on Windows.
\IfFileExists{fonts/FZXBS.ttf}
  {\newCJKfontfamily\swutschoolfont[Path={fonts/}]{FZXBS.ttf}}
  {\newcommand{\swutschoolfont}{\songti}}
\IfFileExists{fonts/FZCHSJ.ttf}
  {\newCJKfontfamily\swutcoverfont[Path={fonts/}]{FZCHSJ.ttf}}
  {\newcommand{\swutcoverfont}{\heiti}}

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
  itemsep=0pt,
  parsep=0pt,
  partopsep=0pt
}
\setcounter{secnumdepth}{4}
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
\newcommand{\swut@supervisor}{}
\newcommand{\swut@date}{二〇二六年六月}

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
\newcommand{\supervisor}[1]{\gdef\swut@supervisor{#1}}
\newcommand{\coverdate}[1]{\gdef\swut@date{#1}\date{#1}}

% ----------------------------------------------------------------------------
% 5. Cover and declaration pages
% ----------------------------------------------------------------------------
% #1 label, #2 value, #3 text vertical coordinate, #4 underline coordinate.
\newcommand{\swut@coverrow}[4]{%
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=108bp,yshift=-#3]current page.north west)
    {{\heiti\sffamily\fontsize{15bp}{18bp}\selectfont
      \makebox[78bp][l]{#1}}};
  \node[anchor=north,inner sep=0pt,text width=318.5bp,align=center]
    at ([xshift=347.25bp,yshift=-#3]current page.north west)
    {{\heiti\sffamily\fontsize{15bp}{18bp}\selectfont #2}};
  \draw[line width=0.75bp]
    ([xshift=188bp,yshift=-#4]current page.north west) --
    ([xshift=506.5bp,yshift=-#4]current page.north west);
}

\renewcommand{\maketitle}{%
  \begin{titlepage}
    \thispagestyle{empty}
    \begin{tikzpicture}[remember picture,overlay]
      % The group is exported unchanged from Word's two-picture Group 13.
      % Word size: 397.95 pt × 83.45 pt; position: x=106.15 pt, y=107.10 pt.
      \node[anchor=north west,inner sep=0pt]
        at ([xshift=106.15bp,yshift=-107.10bp]current page.north west)
        {\includegraphics[width=397.95bp,height=83.45bp]
          {assets/swut-wordmark.png}};

      \node[anchor=north,inner sep=0pt]
        at ([yshift=-202.50bp]current page.north)
        {{\swutschoolfont\fontsize{36bp}{43.2bp}\selectfont
          毕业设计（论文）}};

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

      \swut@coverrow{学生姓名：}{\swut@author}{469.50bp}{498.00bp}
      \swut@coverrow{学\hspace{18bp}号：}{\swut@studentid}{508.00bp}{537.00bp}
      \swut@coverrow{学\hspace{18bp}院：}{\swut@college}{546.00bp}{575.00bp}
      \swut@coverrow{专\hspace{18bp}业：}{\swut@major}{584.50bp}{613.50bp}
      \swut@coverrow{指导教师：}{\swut@supervisor}{623.00bp}{652.00bp}

      \node[anchor=north,inner sep=0pt]
        at ([yshift=-742.50bp]current page.north)
        {{\heiti\sffamily\fontsize{15bp}{22.5bp}\selectfont\swut@date}};
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

% #1 signature row coordinate; #2 underline/date reference coordinate.
\newcommand{\swut@declarationsignature}[2]{%
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=317.5bp,yshift=-#1]current page.north west)
    {{\songti\rmfamily\fontsize{12bp}{18bp}\selectfont 作者签名：}};
  \node[anchor=north west,inner sep=0pt,text=red]
    at ([xshift=404bp,yshift=-#1]current page.north west)
    {{\songti\rmfamily\bfseries\fontsize{12bp}{18bp}\selectfont
      （手签）（完稿请删除）}};
  \draw[line width=0.5bp]
    ([xshift=382.5bp,yshift=-#2]current page.north west) --
    ([xshift=539bp,yshift=-#2]current page.north west);
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=317.5bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\songti\rmfamily\fontsize{12bp}{18bp}\selectfont
      日\hspace{24bp}期：}};
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=388.5bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\rmfamily\fontsize{12bp}{18bp}\selectfont 20}};
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=424bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\songti\fontsize{12bp}{18bp}\selectfont 年}};
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=470bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\songti\fontsize{12bp}{18bp}\selectfont 月}};
  \node[anchor=north west,inner sep=0pt]
    at ([xshift=516bp,yshift=-\dimexpr#2+22bp\relax]current page.north west)
    {{\songti\fontsize{12bp}{18bp}\selectfont 日}};
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

\fancypagestyle{swut-front}{%
  \fancyhf{}
  \renewcommand{\headrulewidth}{0pt}
  \fancyfoot[C]{\swut@pagenumber}
}

\fancypagestyle{swut-main}{%
  \fancyhf{}
  \fancyhead[C]{\songti\rmfamily\zihao{5}\swut@title}
  \fancyfoot[C]{\swut@pagenumber}
  \renewcommand{\headrulewidth}{0.4pt}
}

% Keep chapter-opening pages consistent with the active matter style.
\newcommand{\swut@setfrontplain}{%
  \fancypagestyle{plain}{%
    \fancyhf{}
    \renewcommand{\headrulewidth}{0pt}
    \fancyfoot[C]{\swut@pagenumber}
  }%
}

\newcommand{\swut@setmainplain}{%
  \fancypagestyle{plain}{%
    \fancyhf{}
    \fancyhead[C]{\songti\rmfamily\zihao{5}\swut@title}
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
    beforeskip = 0pt,
    % Fine adjustment from the rendered Word/PDF title-to-body comparison.
    aftertitle = \par\vspace{0.95bp},
    afterskip = 0pt,
    afterindent = true
  },
  subsection = {
    aftername = \swut@headingnumberseparator,
    format = \setstretch{1}\heiti\sffamily
      \fontsize{12bp}{18bp}\selectfont,
    beforeskip = 0pt,
    % Match the measured 10.1 bp visible gap before body text.
    aftertitle = \par\vspace{-1.29bp},
    afterskip = 0pt,
    afterindent = true
  },
  subsubsection = {
    aftername = \swut@headingnumberseparator,
    format = \setstretch{1}\songti
      \fontsize{12bp}{18bp}\selectfont,
    beforeskip = 0pt,
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
% follows another heading. Restore the measured Word gap in that case only.
\pretocmd{\subsection}{%
  \if@nobreak\vspace{4.77bp}\fi
}{}{%
  \ClassWarning{swutthesis}{Unable to patch adjacent subsection spacing}%
}
\renewcommand{\thesubsubsection}{（\arabic{subsubsection}）}

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
\renewcommand{\cftfigpresnum}{图~}
\renewcommand{\cfttabpresnum}{表~}
\setlength{\cftfignumwidth}{3.5em}
\setlength{\cfttabnumwidth}{3.5em}

\newcommand{\swuttableofcontents}{%
  \clearpage
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
\captionsetup[table]{position=top,skip=6pt}
\setlength{\heavyrulewidth}{1.5pt}
\setlength{\lightrulewidth}{0.75pt}
\setlength{\cmidrulewidth}{0.75pt}
\renewcommand{\arraystretch}{1.2}
\newenvironment{swuttable}{\zihao{5}\singlespacing}{}

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
  aboveskip=0.35\baselineskip,
  belowskip=0.35\baselineskip,
  float=htbp
}
% A floating listing otherwise receives both the listing skip and LaTeX's
% comparatively large generic float separation.  Keep code visually attached
% to its explanation while retaining the whole-block page-breaking behaviour.
\AtBeginEnvironment{lstlisting}{%
  \setlength{\intextsep}{0.35\baselineskip}%
  \setlength{\textfloatsep}{0.35\baselineskip}%
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
