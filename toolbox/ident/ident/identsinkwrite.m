function identsinkwrite(name,Ts,in,out)

z = iddata(out,in,Ts);
assignin('base',name,z);

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:18:59 $
