function showfixptsimranges
%SHOWFIXPTSIMRANGES show min/max/overflow logs from last simulation

% Copyright 1994-2003 The MathWorks, Inc. 
% $Revision: 1.7.4.4 $  
% $Date: 2003/05/17 04:47:15 $

evalin('base','global FixPtSimRanges');

global FixPtSimRanges;

for i = 1:length(FixPtSimRanges)
	disp(' ')
	disp(FixPtSimRanges{i})
end
