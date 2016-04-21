function dat1 = getexp(dat,arg)
%GETEXP Retrieve particular experiments from an IDDATA object.
%
%   D = GETEXP(DAT,ExpNumber) or D = GETEXP(DAT,ExpName) extracts specific
%   experiments from the multi-experiment IDDATA object DAT.  You can refer
%   to particular experiments either by number (e.g., ExpNumber=2) or by name
%   (e.g., ExpName='Day 1').  GETEXP returns an IDDATA object D containing the 
%   requested experiments.
%
%   Examples: 
%      D = getexp(Dat,2)               D = getexp(Dat,[3 1])
%      D = getexp(Dat,'Period1')       D = getexp(Dat,{'Day 1','Period 2'})
%
%   See also IDDATA, IDDATA/MERGE, IDDATA/SUBSREF.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $ $Date: 2004/04/10 23:15:51 $

if nargin<2
    disp('Usage: D = GETEXP(DATA,ExperimentNumber)');
    dat1=[];
    return
end

Struct.type = '()';
Struct.subs = {':',':',':',arg};
try
    dat1 = subsref(dat,Struct);
catch
    error(lasterr)
end