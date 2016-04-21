function label = uniqlabel(labelList,defaultLabel)
% UNIQLABEL Given a list of current labels (labelList) and a prefix (defaultLabel)
%           (eg. sig, filt, or spect) for a new label, this function appends a 
%           unique number to the prefix.
%
%           This helper function is used by: filtdes.m, spectview.m, applyfilt.m 
%           and sptimport.m.
% Inputs:
%    labelList - list of strings
%    defaultLabel - string; such as 'sig','filt'
% Output:
%    label - unique identifier such as 'sig1', 'sig2'
%

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $ $ Date: $

i=1;
label = [defaultLabel sprintf('%.9g',i)];
while ~isempty(findcstr(labelList,label))
   i=i+1;
   label = [defaultLabel sprintf('%.9g',i)];
end

% --- EOF uniqlabel ---
