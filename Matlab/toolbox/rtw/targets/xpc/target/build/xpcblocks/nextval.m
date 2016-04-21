function y=nextval(a,b)

%nextval -helper function for incscid


%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/08 21:03:16 $

if isempty(find((b+1)==a))
    y=(b+1);
else
    y=nextval(a,b+1);
end

