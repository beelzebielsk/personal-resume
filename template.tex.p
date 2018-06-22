◊(local-require racket)
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
    \begin{tabu} to \linewidth [h!]{X[65,l]X[35,r]}
      \begin{tabu} to \linewidth {X}
        \gobblefirst\leftToks
        \the\leftToks
      \end{tabu}
      &
      \begin{tabu} to \linewidth {X[r]}
        \gobblefirst\rightToks
        \the\rightToks
      \end{tabu}
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

\begin{center}
	\name{◊(select 'name doc)}

  {\setlength{\tabcolsep}{0pt}
    \begin{tabu} to \textwidth {XX[r]}
        ◊(let [(info (cons 'root (select* 'contact-information doc)))]
            (string-join (list
                (select 'email info) "&"
                (select 'github info) "\\\\"
                (select 'phone-number info) "&"
                (select 'linkedin info))))
    \end{tabu}
  }
\end{center}

\begin{resumesection}{Education}
    \begin{newplace}
        \placerow{◊(select-path 'education-information 'school 'name doc)}
                 {◊(select-path 'education-information 'school 'graduation-date doc)}
        \jobrow  {◊(select-path 'education-information 'school 'degree doc)}
                 {}
    \end{newplace}

    \begin{newplace}
        \placerow{Relevant Coursework}{}
    \end{newplace}

    \begin{short}
        ◊(let* [(to-item 
                 (lambda (result) 
                    (string-append "\\item " result)))
                (items (map to-item (select-path* 'coursework 'course doc)))]
            (string-join items "\n"))
    \end{short}

\end{resumesection}

\begin{resumesection}{Technical Skills}
   ◊(select-path* 'skills doc)
\end{resumesection}

\begin{resumesection}{Projects}
\end{resumesection}

\begin{resumesection}{Experience}
\end{resumesection}

\end{document}
