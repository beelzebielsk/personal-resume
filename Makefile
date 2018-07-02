ODFLIB := $(abspath ./java-sample/simple-odf-0.8.2-incubating-jar-with-dependencies.jar)
CLASSPATH := .:$(ODFLIB)

all : resume
resume : output/resume.pdf
output/resume.pdf : resume.tex
	lualatex --output-directory output $< 

%.class : %.java
	javac -cp $(CLASSPATH) $<

%.run : %.class
	cd $(dir $<); java -cp $(CLASSPATH) $(notdir $(basename $<))

output/resume.odt : java-sample/ResumeExample.class
	cd java-sample; java -cp $(CLASSPATH) $(notdir $(basename $<))
	mv java-sample/resume.odt output/resume.odt

.PHONY : test
test :
	echo $(shell pwd)

