function this = pseudospectrum(varargin)
%PSEUDOSPECTRUM   Pseudospectrum.
%   H = DSPDATA.PSEUDOSPECTRUM(DATA) instantiates an object H with its
%   data property set to DATA. The frequency vector defaults to [0, pi),
%   and Fs defaults to "Normalized".  DATA can be a vector or a matrix
%   where each column represents an independent trial.
%
%   H = DSPDATA.PSEUDOSPECTRUM(DATA,FREQUENCIES) sets the frequency vector
%   to FREQUENCIES in the object.  The length of the vector FREQUENCIES
%   must equal the length of the columns of DATA.
%
%   H = DSPDATA.PSEUDOSPECTRUM(...,'Fs',Fs) sets the sampling frequency to
%   Fs.  If FREQUENCIES is not specified, the frequency vector defaults to
%   [0, Fs/2] for even length data and  [0, Fs/2) for odd length data.  See
%   the NOTE below for more details.
%
%   H = DSPDATA.PSEUDOSPECTRUM(...,'SpectrumRange',SPECTRUMRANGE) sets the
%   SpectrumRange property to the string in SPECTRUMRANGE, which can be
%   either 'half' or 'whole'.
%
%   H = DSPDATA.PSEUDOSPECTRUM(...,'CenterDC',true) shifts the
%   zero-frequency component to the center of a spectrum calculated over
%   the whole Nyquist interval.  If the object's SpectrumRange property is
%   set to 'half', it's changed to 'whole' and the data is converted to a
%   whole spectrum.
%   
%   Setting the CenterDC property to false shifts the data and the
%   frequency values in the object, so that DC is in the left edge of the
%   spectrum.  This operation does not effect the SpectrumRange property.
%
%   NOTE: If the spectrum data specified was calculated over "half" the
%   Nyquist interval and you don't specify a corresponding frequency
%   vector, then the default frequency vector will assume that the number
%   of points in the "whole" FFT was even.  Also, the plot option to
%   convert to a "whole" spectrum will assume the original "whole" FFT
%   length was even.
%
%   EXAMPLE: Use eigenanalysis to estimate the pseudospectrum of a noisy
%            sinusoidal signal with two frequency components. Then store
%            the results in a PSEUDOSPECTRUM data object and plot it.
%
%        Fs = 32e3;   t  = 0:1/Fs:2.96; 
%        x = cos(2*pi*t*1.24e3) + cos(2*pi*t*10e3) + randn(size(t)); 
%        P = pmusic(x,4);
%        hps = dspdata.pseudospectrum(P,'Fs',Fs); % Create the data object.
%        plot(hps);                               % Plot the pseudospectrum.
%
%   See also DSPDATA/PSD, DSPDATA/MSSPECTRUM, SPECTRUM/PERIODOGRAM, 
%   DSPDATA/PLOT, DSPDATA/NORMALIZEFREQ.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/25 23:06:48 $

% Help for instantiating a PSEUDOSPECTRUM object.

% [EOF]
