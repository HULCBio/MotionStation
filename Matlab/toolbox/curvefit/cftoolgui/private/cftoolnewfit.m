function [hFit, name, isgood] = cftoolnewfit()
%CFCREATEFIT Create cftool fit

%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:40:14 $
%   Copyright 2004 The MathWorks, Inc.

hFit = cftool.fit;
name = hFit.name;
isgood = hFit.isGood;
hFit = java(hFit);

