function varargout = dspblkupfir(action,varargin)
% DSPBLKUPFIR Mask dynamic dialog function for FIR interpolation block


% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:55:19 $ $Revision: 1.10 $

blk = gcb;    % Cache handle to block

if nargin==0
    action = 'dynamic';   % mask callback
end

% Get the value of the checkbox for frame-based
frame_based = get_param(blk, 'frame');

switch action
case 'dynamic'
    % Execute dynamic dialogs    
    % Get status of frame checkbox
    mask_enables = get_param(blk,'maskenables');
    mask_enables{4} = frame_based;
    mask_enables{5} = frame_based;
    set_param(blk,'maskenables',mask_enables);
    
case 'setup1'
    % Initialize the str output variable in case the 'setup2' call
    % errors out (i.e. when the inputs are empty).
    % This displays a default icon.
    
    str = ['x[?]'];
    % Denote Frame-based if appropriate and set numChans
    if (strcmp(frame_based,'on'))
        numChans = varargin{1};
    else
        numChans = -1; 
    end
    
    % Gather up outputs
    varargout{1} = str;
    varargout{2} = numChans;
    
case 'setup2'
    % Input arguments for setup case:
    % dspblkupfir('setup', h,L,framing)
    
    h = varargin{1};
    L = varargin{2};
    framing = varargin{3};

    [M,N] = size(h);
    if (M ~= 1 & N ~= 1)
        error('The filter coefficients must be a non-empty vector');
    end
    if (isempty(L) | L < 1 | fix(L) ~= L)
        error('Interpolation factor must be a positive integer');
    end
    % Need to reshuffle the coefficients into phase order
    len = length(h);
    if (rem(len, L) ~= 0)
        nzeros = L - rem(len, L);
        h = [h(:); zeros(nzeros,1)];
    end
    len = length(h);
    nrows = len / L;
    % Re-arrange the coefficient and gain-scale
    h = L * reshape(h, L, nrows).'; 
    
    if (strcmp(frame_based,'off'))
        % Constant size framing method ("1") is sample-based default
        framing = 1;
    end
    
    str=['x[n/' num2str(L) ']'];
    
    % Gather up outputs
    varargout = {h,framing,str};
    
otherwise
    error('unhandled case');
end

% end of dspblkupfir.m
