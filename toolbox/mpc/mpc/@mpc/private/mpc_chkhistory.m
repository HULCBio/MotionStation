function newhist=mpc_chkhistory(hist)

%MPC_CHKHISTORY Check correctness of history field and possibly convert it to
%   CLOCK format
%
%   See DATESTR, DATENUM, DATEVEC, CLOCK

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:05 $ 

if ischar(hist),
    % Assume time is given in DATESTR format
    newhist=datevec(hist);
    return
end

if isnumeric(hist),
    if prod(size(hist))==1,
        % Assume time is given in DATENUM format (one number)
        newhist=datevec(hist);
    else
        newhist=hist(:)';
        if length(newhist)~=6,
            error('mpc:mpc_chkhistory:time','Time format is invalid. See CLOCK, DATEVEC, DATESTR, DATENUM');
        end
    end
end     