function [emsg] = dspblkadpterrfcn(bh, errmsg)
% Error callback function (ErrFcn) for adaptive filter blocks
% in dspadpt3.

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/12 23:05:57 $

%if we are not producing any error return the last error
lerr = sllastdiagnostic;
emsg = lerr.Message;

%It is best to check each parameter here since
% several blocks throw different error for different reasons
% from the subsystem
% sllastdiagnostic is not very helpful in many cases

LMS = 1;
BLMS = 2;
RLS = 3;

blk = -1;
if (findstr(get_param(bh,'MaskInitialization'), 'dspblklms')) blk = LMS; end;
if (findstr(get_param(bh,'MaskInitialization'), 'dspblkfblms')) blk = BLMS; end;
if (findstr(get_param(bh,'MaskInitialization'), 'dspblkrls')) blk = RLS; end;
if (blk == -1) return; end;

%check filter length
try 
    L = evalin('base', get_param(bh, 'L'));
    %note: in the check below length check should be first since
    %      logical operator needs scalar values
    if (length(L) > 1 || L <= 0 || round(L)~=L || ~isreal(L))
        emsg = 'The filter length should be a scalar integer greater than 0.';
        return;
    end
catch
end

%check block length
if (blk == BLMS)
	try 
        N = evalin('base', get_param(bh, 'N'));
        %note: in the check below length check should be first since
        %      logical operator needs scalar values       
        if (length(N) > 1 || N <= 0 || round(N)~=N || ~isreal(N))
            emsg = 'Block size should be a scalar integer greater than 0.';
            return;
        end
	catch
	end
end

%check ic
try
    ic = evalin('base', get_param(bh, 'ic'));
    L = evalin('base', get_param(bh, 'L'));
    if (length(ic) > 1 && length(ic) ~= L)
        emsg= 'Initial conditions should be either a scalar or a vector equal to the filter length';
        return;
    end
catch
end

%check step-size
if (blk ~= RLS)
	try 
        mu = evalin('base', get_param(bh, 'mu'));
        if (length(mu) > 1 || mu < 0)
            emsg = 'Step-size should be a positive scalar value.';
            return;
        end
        if (~isreal(mu))
            emsg = 'Step-size should not be complex.';
            return;
        end
	catch
	end
end

%check leakage
if (blk ~= RLS)
	try
        l = evalin('base', get_param(bh, 'leakage'));
        if ( length(l) > 1 || l < 0 || l > 1 || ~isreal(l))
            emsg = 'Leakage factor should be between 0 and 1.';
            return;
        end
	catch
	end
else %check lambda
	try
        l = evalin('base', get_param(bh, 'lambda'));
        if (l < 0 || l > 1 || ~isreal(l))
            emsg = 'Forgetting factor should be between 0 and 1.';
            return;
        end
	catch
	end
end

%dimension check for BLMS
if (blk == BLMS)
    if (~isempty(findstr(lerr.MessageID, 'SL_PortDimsMismatch')) ||...
        ~isempty(findstr(lerr.MessageID, 'SL_AssignmentInvDataPortWidth')) )
        if (strcmp(get_param(bh, 'algo'), 'Block LMS'))
            emsg = 'The Input frame length should be an integer multiple of block length.';
            return;
        else
            emsg = 'The Input frame length should be an integer multiple of block length.';
            return;
        end
    end
    try
        %check L+N == power of 2
        if (strcmp(get_param(bh, 'algo'), 'Fast Block LMS'))
            L = evalin('base', get_param(bh, 'L'));
            N = evalin('base', get_param(bh, 'N'));
            s = uint32(L+N);
            sminus1 = uint32(L+N-1);
            if (bitand(s,sminus1) ~= 0)
                emsg = 'The sum of filter length and block length should be a power of 2.';
            end
            return;
        end
    catch
    end
end