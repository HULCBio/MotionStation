function xx = calendar(c,m)
%CALENDAR Calendar.
%   CALENDAR or CALENDAR(DATE) or CALENDAR(YEAR,MONTH) is a 6-by-7
%   matrix containing a calendar for the current or specified month.
%
%   The first column of the returned matrix corresponds to Sunday.
%
%   See also DATENUM.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/15 03:20:34 $

if nargin == 0
   c = clock;
   c(3) = 1;
elseif nargin == 1
   c = datevec(c);
   c(3) = 1;
else
   if prod(size(c))~=1 | prod(size(m))~=1, 
     error('Y and M must be scalars.');
   end
   if m < 1 | m > 12, error('M must contain values between 1 and 12.'); end
   c = [fix(c) fix(m) 1];
end

% Determine the week day for first day of the month.
k = rem(fix(datenum(c(1),c(2),c(3)))+5,7)+1;

% Determine number of days in the month.
dpm = [31 28 31 30 31 30 31 31 30 31 30 31];
d = dpm(c(2));
if (c(2) == 2) & ...
  ((rem(c(1),4) == 0 & rem(c(1),100) ~= 0) |  rem(c(1),400) == 0)
%  Leap year February.
   d = 29;
end

% Fix in the matrix.
x = zeros(7,6);
x(k:k+d-1) = 1:d;
x = x';

if nargout==0,
  mths = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';
          'Aug';'Sep';'Oct';'Nov';'Dec'];
  mth = mths(c(:,2),:);
  yr = sprintf('%.0f',c(1)+10000);
  disp(sprintf('                   %s %s',mth,yr(2:5)))
  disp(        '     S     M    Tu     W    Th     F     S')
  disp(x)
else
  xx = x;
end
