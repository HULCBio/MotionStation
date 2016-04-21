function S = num2hex(X)
%NUM2HEX Convert singles and doubles to IEEE hexadecimal strings.
%   If X is a single or double precision array with n elements,
%   NUM2HEX(X) is an n-by-8 or n-by-16 char array of the hexadecimal
%   floating point representation.  The same representation is printed
%   with FORMAT HEX.
%
%   Examples:
%
%      num2hex([1 0 0.1 -pi Inf NaN]) is
%      3ff0000000000000
%      0000000000000000
%      3fb999999999999a
%      c00921fb54442d18
%      7ff0000000000000
%      fff8000000000000
%
%      num2hex(single([1 0 0.1 -pi Inf NaN])) is
%      3f800000
%      00000000
%      3dcccccd
%      c0490fdb
%      7f800000
%      ffc00000
%
%   See also HEX2NUM, DEC2HEX, FORMAT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:08:43 $
n = numel(X);
d = '0123456789abcdef';
if ~isreal(X)
   error('MATLAB:num2hex:realInput','Input must be real.')
end
if isa(X,'double')
   S = char(zeros(n,16));
   for k = 1:n
      x = X(k);
      if isnan(x)
         s = 'fff8000000000000';
      elseif isinf(x) & x > 0
         s = '7ff0000000000000';
      elseif isinf(x) & x < 0
         s = 'fff0000000000000';
      elseif x == 0
         s = '0000000000000000';
      else
         s = blanks(16);
         if abs(x) < realmin
            e = 0;
            f = 16*abs(x)/realmin;
         else
            [f,e] = log2(abs(x));
            e = e+1022;
            f = 32*(f-.5);
         end
         if x > 0
            s(1) = d(floor(e/256)+1);
         else
            s(1) = d(floor(e/256)+9);
         end
         s(2) = d(floor(rem(e,256)/16)+1);
         s(3) = d(rem(e,16)+1);
         for j = 4:16
            s(j) = d(floor(f)+1);
            f = 16*rem(f,1);
         end
      end
      S(k,:) = s;
   end
elseif isa(X,'single')
   S = char(zeros(n,8));
   for k = 1:n
      x = X(k);
      if isnan(x)
         s = 'ffc00000';
      elseif isinf(x) & x > 0
         s = '7f800000';
      elseif isinf(x) & x < 0
         s = 'ff800000';
      elseif x == 0
         s = '00000000';
      else
         s = blanks(8);
         if abs(x) < realmin('single')
            e = 0;
            f = 8*abs(x)/realmin('single');
         else
            [f,e] = log2(abs(x));
            e = e+126;
            f = 16*(f-.5);
         end
         if x > 0
            s(1) = d(floor(e/32)+1);
         else
            s(1) = d(floor(e/32)+9);
         end
         s(2) = d(floor(rem(e,32)/2)+1);
         s(3) = d(8*rem(e,2)+floor(f)+1);
         for j = 4:8
            f = 16*rem(f,1);
            s(j) = d(floor(f)+1);
         end
      end
      S(k,:) = s;
   end
else
   error('MATLAB:num2hex:floatpointInput','Inputs must be floating point, and may not be of class %s.',class(X))
end
