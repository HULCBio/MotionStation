% function svalue = sim2str(value,mask)
%	mask = 0, value is basically a number, default
%	mask = 1, use setstr(value)
%       mask = 2, get out the color/line type data

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function svalue = sim2str(value,mask)

  if nargin == 1
    mask = 0;
  end
  if isinf(value)
    svalue = '';
  elseif isnan(value)
    svalue = '';
  elseif mask == 0
	if (floor(value) == ceil(value)) & abs(value)<10000
		svalue = int2str(value);
	elseif value>=1e4 | value<=1e-4
		svalue = sprintf('%1.0e',value);
	elseif value<1 & value>0
		svalue = sprintf('%1.3f',value);
	else
		svalue = num2str(value);
	end
  elseif mask == 1
	svalue = setstr(value);
  elseif mask == 2
	color = floor(value);
	lt1 = floor(1000*(value-color));
	lt2 = floor(1000000*(value-(color+lt1/1000)));
% the 1st entry is the color, 2nd and 3rd entry are the line type/symbol
	svalue = [color lt1 lt2];
	svalue = abs(value);
  end