function r = plot(this,t,y,varargin)
%PLOT  Adds data to a response plot.
%
%   R = PLOT(TIMEPLOT,T,Y) adds the response data (T,Y) to the 
%   time plot TIMEPLOT.  The response is drawn immediately.
%
%   R = PLOT(TIMEPLOT,T,Y,'Property1',Value1,...) further specifies 
%   data properties such as units. See the @timedata class for a list of 
%   valid properties.
%
%   R = PLOT(TIMEPLOT,T,Y,...,'nodraw') defers drawing.  An 
%   explicit call to DRAW is then required to show the new response. 
%   This option is useful to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:08 $

if nargin<3
   error('Not enough input arguments.')
end

% Look for 'nodraw' flag
nargs = length(varargin);
varargin(strcmpi(varargin,'nodraw')) = [];
DrawFlag = (length(varargin)==nargs);

% Check data
% Time vector
if ~isreal(t) | ~isreal(y)
   error('Time and amplitude data must be real valued.')
end
t = t(:);
ns = length(t);
% Amplitude
if prod(size(y))==ns
   y = y(:);
end
[ns2,ny,nu] = size(y);
if ns2~=ns
   error('Number of samples in time vector and amplitude data must agree.')
end

% Create new response
try
   r = this.addresponse(1:ny,1:nu,1);
catch
   rethrow(lasterror)
end

% Store data and set properties
r.Data.Time = t;
r.Data.Amplitude = y;
if ns>0
   r.Data.Focus = [t(1) t(end)];
end
if length(varargin)
   set(r.Data,varargin{:})
end

% Draw new response
if DrawFlag
   draw(r)
end