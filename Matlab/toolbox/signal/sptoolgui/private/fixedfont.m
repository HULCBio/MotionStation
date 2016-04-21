function [fontname,fontsize] = fixedfont
%FIXEDFONT Returns name and size of a fixed width font for this system.
%   Example usage:
%     [fontname,fontsize] = fixedfont;

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.9 $

fontname = get(0,'fixedwidthfontname');
fontsize = get(0,'defaultuicontrolfontsize');
