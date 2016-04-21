function [proc,bigE] = getproc(cc)
% GETPROC (Private) Returns a) the name of the processor that cc is connected
% to and b) the endianness of cc.

% Copyright 2002-2003 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:04:04 $

ccinfo = info(cc);
family      = ccinfo.family;
subfamily   = ccinfo.subfamily;
revfamily   = ccinfo.revfamily;
bigE        = ccinfo.isbigendian;

if family == 470  % TMS470 family - ARM processor (R1x or R2x)
    if subfamily == 1
        proc   = 'r1x';
    elseif subfamily == 2
        proc   = 'r2x';
    else
        error('processor Not supported yet.');
    end        
else % TMS320 family
    if subfamily>=96 && subfamily < 112, % C6xx
        if subfamily==98 || subfamily==103, 
            % c62x or c67x
            proc = 'c67x';
        else 
            % c64x
            proc = 'c64x';
        end
    elseif subfamily==84, % C54x
        proc  = 'c54x';
    elseif subfamily==85, % C55x
        proc  = 'c55x';
    elseif subfamily == 40, % C28x
        proc = 'c28x';
    elseif subfamily == 39, % C27x
        proc = 'c27x';
    elseif subfamily == 36, % C24x
        proc = 'c24x';
    else
        error('Processor is not supported.');
    end
end

% [EOF] getproc.m