\ProvidesClass{rootmos}[2026/04/06 v0.0.1 rootmos' document class]

\RequirePackage{etoolbox}

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

\iftoggle{@swedish}{%
  \usepackage[swedish]{babel}
}{% not @swedish
  \usepackage[english]{babel}
}%

\usepackage[a4paper]{geometry}

\usepackage{hyperref}
\hypersetup{final}

\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{mathtools}

\usepackage{verbatim}
\usepackage[\jobtype,obeyDraft,textsize=tiny]{todonotes}

\iftoggle{@apacite}{%
  \usepackage[style=apa,backend=biber,useprefix=true]{biblatex}
  \input{rootmos-cite-apa.tex}
}{% not @apa
  \usepackage[style=numeric,backend=biber,useprefix=true]{biblatex}
  \input{rootmos-cite.tex}
}
\directlua{require("rootmos-cite").setup()}
\addbibresources

% https://tex.stackexchange.com/a/588446
\usepackage{xpatch}
\xpretobibmacro{doi+url}{\printfield{isbn}}{}{}

% TODO biblatex urlstyle?
\urlstyle{tt}

\usepackage{csquotes}
\SetBlockThreshold{0}
\SetCiteCommand{\pc}

\def\rootmos@email{\url{me@rootmos.\iftoggle{@swedish}{se}{io}}}
\def\mdu@email{\url{gbm26001@student.mdu.se}}

\AtBeginDocument{%
  \renewcommand*{\thefootnote}{\fnsymbol{footnote}}%
  \setcounter{footnote}{1}%
}

\ifdraft{}{\AtBeginDocument{\maketitle}}

\IfFileExists{./me.tex}{\input{./me.tex}}{%
  \author{Gustav Behm\footnote{\rootmos@email\iftoggle{@mdu}{, \mdu@email}{}}}
  \iftoggle{@apa}{\iftoggle{@mdu}{}{\affiliation{\,}}}{}
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
}{}

\iftoggle{@toc}{
  \ifdraft{}{\AtBeginDocument{\tableofcontents}}
}

\def\@buildinfo{%
  \renewcommand*{\thefootnote}{}%
  \footnotetext{%
    \iftoggle{@swedish}{Antal ord}{Word count}:
    \directlua{tex.print(require("rootmos").wordcount())}
  }%
  \footnotetext{\directlua{require("rootmos").buildinfo()}}%
}

\iftoggle{@apa}{
  \ifdraft{%
    \AtBeginDocument{\@buildinfo}%
  }{%
    \note{\@buildinfo}%
  }%
}{%
  \AtBeginDocument{\@buildinfo}%
}

\AtBeginDocument{%
  \renewcommand*{\thefootnote}{\arabic{footnote}}%
  \setcounter{footnote}{0}%
}{}

\AtEndDocument{%
  \ifdraft{%
    \nocite{*}%
    \clearpage%
  }{}%
  \printbibliography%
}
