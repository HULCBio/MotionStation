%CVEXIT Exit the Coverage environment.
%

%
%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/03/23 03:00:58 $

[m__,x__]=inmem;

CVCoveragePresent__ = 0;

for i__=1:length(x__)
	if strcmp(x__{i__},'cv')
		CVCoveragePresent__ = 1;
	end
end


if CVCoveragePresent__
  cv('unlock');
  clear('cv');
end

clear('m__');
clear('x__');
clear('CVCoveragePresent__');
