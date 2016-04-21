function val=query(t,varargin)
%QUERY retrieves data from a TLC context
%   QUERY(H,REFERENCE) gets the value of
%   REFERENCE from tlc context H.
%
%   See also: TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:57:00 $

switch length(varargin)
case 0
   val=[];
case 1
   val=tlc('query',t.Handle,varargin{1});
otherwise
   val={};
   for i=1:length(varargin)
      val{i}=tlc('query',t.Handle,varargin{i});
   end
end
