% function out = mkth(i)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = mkth(i)

	if i == 1
		out = '1st';
	elseif i == 2
		out = '2nd';
	elseif i == 3
		out = '3rd';
	else
		out = [int2str(i) 'th'];
	end