function Y = db(X,U,R)
%DB Convert to decibels.
%   DB(X) converts the elements of X to decibel units
%   across a 1 Ohm load.  The elements of X are assumed
%   to represent voltage measurements.
%
%   DB(X,U) indicates the units of the elements in X,
%   and may be 'power', 'voltage' or any portion of
%   either unit string.  If omitted, U='voltage'.
%
%   DB(X,R) indicates a measurement reference load of
%   R Ohms.  If omitted, R=1 Ohm.  Note that R is only
%   needed for the conversion of voltage measurements,
%   and is ignored if U is 'power'.
%
%   DB(X,U,R) specifies both a unit string and a
%   reference load.
%
%   Examples:
%   1) Convert 0.1 volt to dB (1 Ohm ref.)
%      db(.1)           % -20 dB
%
%   2) Convert sqrt(.5)=0.7071 volts to dB (50 Ohm ref.)
%      db(sqrt(.5),50)  % -20 dB
%
%   3) Convert 1 mW to dB
%      db(1e-3,'power') % -30 dB
%
%   See also DBM, ABS, ANGLE.

%   Author(s): D. Orofino
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:09:20 $

if nargin==1,
   % U='voltage'; R=1;
   X=abs(X).^2;
else
   if nargin==2,
      if ~ischar(U),
         R=U; U='voltage';
      else
         R=1;
      end
   end
   idx=strmatch(lower(U),{'power','voltage'});
   if length(idx)~=1,
      error(['Units must be ''power'' or ''voltage''.']);
   end
   if idx == 1,
      if any(X<0),
         error('Power cannot be negative.');
      end
   else
      X=abs(X).^2./R;
   end
end

% We want to guarantee that the result is an integer
% if X is a negative power of 10.  To do so, we force
% some rounding of precision by adding 300-300.

Y = (10.*log10(X)+300)-300;

% [EOF] db.m

