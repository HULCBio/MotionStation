function timezplot(t,h,Fs,tstr)
%TIMEZPLOT Plot the time response data
%   TIMEZPLOT(T,H,FS,TITLE) Plot the time response represented by the time
%   vector T and the response vector H.  FS is the sampling frequency and
%   defaults to 1.  TITLE is the prefix to ' Response' for the axes title
%   and defaults to ''.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $ $Date: 2004/04/13 00:18:53 $

error(nargchk(2,4,nargin));

if nargin < 3, Fs   = 1; end
if nargin < 4, tstr = ''; end

plotimag = any(~isreal(h));
if plotimag,
    subplot(2,1,1);
    ylbl = 'Real';
else
    ylbl = '';
end

if Fs == 1, xlbl = 'n (samples)';
else,       xlbl = 'nT (seconds)'; end

lclstem(t, real(h), xlbl, ylbl);
title(sprintf('%s Response', tstr));

if plotimag,
    subplot(2,1,2);
    lclstem(t, imag(h), xlbl, 'Imaginary');
end

% Set the figure's next plot to replace to match the functionality of
% freqz.  This is necessary so subsequent plots to the figure replace
% both axes for the complex case.
set(gcf,'nextplot','replace');   


% -----------------------------------------------------------
function lclstem(t, h, xlbl, ylbl)

stem('v6',t,h,'filled');

xlabel(xlbl); 
ylabel(sprintf('%s Amplitude', ylbl));

xlimits = [t(1) t(end)];
if ~isequal(xlimits(1), xlimits(2)),
    set(gca,'xlim',xlimits);
end

