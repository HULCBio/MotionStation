function [fitname, goodnessname, outputname] = cffitsavenames(fitprefix, goodnessprefix, outputprefix)
% CFFITSAVENAMES Creates unique variable names for save fit.  

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $

fitname = cfgetuniquewsname(fitprefix);
goodnessname = cfgetuniquewsname(goodnessprefix);
outputname = cfgetuniquewsname(outputprefix);
