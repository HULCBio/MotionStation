function flag = isnan(data)
%IDDATA/ISNAN
%
%   FLAG = ISNAN(DATA)
%
%   DATA is an IDDATA object.
%   FLAG is returned as 1 if any data point in DATA is NaN, that is
%         marked as missing or unknown.

%	L. Ljung 00-05-10
%	Copyright 1986-2001 The MathWorks, Inc.
%	$Revision: 1.3 $  $Date: 2001/04/06 14:22:04 $

y = data.OutputData;
u = data.InputData;
flag = 0;
for kexp = 1:length(y)
   z = [y{kexp},u{kexp}];
   if any(any(isnan(z))')
      flag = 1;
   end
end
