◊(local-require racket)
◊(define (string-prepend* prefix)
    (lambda (str) (string-append prefix str)))
\documentclass{article}
%- Preamble: {{{ -------------------------------------------

% Disable page numbers.
\pagenumbering{gobble}
%- Packages: -----------------------------------------------
\usepackage[margin=.7in, asymmetric, centering]{geometry}
\usepackage{float}
\usepackage[inline]{enumitem}
\usepackage{fontspec} % Requires LuaLaTeX!
\usepackage{array} % For extra table stuffs, like before/after column commands.
\usepackage{tabu}
%- Fonts: --------------------------------------------------
\setmainfont{Heuristica}
%- Lengths: ------------------------------------------------
\setlength{\parindent}{0pt}
%- Commands: {{{ -------------------------------------------
% To do small caps: \textsc{}.
% For creating the effect of a building a left side and right side for
% places. Append table material to a list of tokens, then paste that
% material inside of a table at the end. To make breaks work, newlines
% are places before each token, and at the very end, the earliest
% newline is gobbled up by \gobblefirst.
\newcommand{\appendtotoks}[2]{% #1=toks register, #2-toks to append
  #1=\expandafter{\the#1#2}%
}
\def\gobble#1{}
\def\gobblefirst#1{%
  #1\expandafter\expandafter\expandafter{\expandafter\gobble\the#1}}
\newcommand{\name}[1]{{\huge #1} \vspace{10pt}}
\newcommand{\sectionTitle}[1]{{\Large #1} \vspace{4pt}}
\newenvironment{resumesection}[1]
  {\sectionTitle{#1}}
	{\vspace{10pt}}
\newcommand{\subSectionTitle}[1]{%
	{\large \textbf{#1}} \vspace{4pt}%
}
\newcommand{\placeStyle}[1]{\textbf{#1}}
\newcommand{\positionStyle}[1]{\textit{#1}}
\newenvironment{newplace}
  {
    \newtoks\leftToks
    \newtoks\rightToks
    \newcommand{\placerow}[2]{%
      \appendtotoks{\leftToks}{\\\placeStyle{##1}}%
      \appendtotoks{\rightToks}{\\##2}}
    \newcommand{\jobrow}[2]{%
      \appendtotoks{\leftToks}{\\\positionStyle{##1}}%
      \appendtotoks{\rightToks}{\\##2}}
    \newcommand{\plainrow}[2]{%
      \appendtotoks{\leftToks}{\\##1}%
      \appendtotoks{\rightToks}{\\##2}}
    \setlength{\tabcolsep}{0pt}%
  }
  {%
    \begin{tabu} to \linewidth [h!]{X[-65,l]X[-35,r]}
        \begin{tabular}{l}
            \gobblefirst\leftToks
            \the\leftToks
        \end{tabular}
        &
        \begin{tabular}{r}
            \gobblefirst\rightToks
            \the\rightToks
        \end{tabular}
    \end{tabu}%
  }
\newenvironment{bullets}
	{\begin{itemize}[noitemsep, topsep=0pt]}
	{\end{itemize}}

% From enumitem. itemize* means inline list.
\newlist{short}{itemize*}{1}
\setlist[short]{label={{}}, itemjoin={{, }}}

%- }}} -----------------------------------------------------
%- }}} -----------------------------------------------------
\begin{document}

◊(select 'personal-information doc)

◊(select 'education-information doc)

\begin{resumesection}{Technical Skills}

    \begin{bullets}
    ◊(select* 'skills doc)
    \end{bullets}

\end{resumesection}

◊(select 'projects doc)
◊(select 'experience doc)


\end{document}
