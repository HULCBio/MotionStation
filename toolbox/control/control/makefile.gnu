# $Revision: 1.1.6.1 $
# This makefile will auto-generate Contents.m from Contents.m_template, 
# and ja/Contents.m from ja/Contents.m_template 
# 
TEMPLATE_TARGETS := Contents.m ja/Contents.m 
# 
# need an empty all target 
all: 
once : $(TEMPLATE_TARGETS) 

include template_rules.gnu 
