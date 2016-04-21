% function svalue = agv2str(value,mask)
%	mask = 0, value is basically a number, default
%	mask = 1, use setstr(value)
%	mask = 2, 2 decimal places

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function svalue = agv2str(value,mask)
  if nargin == 1
    mask = 0;
  end
  if isinf(value)
    svalue = '';
  elseif isnan(value)
    svalue = '';
  elseif mask == 0 | mask == 2
	if (floor(value) == ceil(value)) & abs(value)<10000
		svalue = int2str(value);
	elseif value>=1e4 | value<=1e-4
		svalue = sprintf('%1.0e',value);
	elseif value<1 & value>0
		if mask==0
			svalue = sprintf('%1.3f',value);
		else
			svalue = sprintf('%4.2f',value);
		end
	elseif value>=1 & mask==2
		svalue = num2str(value);
		len = min([size(svalue,2) 4]);
		svalue = svalue(1:len);
	else
		svalue = num2str(value);
	end
  else
	svalue = setstr(value);
  end