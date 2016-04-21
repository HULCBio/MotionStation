function identsinkwrite(name,Ts,in,out)
% IDENTSINKWRITE Utility used by the ident sink block to write an iddata
%                object to the workspace

% John Glass 4/2003
% Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/08/26 13:31:22 $

z = iddata(out,in,Ts,'TStart',0);
assignin('base',name,z);

