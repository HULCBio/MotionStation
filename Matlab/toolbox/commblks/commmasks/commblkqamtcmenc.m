function [constpts, Mnum, err] = commblkqamtcmenc(block)
% COMMBLKQAMTCMENC Mask function for Rectangular QAM TCM Encoder block
%
% Usage:
%      commblkqamtcmenc(block);

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/07/30 02:48:33 $

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
% -- Check if the specified trellis works with chosen M-ary number
if (outSym~=Mnum)
    err.msg = ['Incorrect trellis specified for the chosen M-ary number.'];
    err.mmi = 'comm:tcmconstmap:MTrellisDimension';
else
    constpts = tcmconstmapper(maskTrellis, Mnum, 'qam');
end

% [EOF]