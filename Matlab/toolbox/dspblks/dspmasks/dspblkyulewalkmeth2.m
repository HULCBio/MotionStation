function varargout = dspblkyulewalkmeth2(action)
% DSPBLKYULEWALKMETH2 Mask dynamic dialog function for
% Yule-Walker Method power spectrum estimation block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:58:38 $ $Revision: 1.6 $

blk = gcb;
if nargin<1, action = 'dynamic'; end

switch action
case 'icon'
    d = 0.1; xe=4; x=-xe:d:xe;
    y = ones(size(x)); i=find(x); y(i)=sin(pi*x(i))./(pi*x(i));
    y = abs(y).^(0.75);
    varargout = {xe,x,y};
    
case 'dynamic'
    % Execute dynamic dialogs
    
    % Cache original dialog mask enables
    ena_orig = get_param(blk,'maskenables');
    ena = ena_orig;
    
    % Determine "Inherit FFT length" and "Inherit order" checkbox settings
    inhOrdStr = get_param(blk,'inheritOrd');
    inhFftStr = get_param(blk,'inheritFFT');
    
    % Determine if FFT length edit box is visible
    iOrdEdit = 2; ordEditBoxEnabled = strcmp(inhOrdStr, 'off');
    iFFTedit = 4; fftEditBoxEnabled = strcmp(inhFftStr, 'off');
    
    % Map true/false to off/on strings, and place into visibilities array:
    enaopt = {'off','on'};
    ena([iFFTedit iOrdEdit]) = enaopt([fftEditBoxEnabled ordEditBoxEnabled]+1);
    if ~isequal(ena,ena_orig),
        set_param(blk,'maskenables',ena);
    end
    
case 'init'
    % Execute side-effect behaviors
    % i.e., set_param to underlying blocks, etc.
    
    % Determine "Inherit FFT length" and "Inherit order" checkbox settings
    inhOrd_check = get_param(blk,'inheritOrd');
    inhFft_check = get_param(blk,'inheritFFT');
    
    % Determine names of underlying blocks:
    magfft_blk  = strcat(blk, '/Magnitude FFT');
    ywarest_blk = strcat(blk, '/Yule-Walker AR Estimator');
    
    % Get affected parameters of underlying blocks:
    ywarest_check = get_param(ywarest_blk,'inheritOrder'); % INHERIT ESTIMATION ORDER
    magfft_check  = get_param(magfft_blk,'fftLenInherit'); % INHERIT FFT LENGTH
    
    changePending_order = ~strcmp(inhOrd_check, ywarest_check);
    changePending_fft   = ~strcmp(inhFft_check, magfft_check);
    anyChangePending = changePending_fft | changePending_order;
    
    if anyChangePending,
        set_param(ywarest_blk, 'inheritOrder', inhOrd_check);
        set_param(magfft_blk, 'fftLenInherit', inhFft_check);
    end
end

% [EOF] dspblkyulewalkmeth2.m
