function cleanup(z)
%CLEANUP 
%
%   See also INITIALIZE

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:56:22 $


%global FixLogPref;
%global FixLogMerge;
%global FixUseDbl;

%FixLogPref  = subsref(z,substruct('.','FixGlobalLogPref'));
%FixLogMerge = subsref(z,substruct('.','FixGlobalLogMerge'));
%FixUseDbl   = subsref(z,substruct('.','FixGlobalUseDbl'));


