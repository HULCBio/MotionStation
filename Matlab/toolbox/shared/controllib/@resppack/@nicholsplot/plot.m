function r = plot(this,w,varargin)
%PLOT  Adds data to a bode plot.
%
%   R = PLOT(NICPLOT,W,M,P) adds the frequency response data (W,M,P) to  
%   the Nichols plot NICPLOT.  W is the frequency vector, and M and P are
%   the magnitude and phase arrays (the size of their first dimension
%   must match the number of frequencies). The added response is drawn 
%   immediately.
%
%   R = PLOT(NICPLOT,W,H) specifies the complex frequency response H
%   rather than the magnitude and phase data.  
%
%   R = PLOT(NICPLOT,W,M,P,'Property1',Value1,...) further specifies 
%   data properties such as units. See the @magphasedata class for a list
%   of valid properties.
%
%   R = PLOT(NICPLOT,...,'nodraw') defers drawing.  An explicit call to
%   DRAW is then required to show the new response.  This option is useful 
%   to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:23 $

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
if ~isreal(w)
   error('The frequency points must be real valued.')
end
w = w(:);
nf = length(w);
if ni==3 | ischar(varargin{2})
   % Complex frequency response
   h = varargin{1};
   varargin = varargin(2:end);
   if prod(size(h))==nf
      h = h(:);
   end
   mag = abs(h);
   phase = unwrap(atan2(imag(h),real(h)),[],1);
else
   mag = varargin{1};
   phase = varargin{2};
   varargin = varargin(3:end);
   if prod(size(mag))==nf
      mag = mag(:);
      phase = phase(:);
   end
end
% Size checking
if size(mag,1)~=nf & size(mag,3)==nf
   % Accept frequency-last format
   mag = permute(mag,[3 1 2]);
   phase = permute(phase,[3 1 2]);
end
[nf2,ny,nu] = size(mag);
[nf3,ny2,nu2] = size(phase);
if nf2~=nf | nf3~=nf
   error('Number of samples in frequency vector and response data must agree.')
elseif ny2~=ny | nu2~=nu
   error('Sizes of magnitude and phase arrays must agree.')
elseif ~isreal(mag) | ~isreal(phase)
   error('Magnitude and phase data must be real valued.')
end
   
% Create new response
try
   r = this.addresponse(1:ny,1:nu,1);
catch
   rethrow(lasterror)
end

% Store data and set properties
r.Data.Frequency = w;
r.Data.Magnitude = mag;
r.Data.Phase = phase;
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