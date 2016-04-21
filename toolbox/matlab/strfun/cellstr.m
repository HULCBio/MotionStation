function c = cellstr(s)
%CELLSTR Create cell array of strings from character array.
%   C = CELLSTR(S) places each row of the character array S into 
%   separate cells of C.
%
%   Use CHAR to convert back.
%
%   Another way to create a cell array of strings is by using the curly
%   braces: 
%      C = {'hello' 'yes' 'no' 'goodbye'};
%
%   See also STRINGS, CHAR, ISCELLSTR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.4 $  $Date: 2004/04/10 23:32:32 $
%==============================================================================

if ischar(s)
	if isempty(s)
	    c = {''};
	else
		if ndims(s)~=2 
			error('MATLAB:cellstr:InputShape','S must be 2-D.')
		end

		[rows,cols]=size(s);
		c = cell(rows,1);
		lastcolSpace = isspace(s(:,cols));
		for i=1:rows
			if lastcolSpace(i)
				m = find(~isspace(s(i,:)),1,'last');
				if isempty(m)
					c{i} = '';
				else
					c{i} = s(i,1:m);
				end
			else
				c{i} = s(i,:);
			end
		end
	end
elseif iscellstr(s)
    c = s; 
else
	error('MATLAB:cellstr:InputClass','Input must be a string.')
end
%==============================================================================