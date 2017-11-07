all : resume
resume : output/resume.pdf
output/resume.pdf : resume.tex
	lualatex --output-directory output $< 
