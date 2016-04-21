function val=get(t,varargin)
%GET retrieves a tlc context parameter
%   GET(H,PARAMETER) retrieves PARAMETER
%   from the user data fields of tlc 
%   context H.
%
%   See also: TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:57:07 $

switch length(varargin)
case 0
   val=[];
case 1
   val=tlc('get',t.Handle,varargin{1});
otherwise
   val={};
   for i=1:length(varargin)
      val{i}=tlc('get',t.Handle,varargin{i});
   end
end
