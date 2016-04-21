function len = strlen(s)
%STRLEN  String length
%        LEN = STRLEN(S) returns the string length of each row in string
%        matrix S.
%

%
%  Written by E.Mehran Mestchian
%  Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11.2.1 $  $Date: 2004/04/15 01:00:47 $

error(nargchk(1,1,nargin));
[d,len]=max(s'==0);
if isempty(len),return,end
if size(s,2)==1,len=(s~=0);return,end
d=~d;
len(d)=len(d)+size(s,2);
len=len'-1;
