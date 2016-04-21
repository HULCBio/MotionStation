function [hFit, name, isgood, outlier, dataset] = cfcopyfit(sourcefit)
%CFCOPYFIT Copy cftool fit

%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:39:40 $
%   Copyright 2004 The MathWorks, Inc.

hFit = copyfit(sourcefit);
name = hFit.name;
isgood = hFit.isGood;
outlier = hFit.outlier;
dataset = hFit.dataset;
hFit = java(hFit);

