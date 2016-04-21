function gardner_masksetup(block)
%GARDNER_MASKSETUP Sets up the workspace variables for the Gardner Timing
%Recovery demo.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2003/06/23 04:36:36 $

Vals = get_param(block, 'maskvalues');
setfieldindexnumbers(block);

%--- Get Variables from mask 
% str is the parameter structure from the mask
str.M         = str2num(Vals{idxM});
str.tsym      = str2num(Vals{idxTsym});
str.g         = str2num(Vals{idxG});
str.snrdB     = str2num(Vals{idxSnrdB});
str.L         = str2num(Vals{idxL});
str.rollOff   = str2num(Vals{idxRollOff});
str.filtDelay = str2num(Vals{idxFiltDelay});
str.numSymb   = str2num(Vals{idxNumSymb});
str.numRuns   = str2num(Vals{idxNumRuns});

assignin('base', 'M',         str.M );
assignin('base', 'tsym',      str.tsym );
assignin('base', 'g',         str.g );
assignin('base', 'snrdB',     str.snrdB );
assignin('base', 'L',         str.L );
assignin('base', 'rollOff',   str.rollOff );
assignin('base', 'filtDelay', str.filtDelay );
assignin('base', 'numSymb',   str.numSymb );
assignin('base', 'R',         str.numRuns );
    
% [EOF]
