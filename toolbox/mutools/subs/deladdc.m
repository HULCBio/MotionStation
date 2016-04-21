% function out = deladdc(in,coord,want)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = deladdc(in,coord,want)

	nn = size(in,1);
	if want
		if nn == 0
			out = coord;
		else
			loc = find(sum(abs(in-ones(nn,1)*coord)')==0);
			if isempty(loc)
				out = [in;coord];
			else
				out = in;
			end
		end
	else
		if nn > 0
			loc = find(sum(abs(in-ones(nn,1)*coord)')==0);
			if ~isempty(loc)
				out = [in(1:loc-1,:) ; in(loc+1:nn,:)];
			else
				out = in;
			end
		else
			out = [];
		end
	end