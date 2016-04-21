function varargout=nenw(r,stateValues);
%NENW turns errors and warnings off
%   A=NENW(R) sets warnings and errors off, returning
%   the previous error/warning state in structure A.
%   NENW(R,A) restores errors and warnings to state A.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:22 $

%if nargout>0
   wS=warning;
   dbS=dbstatus;
   varargout{1}=struct('WarnState',{wS},...
      'DbstopCond',{{dbS.cond}});
%end


if nargin>1
   %if we are handed a struct to implement
   dsc=stateValues.DbstopCond(find...
      (~cellfun('isempty',stateValues.DbstopCond)));
   for i=1:length(dsc)
      dbstop('if',dsc{i});
   end
   warning(stateValues.WarnState);
else
   warning off
   dbclear if error
   dbclear if warning
   dbclear if naninf   
end



