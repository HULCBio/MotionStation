function r = plot(this,w,h,varargin)
%PLOT  Adds data to a bode plot.
%
%   R = PLOT(NYQPLOT,W,H) adds the frequency response data (W,H) to  
%   the Nyquist plot NYQPLOT.  W is the frequency vector, and H is
%   the complex frequency response (the size of its first dimension
%   must match the number of frequencies). The added response is drawn 
%   immediately.
%
%   R = PLOT(NYQPLOT,W,H,'Property1',Value1,...) further specifies 
%   data properties such as units. See the @freqdata class for a list
%   of valid properties.
%
%   R = PLOT(NYQPLOT,...,'nodraw') defers drawing.  An explicit call to
%   DRAW is then required to show the new response.  This option is useful 
%   to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:46 $

ni = nargin;
if ni<3
   error('Not enough input arguments.')
end

% Look for 'nodraw' flag
nargs = length(varargin);
varargin(strcmpi(varargin,'nodraw')) = [];
DrawFlag = (length(varargin)==nargs);

% Check data
% Frequency
if ~isreal(w) | ~isnumeric(h)
   error('The frequency response data must be specified as numeric arrays.')
end
w = w(:);
nf = length(w);
% Response
if prod(size(h))==nf
   h = h(:);
end
% Size checking
if size(h,1)~=nf & size(h,3)==nf
   % Accept frequency-last format
   h = permute(h,[3 1 2]);
end
[nf2,ny,nu] = size(h);
if nf2~=nf
   error('Number of samples in frequency vector and response data must agree.')
end
   
% Create new response
try
   r = this.addresponse(1:ny,1:nu,1);
catch
   rethrow(lasterror)
end

% Store data and set properties
r.Data.Frequency = w;
r.Data.Response = h;
if nf>0
   r.Data.Focus = [w(1) w(end)];
end
if length(varargin)
   set(r.Data,varargin{:})
end

% Draw new response
if DrawFlag
   draw(r)
end