function varargout = dspblkcovarmeth2(action)
% DSPBLKCOVARMETH2 Mask dynamic dialog function for
% Covariance Method power spectrum estimation block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:58:44 $ $Revision: 1.5 $

blk = gcb;
if nargin<1, action='dynamic'; end

switch action
    
case 'dynamic'
    
    % Execute dynamic dialogs
    
    % Cache original dialog mask enables
    ena_orig = get_param(blk,'maskenables');
    ena = ena_orig;
    
    % Determine "Inherit FFT length" and "Inherit order" checkbox settings
    inhFftStr = get_param(blk,'inheritFFT');
    
    % Determine if FFT length edit box is visible
    iFFTedit = 3; fftEditBoxEnabled = strcmp(inhFftStr, 'off');
    
    % Map true/false to off/on strings, and place into visibilities array:
    enaopt = {'off','on'};
    ena([iFFTedit]) = enaopt([fftEditBoxEnabled]+1);
    if ~isequal(ena,ena_orig),
        % Only update if a change was really made:
        set_param(blk,'maskenables',ena);
    end

    
case 'init'
    % Determine "Inherit FFT length" checkbox setting
    inhFft_check = get_param(blk,'inheritFFT');
    magfft_blk   = [blk, '/Magnitude FFT'];
    magfft_check = get_param(magfft_blk,'fftLenInherit');
    
    changePending = ~strcmp(inhFft_check, magfft_check);
    if changePending,
        set_param(magfft_blk, 'fftLenInherit', inhFft_check);
    end
    
    
case 'icon'
    d = 0.1; xe=4; x=-xe:d:xe;
    y = ones(size(x)); i=find(x); y(i)=sin(pi*x(i))./(pi*x(i));
    y = abs(y).^(0.75);
    varargout = {xe,x,y};
    
end

% [EOF] dspblkcovarmeth2.m
