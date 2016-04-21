function realflag = isreal(ze)
% ISREAL Checks if an IDDATA object contains complex data
%
%   ISREAL(DATA) returns 1 if all data points in DATA are real
%       and 0 else.
%
%   See also IDDATA/REALDATA and IDDATA/COMPLEX.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/04/10 23:16:00 $

realflag = 1;
for kexp = 1:length(ze.OutputData)
   if ~isreal(ze.OutputData{kexp}), realflag = 0;end
   if ~isreal(ze.InputData{kexp}), realflag = 0;end
end
