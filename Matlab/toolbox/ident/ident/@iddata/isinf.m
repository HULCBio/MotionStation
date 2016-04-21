function flag = isinf(data)
%IDDATA/ISINF
%
%   FLAG = ISINF(DATA)
%
%   DATA is an IDDATA object.
%   FLAG is returned as 1 if any data point in DATA is Inf.

%	L. Ljung 03-08-10
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.1 $  $Date: 2003/08/18 09:02:12 $

y = data.OutputData;
u = data.InputData;
flag = 0;
for kexp = 1:length(y)
   z = [y{kexp},u{kexp}];
   if any(any(isinf(z))')
      flag = 1;
   end
end
