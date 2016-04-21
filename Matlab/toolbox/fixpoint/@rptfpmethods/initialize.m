function varargout=initialize(z,coutlineHandle);
%INITIALIZE sets the Fixed Point information structure to empty
%   INITIALIZE(RPTFPMETHODS) sets up the Fixed Point information
%   structure with empty fields.
%
%   See also SUBSREF, CLEANUP

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:56:28 $


%global FixLogPref;
%global FixLogMerge;
%global FixUseDbl;

d.SignalInfo        = [];
%d.FixGlobalLogPref  = FixLogPref;
%d.FixGlobalLogMerge = FixLogMerge;
%d.FixGlobalUseDbl   = FixUseDbl;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargout==1
   varargout{1}=d;
else
   rgstoredata(z,d);
end
