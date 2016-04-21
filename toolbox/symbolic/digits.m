function r = digits(d)
%DIGITS Set Maple's Digits.
%   Digits determines the accuracy of Maple's numeric computations.
%   DIGITS, by itself, displays the current setting of Digits.
%   DIGITS(D) sets Digits to D for subsequent calculations. D is an 
%      integer, or a string or sym representing an integer.
%   D = DIGITS returns the current setting of Digits. D is an integer.
%
%   See also VPA.

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/15 03:12:57 $

if nargin == 1
   if ~isstr(d), d = int2str(d); end;
   maple(['Digits := ', d]);
elseif nargout == 1
   r = eval(maple('Digits;'));
else
   disp(' ');
   disp(['Digits = ' maple('Digits')])
   disp(' ');
end
