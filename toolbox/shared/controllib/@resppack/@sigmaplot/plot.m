function r = plot(this,w,sv,varargin)
%PLOT  Adds data to a bode plot.
%
%   R = PLOT(SIGPLOT,W,S) adds the singular value data (W,S) to  
%   the singular value plot SIGPLOT.  W is the frequency vector, and S is
%   the array of singular values (the size of its first dimension
%   must match the number of frequencies). The added response is drawn 
%   immediately.
%
%   R = PLOT(SIGPLOT,W,S,'Property1',Value1,...) further specifies 
%   data properties such as units. See the @sigmadata class for a list
%   of valid properties.
%
%   R = PLOT(SIGPLOT,...,'nodraw') defers drawing.  An explicit call to
%   DRAW is then required to show the new response.  This option is useful 
%   to render multiple responses all at once.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:17 $

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
   error('The frequency response data must be specified as numeric arrays.')
end
w = w(:);
nf = length(w);
% Singular values
[nr,nc] = size(sv);
if ~isreal(sv) | any(sv(:)<0)
   error('Singular values should be nonnegative real numbers.');
elseif nr~=nf
   if nc~=nf
      error('Number of singular values does not match number of frequency points.')
   else
      sv = sv.';
   end
end

% Create new response
try
   r = this.addresponse(1,1,1);
catch
   rethrow(lasterror)
end

% Store data and set properties
r.Data.Frequency = w;
r.Data.SingularValues = sv;
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