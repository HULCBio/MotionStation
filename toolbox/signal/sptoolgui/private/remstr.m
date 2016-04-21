function outstr = remstr(instr,rem)
% REMSTR  Remove string from callback string.
%   STR1 = REMSTR(STR,REM) removes all occurrences of string REM from
%   string STR.
%   Removes a preceding comma if there is one and nothing following.
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

%   T. Krauss  11/21/94

if length(rem) == 0
	outstr = instr;
else
	if length(rem)>length(instr)
		outstr = instr;
	else
		outstr = instr;
		ind = findstr(outstr,rem);
		for i = 1:length(ind)
			outstr(ind(i)-(i-1)*length(rem)+(0:length(rem)-1)) = [];
		end

		% now remove trailing comma separator if present
		if length(outstr)>0
			ind = length(outstr);
			while (outstr(ind)==' ')
				ind = ind-1;
			end
			if instr(ind)==','
				outstr(ind:length(outstr)) = [];
			end
		end
	end
end

