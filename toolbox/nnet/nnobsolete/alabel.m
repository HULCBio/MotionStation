function alabel(x,y,t,z)
%ALABEL Set axis labels and title.
%  
%  This function is obselete.
%  Use XLABEL, YLABEL, TITLE, and AXIS.

nntobsf('alabel','Use XLABEL, YLABEL, TITLE, and AXIS.')

%  
%  *WARNING*: ALABEL is undocumented as it may be altered
%  at any time in the future without warning.

% ALABEL(X,Y,T,Z)
%   X - X axis label (string).
%   Y - Y axis label (string).
%   T - Title of axis (string).
%   Z - Z axis label (string).
% Labels current axis with xlabel X, ylabel Y and title T.
%
% ALABEL may be called with from 0 to 3 arguments.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:13:44 $

n = nargin;
if n == 0
  x = 'Wavelength';
  y = 'Decay rate';
  t = 'Foobar Decay Rates';
  n = 3;
end

xlabel(x)
if n >= 2, ylabel(y), end
if n >= 3, title(t), end
if n == 4, zlabel(z), end
