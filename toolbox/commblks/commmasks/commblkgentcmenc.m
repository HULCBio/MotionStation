function [constpts, Mnum, err] = commblkgentcmenc(block)
% COMMBLKGENTCMENC Mask function for General TCM Encoder block
%
% Usage:
%      commblkgentcmenc(block);

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/01 18:59:32 $

% -- Initialize the error message
err.msg = [];
err.mmi = [];
constpts = [];

% -- Get mask values and enables
En   = get_param(block, 'maskEnables');
Vals = get_param(block, 'maskValues');

% -- Get mask idx for Reset and Specchan parameter
setallfieldvalues(block);
Mnum = numel(str2num(Vals{idxConstpts}));

%-- Check trellis
[isok, msg] = istrellis(maskTrellis);
if(~isok)
    err.msg = ['Invalid trellis structure. ' msg]; 
    err.mmi = 'commblks:tcmconstmapper:isTrellis';
    return
end

%-- Check constellation points: 
% Error out if empty, matrix, 1D vector, non-numeric or non-complex
if isempty(maskConstpts) || ismatrix(maskConstpts) || length(maskConstpts)<2 ...
      || ~isnumeric(maskConstpts) || (length(unique(maskConstpts)) ~= length(maskConstpts))
  err.msg = ['Signal constellation must be a vector of at least ' ...
             'two elements, representing the set of constellation points ' ...
             'that the modulator in the current model can generate.'];
  err.mmi = 'commblks:commblktcmdec:constPtsCheck';
  return
end        

% -- Check if the specified trellis works with chosen set of constellation 
if(maskTrellis.numOutputSymbols~=Mnum)
  err.msg = ['Trellis specified does not correspond to the chosen signal constellation set.'];
  err.mmi = 'comm:commblkpsktcmdec:MTrellisDimension'; 
  return
end

const = gentcmconstmapper(maskTrellis, maskConstpts);                       
constpts = complex(real(const),imag(const)); 

%-- Check constellation points: 
% Error out if empty, matrix, 1D vector, non-numeric or non-complex
if isempty(constpts) || ismatrix(constpts) || length(constpts)<2 ...
        || ~isnumeric(constpts) || isreal(constpts) ...
        || (length(unique(constpts)) ~= length(constpts))
    err.msg = ['Signal constellation must be a vector of at least ' ...
            'two elements, representing the set of constellation points ' ...
            'that the modulator in the current model can generate.'];
    err.mmi = 'commblks:commblktcmdec:constPtsCheck';
    return
end

% [EOF]            