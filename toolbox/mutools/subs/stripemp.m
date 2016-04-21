% function out = stripemp(ins,num)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = stripemp(ins,num)
%	replaces '[]' in '([]' with int2str(num)

	lb = find(ins=='[');

	out = [];
	lev = 0;
	for i=1:length(ins)
		if ins(i)=='(' & lev == 0
			lev = 1;
			out = [out ins(i)];
		elseif ins(i)=='[' & lev == 1
			lev = 2;
			out = [out ins(i)];
		elseif ins(i)==']' & lev == 2
			out = [out(1:length(out)-1) int2str(num)];
			lev = 0;
		else
			out = [out ins(i)];
			lev = 0;
		end
	end

