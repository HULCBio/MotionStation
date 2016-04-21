function varargout = dspblkrceps(varargin)
% DSPBLKRCEPS Mask dynamic dialog function for Real Cepstrum block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:58:32 $ $Revision: 1.6 $

if nargin==0   % For dynamic dialog callback, dspblkrceps is called with no arguments
    action = 'dynamic';
else
    action = varargin{1};  % 'init'
end

blk = gcb;

% Determine "Inherit FFT length" checkbox setting
inhFftStr = get_param(blk,'inheritFFT');


switch action
case 'dynamic'
    
    % Execute dynamic dialog behavior
    
    % Cache original dialog mask enables
    ena_orig = get_param(blk,'maskenables');
    ena = ena_orig;
    
    % Determine if FFT length edit box is visible
    iFFTedit = 2; fftEditBoxEnabled = strcmp(inhFftStr, 'off');
    
    % Map true/false to off/on strings, and place into visibilities array:
    enaopt = {'off','on'};
    ena([iFFTedit]) = enaopt([fftEditBoxEnabled]+1);
    if ~isequal(ena,ena_orig),
        % Only update if a change was really made:
        set_param(blk,'maskenables',ena);
    end
    
case 'init'
    
    % Execute Initialization-mode settings
    
    % Update the Zero Pad block underneath the top level
    if strcmp(inhFftStr, 'on'),
        set_param([blk '/Zero Pad'], 'zpadAlong', 'None');
    else
        set_param([blk '/Zero Pad'], 'zpadAlong', 'Columns');
    end
    
end

% [EOF] dspblkrceps.m
