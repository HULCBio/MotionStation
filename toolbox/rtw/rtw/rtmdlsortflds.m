function y = rtmdlsortflds(flds, indices)
%RTMDLSORTFLDS is a RTW support function.
%   RTWMDLPATHTOK is a RTW support function which is used to sort 
%   an array of names on the basis of a vector of indices.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.2 $

[junk,sortI] = sort(indices);

y = flds(sortI,:);

% [EOF] rtmdlsortflds.m
