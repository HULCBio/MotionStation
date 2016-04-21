% function str = seesub(mij,form)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function str = seesub(mij,form)

loc=find(form=='.')-find(form=='%');
if isempty(loc), loc=1; end
if any(form=='e') & loc==1
    pad = ' ';
else
    pad = [];
end %if
	if mij < 0
		str = sprintf(form,mij);
	else
		str = sprintf([pad form], abs(mij));
	end

%
%