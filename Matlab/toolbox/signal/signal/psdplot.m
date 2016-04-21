function psdplot(varargin)
%PSDPLOT Plot Power Spectral Density (PSD) data.
%   PSDPLOT(Pxx,W) plots the PSD, Pxx, computed at the frequencies
%   specified in W (in radians/sample).
%   
%   PSDPLOT(Pxx,W,UNITS) specifies the frequency (x-axis) units for the plot.
%   UNITS can be either 'RAD/SAMPLE' (default) or 'Hz'.
%
%   PSDPLOT(Pxx,W,UNITS,YSCALE), where YSCALE can be either 'LINEAR' or 'DB',
%   specifies the scaling of the Y-axis for the PSD plot.
%
%   PSDPLOT(Pxx,W,UNITS,YSCALE,TITLESTRING) will use the specified string for
%   the title of the plot.
%
%   NOTE: The PSDPLOT function is OBSOLETE. To plot spectrum data use the
%         new DSP data objects. With these objects you can plot Power
%         Spectral Density or Power Spectrum data, and specify data units
%         and frequency units. Type help dspdata/psd or dspdata/ps for
%         details and an example.
%
%   See also DSPDATA/PSD, DSPDATA/PS, SPECTRUM/PERIODOGRAM, SPECTRUM/WELCH,
%   SPECTRUM/MTM, SPECTRUM/MUSIC, SPECTRUM/EIGENVECTOR, SPECTRUM/BURG,
%   SPECTRUM/COV, SPECTRUM/MCOV, SPECTRUM/YULEAR.

%   Author(s): R. Losada 
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/13 00:18:57 $ 

error(nargchk(2,5,nargin));

% Obselete in R14.
warnStr = sprintf(['PSDPLOT is obsolete and will be removed in future versions.\n',...
    'Use the PSD data object instead, type help dspdata/psd.']);
warning(generatemsgid('obseleteFunction'), warnStr);

[inparg,msg] = parseinput(varargin{:});
error(msg);

data = psdplotsetup(inparg); % Generate the plot data

newplot;

plot(data.freq,data.mag);
ax = gca;
xlabel(data.freqlabel);
ylabel(data.maglabel);
title(inparg.titlestring)
axes(ax(1)); % Always bring the plot to the top
set(ax,'xgrid','on','ygrid','on','xlim',data.freqlim);

%-------------------------------------------------------------------------------
function [inparg,msg] = parseinput(varargin)
%PARSEINPUT   Setup a structure INPARG with the input args parsed.
%   INPARG is a structure which contains the following fields:
%   INPARG.w           - Frequency vector
%   INPARG.Pxx         - Power Spectral Density
%   INPARG.units       - Frequency units 'rad/sample' or 'Hz'
%   INPARG.yscale      - 'db' or 'linear'
%   INPARG.TITLESTRING - Title for the plot 

inparg.Pxx = varargin{1};
inparg.w = varargin{2};

% Generate defaults
inparg.units  = 'rad/sample';
inparg.yscale = 'db';
inparg.titlestring = '';
msg = '';

if nargin > 2,
   
   inparg.units = varargin{3};
   if isempty(strmatch(lower(inparg.units),{'rad/sample','hz'})),
      msg = 'Units must be either in ''Hz'' or in ''rad/sample''.'; 
      return
   end
   
   if nargin > 3,
      
      inparg.yscale = varargin{4};
      if isempty(strmatch(lower(inparg.yscale),{'db','linear','squared'})),
         msg = 'Can only plot in ''LINEAR'' scale or in ''DB'' scale.';
         return
      end
      
      if nargin > 4,
         inparg.titlestring = varargin{5};
      end
   end
end
%-------------------------------------------------------------------------------
function data = psdplotsetup(inparg);
%PLOTSETUP   Setup arguments to plot with PSDPLOT.
%   PLOTSETUP returns a structure DATA to be used with PSDPLOT
%   with the following fields:
%   DATA.FREQ       = wplot (Frequency data)
%   DATA.FREQLABEL  = xlab  (Frequency axis --x axis-- label)
%   DATA.FREQLIM    = xlim  (Frequency axis --x axis-- limits)
%   DATA.MAG        = Pxx   (Magnitude data (possibly in dB))
%   DATA.MAGLABEL   = ylab  (Magnitude label)

Pxx = inparg.Pxx;
w = inparg.w;

% Generate the correct labels
if strmatch(lower(inparg.units),'rad/sample'),
   xlab = 'Normalized Frequency  (\times\pi rad/sample)';
   w = w./pi;
   ylabend = '/ rad/sample)';
elseif strmatch(lower(inparg.units),'hz')
   xlab = 'Frequency (Hz)';
   ylabend = '/Hz)';
end
   
% Scale the psd correctly
if strmatch(lower(inparg.yscale),'db'),
   Pxx = db(Pxx,'power');
   ylab = ['Power Spectral Density (dB' ylabend];
elseif strmatch(lower(inparg.yscale),{'linear','squared'}), % 'squared' is allowed 
                                                            % for backwards compat.
   ylab = ['Power Spectral Density (Power' ylabend];
end
   
data.freq = w;
data.freqlabel = xlab;
data.freqlim = [w(1) w(end)];
data.mag = Pxx;
data.maglabel = ylab;

% [EOF] psdplot.m

