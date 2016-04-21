function dspblkchksigattrbs()
% DSPBLKCHKSIGATTRBS Signal Processing Blockset Check Signal Attributes block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:06:08 $

% Cache away the current block settings
blk = gcb;
vis = get_param(blk, 'maskvisibilities');

% Get ready to set the new block settings
new_vis = vis;

% Based on the 4th ("Dimensionality") popup,
% set visibility of the 5th ("what kind?")
%
dim_check_method = get_param(blk, 'DimsCheckMethod');
if strcmp(dim_check_method, 'Ignore'),
    new_vis(5) = {'off'};
else
    new_vis(5) = {'on'};
end

% Based on the 6th ("Data type") popup,
% set visibility of the 7th ("what general kind?")
%
dtype_check_method = get_param(blk, 'DatatypeCheckMethod');
if strcmp(dtype_check_method, 'Ignore'),
    % Make general data type specifier and
    % other related popups invisible
    new_vis(7)  = {'off'};
    new_vis(8)  = {'off'};
    new_vis(9)  = {'off'};
    new_vis(10) = {'off'};
else
    % Make general data type specifier popup visible
    new_vis(7) = {'on'};
    
    % Set default related popups invisible for now.
    % Determine which one(s) need to be visible below.
    new_vis(8)  = {'off'};
    new_vis(9)  = {'off'};
    new_vis(10) = {'off'};

    % Based on general data type specifier popup in 7, enable or
    % disable appropriate additional specific data type specifier popup(s)
    dt_general = get_param(blk, 'DatatypeGeneral');
    switch (dt_general),
        case 'Floating-point',
            new_vis(8)  = {'on'};

        case 'Fixed-point',
            new_vis(9)  = {'on'};

        case 'Integer',
            new_vis(10) = {'on'};
    end % dt_general
end

% If anything has changed, then reset the mask visibilities
if ~isequal(new_vis, vis),
    set_param(blk, 'maskvisibilities', new_vis);
end

%[EOF] dspblkchksigattrbs.m