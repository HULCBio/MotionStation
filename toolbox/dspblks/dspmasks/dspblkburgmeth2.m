function varargout = dspblkburgmeth2(action)
% DSPBLKBURGMETH2 Mask dynamic dialog function for
% Burg Method power spectrum estimation block

% Copyright 1995-2002 The MathWorks, Inc.
% $Date: 2002/04/14 20:58:41 $ $Revision: 1.5 $

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
    inhOrdStr = get_param(blk,'inheritOrd');
    
    % Determine if FFT length edit box is visible
    iFFTedit = 4; fftEditBoxEnabled = strcmp(inhFftStr, 'off');
    iOrdEdit = 2; ordEditBoxEnabled = strcmp(inhOrdStr, 'off');
    
    % Map true/false to off/on strings, and place into visibilities array:
    enaopt = {'off','on'};
    ena([iFFTedit iOrdEdit]) = enaopt([fftEditBoxEnabled ordEditBoxEnabled]+1);
    if ~isequal(ena,ena_orig),
        set_param(blk,'maskenables',ena);
    end
    
    
case 'init'
    
    % Determine "Inherit FFT length" and "Inherit order" checkbox settings
    inhFft_check = get_param(blk,'inheritFFT');
    inhOrd_check = get_param(blk,'inheritOrd');

    magfft_blk    = [blk, '/Magnitude FFT'];
    burgarest_blk = [blk, '/Burg AR Estimator'];
    
    magfft_check = get_param(magfft_blk,'fftLenInherit');
    burgarest_check = get_param(burgarest_blk,'inheritOrder');
    
    changePending = ~( strcmp(inhFft_check, magfft_check) & ...
                       strcmp(inhOrd_check, burgarest_check) ...
                      );
    if changePending,
        set_param(magfft_blk,    'fftLenInherit', inhFft_check);  % INHERIT FFT LENGTH
        set_param(burgarest_blk, 'inheritOrder',  inhOrd_check);  % INHERIT ESTIMATION ORDER
    end

    
case 'icon'
    d = 0.1; xe=4; x=-xe:d:xe;
    y = ones(size(x)); i=find(x); y(i)=sin(pi*x(i))./(pi*x(i));
    y = abs(y).^(0.75);
    varargout = {xe,x,y};
    
end

% [EOF] dspblkburgmeth2.m
