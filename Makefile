ODFLIB := $(abspath ./java-sample/simple-odf-0.8.2-incubating-jar-with-dependencies.jar)
CLASSPATH := .:$(ODFLIB)
name := adam-ibrahim
nameForFiles := $(name)-resume

all : resume
resume : output/$(nameForFiles).pdf output/$(nameForFiles).odt

output/$(nameForFiles).pdf : resume.tex
	lualatex --output-directory output $< 
	mv output/$(basename $^).pdf $@

output/resume-example.odt : java-sample/ResumeExample.class
	cd java-sample; java -cp $(CLASSPATH) $(notdir $(basename $<))
	mv java-sample/resume.odt $@

output/$(nameForFiles).odt : resume.class
	java -cp $(CLASSPATH) $(notdir $(basename $<))
	mv resume.odt $@

%.class : %.java
	javac -cp $(CLASSPATH) $<

%.run : %.class
	cd $(dir $<); java -cp $(CLASSPATH) $(notdir $(basename $<))


resume.tex : resume.poly.pm pollen.rkt template.tex.p
	raco pollen render resume.tex

resume.java : resume.poly.pm pollen.rkt template.java.p
	raco pollen render resume.java

.PHONY : test
test :
	echo $(shell pwd)
	echo $(nameForFiles)
