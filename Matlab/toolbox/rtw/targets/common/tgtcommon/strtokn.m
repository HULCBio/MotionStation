function token = strtokn(string,delim,n)
%STRTOKN

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:31 $

remainder = string;

if isempty(delim)
  delim = ' ';
end

while (n>0 & ~isempty(remainder)),
  [token, remainder] = strtok(remainder,delim);
  n=n-1;
  strcmp(token,remainder);
end
