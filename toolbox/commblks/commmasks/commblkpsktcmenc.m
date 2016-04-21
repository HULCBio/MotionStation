function [constpts, Mnum, err] = commblkpsktcmenc(block)
% COMMBLKPSKTCMENC Mask function for M-PSK TCM Encoder block
%
% Usage:
%      commblkpsktcmenc(block);

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/07/30 02:48:31 $

% -- Initialize the error message
err.msg =[];
err.mmi =[];
constpts = [];

% -- Get mask values and enables
En   = get_param(block, 'maskEnables');
Vals = get_param(block, 'maskValues');

% -- Get mask idx for Reset and Specchan parameter
setallfieldvalues(block);
Mnum = str2num(Vals{idxM});

% -- Check trellis
[isok, msg] = istrellis(maskTrellis);
if(~isok)
    err.msg = ['Invalid trellis structure. ' msg]; 
    err.mmi = 'commblks:tcmconstmapper:isTrellis';
    return;
end

outSym = maskTrellis.numOutputSymbols;
% -- Check of the trellis specified can work with the M-ary number chosen
if (outSym~=Mnum)
    err.msg = ['Incorrect trellis specified for the chosen M-ary number.'];
    err.mmi = 'comm:tcmconstmap:MTrellisDimension';
else
    constpts = tcmconstmapper(maskTrellis, Mnum, 'psk');
end

% [EOF]