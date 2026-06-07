\ProvidesClass{rootmos}[2026/05/12 v0.0.2 rootmos' document class]

\RequirePackage{etoolbox}

\newtoggle{@debugcite}
\DeclareOption{debugcite}{%
  \toggletrue{@debugcite}
}

\newtoggle{@debuglayout}
\DeclareOption{debuglayout}{%
  \toggletrue{@debuglayout}
}

\newtoggle{@debug}%
\DeclareOption{debug}{%
  \toggletrue{@debugcite}
  \toggletrue{@debuglayout}
}

\newtoggle{@notes}
\DeclareOption{notes}{%
  \toggletrue{@notes}
}

\newtoggle{@nomargin}
\DeclareOption{nomargin}{%
  \toggletrue{@nomargin}
}

\newtoggle{@apacite}
\DeclareOption{apacite}{%
  \toggletrue{@apacite}
}

\newtoggle{@apa}
\DeclareOption{apa}{%
  \toggletrue{@apacite}
  \toggletrue{@apa}
}

\newtoggle{@swedish}
\DeclareOption{swedish}{%
  \toggletrue{@swedish}
}

\newtoggle{@toc}
\DeclareOption{toc}{%
  \toggletrue{@toc}
}

\newtoggle{@mdu}
\DeclareOption{mdu}{%
  \toggletrue{@swedish}
  \toggletrue{@apacite}
  \toggletrue{@apa}
  \toggletrue{@toc}
  \toggletrue{@mdu}
}

\newtoggle{@notme}
\DeclareOption{notme}{%
  \toggletrue{@notme}
}

\ProcessOptions\relax

\directlua{require("rootmos").setup()}

\RequirePackage[\jobtype]{ifdraft}

\iftoggle{@mdu}{%
  \ifdraft{% draft
    \LoadClass[a4paper,doc,draft]{apa7}
    \setcounter{secnumdepth}{3}
  }{% final
    \LoadClass[a4paper,stu,final]{apa7}
    \renewcommand{\baselinestretch}{1.5}
  }%
}{% not @mdu
  \iftoggle{@apa}{% @apa
    \LoadClass[a4paper,doc,\jobtype]{apa7}
  }{% not @apa
    \LoadClass[a4paper,11pt,\jobtype]{article}
  }
}

\RequirePackage{geometry}
\geometry{a4paper}

\newlength{\nomargin}
\setlength{\nomargin}{7mm}
\iftoggle{@nomargin}{
  \ifdraft{
    \geometry{margin=\nomargin, hmargin={\nomargin,\dimexpr\marginparsep+\marginparwidth+\nomargin}}
  }{
    \geometry{margin=\nomargin}
  }
}{
  \geometry{margin=20mm}
}

\iftoggle{@debuglayout}{%
  \geometry{showframe}
  \usepackage[type=alledges]{fgruler}
  \usepackage{layout}
}

\iftoggle{@swedish}{%
  \usepackage[swedish]{babel}
}{% not @swedish
  \usepackage[english]{babel}
}%

\usepackage{hyperref}
\hypersetup{final}

\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{mathtools}

\usepackage{verbatim}

\usepackage[\jobtype,obeyDraft,textsize=tiny,\iftoggle{@swedish}{swedish}{english},tickmarkheight=1mm]{todonotes}
\NewDocumentCommand{\todof}{O{} m}{%
    \todo[inline,noinlinepar,size=normalsize,#1,inlinewidth=\textwidth-1.7em]{#2}% TODO
}
\NewDocumentCommand{\todoi}{O{} m}{%
    \ifhmode\hfill\break\fi%
    \todo[inline,noinlinepar,size=normalsize,#1]{#2}%
    \ifhmode\vspace{-\parskip}\par\noindent\fi\ignorespaces%
}

\iftoggle{@apacite}{%
  \usepackage[style=apa,backend=biber,useprefix=true]{biblatex}
  \input{rootmos-cite-apa.tex}
}{% not @apa
  \usepackage[style=numeric,backend=biber,useprefix=true]{biblatex}
  \input{rootmos-cite.tex}
}
\directlua{require("rootmos-cite").setup()}

\DeclareBibliographyCategory{ignore}
\addbibresources

% https://tex.stackexchange.com/a/588446
\usepackage{xpatch}
\xpretobibmacro{doi+url}{\printfield{isbn}}{}{}

% TODO biblatex urlstyle?
\urlstyle{tt}

\iftoggle{@mdu}{%
  \ifdraft{% draft
    \usepackage[style=american]{csquotes}
  }{
    \usepackage[style=swedish]{csquotes}
  }
}{
  \usepackage[style=american]{csquotes}
}
\SetBlockThreshold{0}
\SetCiteCommand{\pc}

\usepackage{enumitem}
\setlist{noitemsep,topsep=0.1\baselineskip}

\iftoggle{@notes}{
  \setlength{\parindent}{0pt}
  \setlength{\parskip}{0.4\baselineskip}
}

\def\rootmos@email{\url{me@rootmos.\iftoggle{@swedish}{se}{io}}}
\def\mdu@email{\url{gbm26001@student.mdu.se}}

\AtBeginDocument{%
  \renewcommand*{\thefootnote}{\fnsymbol{footnote}}%
  \setcounter{footnote}{1}%
}

\ifdraft{}{\AtBeginDocument{\maketitle}}

\iftoggle{@notme}{}{%
  \IfFileExists{./me.tex}{\input{./me.tex}}{%
    \author{Gustav Behm\footnote{\rootmos@email\iftoggle{@mdu}{, \mdu@email}{}}}
    \iftoggle{@apa}{\iftoggle{@mdu}{}{\affiliation{\,}}}{}
  }
}

\iftoggle{@apa}{
  \ifdraft{
    \abstract{\,}
  }
}{
  \newcommand{\shorttitle}[1]{}
}

\iftoggle{@mdu}{
  \IfFileExists{./course.tex}{\input{./course.tex}}{}
}

\iftoggle{@toc}{
  \ifdraft{}{\AtBeginDocument{\tableofcontents}}
}

\def\@buildinfo{%
  \renewcommand*{\thefootnote}{}%
  \ifdraft{%
    \footnotetext{%
      \iftoggle{@swedish}{Antal ord}{Word count}:
      \directlua{require("rootmos").wordcount()}
    }%
  }{}%
  \footnotetext{\directlua{tex.print(require("rootmos").buildinfo())}}%
}

\ifdraft{%
  \AtBeginDocument{\@buildinfo}%
}{%
  \iftoggle{@mdu}{%
    \note{\@buildinfo}%
  }{%
    \AtBeginDocument{\@buildinfo}%
  }
}

\AtBeginDocument{%
  \renewcommand*{\thefootnote}{\arabic{footnote}}%
  \setcounter{footnote}{0}%
}

\input{rootmos-candy.tex}

\AtEndDocument{%
  \ifdraft{%
    \iftoggle{@debugcite}{\nocite{*}}{}%
    \clearpage%
  }{}%
  \printbibliography[notcategory=ignore]%
  \ifdraft{\listoftodos}{}
}

\iftoggle{@debuglayout}{%
  \AtEndDocument{\clearpage\layout{}}
}{}
