function sys = chgunits(sys,newUnits)
%CHGUNITS  Change frequency units of a frequency domain IDDATA set.
%
%   DAT = CHGUNITS(DAT,UNITS) changes the units of the frequency
%   points stored in the IDDATA set DAT to UNITS, where UNITS
%   is either 'Hz or 'rad/s'.  A 2*pi scaling factor is applied
%   to the frequency values and the 'Units' property is updated.
%   If the 'Units' field already matches UNITS, no action is taken.
%  
%   For Multiexperiment data UNITS should be a cell array of length
%   equal to the number of experiments. If 'Hz' or 'rad/s' is entered,
%   the same unit change is applied to all experiments.
%
%   See also IDFRD, SET, GET.

%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.2.4.1 $  $Date: 2004/04/10 23:15:42 $

if strcmp(lower(sys.Domain),'time')
    error('CHGUNITS can be applied only to frequency domain data sets.')
end
Nexp = size(sys,'Ne');
if ischar(newUnits)
    newUnits = repmat({newUnits},1,Nexp);
end
for kexp = 1:Nexp
    if ~strncmpi(sys.Tstart{kexp},newUnits{kexp},1)
        if strncmpi(newUnits{kexp},'h',1)
            sys.Tstart{kexp} = 'Hz';
            sys.SamplingInstants{kexp} = sys.SamplingInstants{kexp}/ (2*pi);
        elseif strncmpi(newUnits{kexp},'r',1)
            sys.Tstart{kexp} = 'rad/s';
            sys.SamplingInstants{kexp} = sys.SamplingInstants{kexp} * (2*pi);
        else
            error('Unrecognized UNITS string.');
        end
    end
end

