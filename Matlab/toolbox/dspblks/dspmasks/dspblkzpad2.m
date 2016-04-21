function dspblkzpad2(action, varargin)
% DSPBLKZPAD2 Signal Processing Blockset Zero Pad block helper function

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:07:48 $

% Cache current block
curBlk = gcb;

% Cache current block mask enables
cachedEnables   = get_param(curBlk,'maskenables');
newEnables      = cachedEnables;

padAlongWhatDim           = get_param(curBlk,'zpadAlong');
padAlongColNumOutRowsMode = get_param(curBlk,'padNumOutRowsSpecMethod');
padAlongRowNumOutColsMode = get_param(curBlk,'padNumOutColsSpecMethod');

% "Pad signal at" and "Pad along" parameters always enabled
newEnables{1} = 'on';
newEnables{2} = 'on';

% Disable all other parameters by default.
% Turn on individual parameters as needed.
newEnables{3} = 'off';
newEnables{4} = 'off';
newEnables{5} = 'off';
newEnables{6} = 'off';
newEnables{7} = 'off';

if ( ~strcmp(padAlongWhatDim, 'None') )
    % If pad along columns or pad along both,
    % then enable the num output rows specification
    % method popup parameter.
    if ( ~strcmp(padAlongWhatDim, 'Rows') )
    	newEnables{3} = 'on';
        if ( strcmp(padAlongColNumOutRowsMode, 'User-specified') )
            newEnables{4} = 'on'; % Enable specified num out rows parameter
            newEnables{7} = 'on'; % Enable truncation behavior parameter
        end
    end
    
    % If pad along rows or pad along both,
    % then enable the num output cols specification
    % method popup parameter.
    if ( ~strcmp(padAlongWhatDim, 'Columns') )
    	newEnables{5} = 'on';
        if ( strcmp(padAlongRowNumOutColsMode, 'User-specified') )
            newEnables{6} = 'on'; % Enable specified num out rows parameter
            newEnables{7} = 'on'; % Enable truncation behavior parameter
        end
    end
end

% Only update the block mask enables if they have changed
if ~(isequal(cachedEnables, newEnables))
    set_param(curBlk, 'maskenables', newEnables);
end

% [EOF] dspblkzpad2.m
