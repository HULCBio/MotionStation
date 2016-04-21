function d = base2dec(h,b)
%BASE2DEC Convert base B string to decimal integer.
%   BASE2DEC(S,B) converts the string number S of base B into its 
%   decimal (base 10) equivalent.  B must be an integer
%   between 2 and 36. 
%
%   If S is a character array, each row is interpreted as a base B string.
%
%   Example
%      base2dec('212',3) returns 23
%
%   See also DEC2BASE, HEX2DEC, BIN2DEC.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.3 $  $Date: 2004/04/10 23:32:30 $

%   Douglas M. Schwarz, 18 February 1996

error(nargchk(2,2,nargin));

if iscellstr(h), h = char(h); end
if isempty(h), d = []; return, end

if ~isempty(find(h==' ' | h==0)), 
  h = strjust(h);
  h(h==' ' | h==0) = '0';
end

[m,n] = size(h);
bArr = [ones(m,1) cumprod(b(ones(m,n-1)),2)];
values(real('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')) = 0:35;
if any(any(values(h) >= b))
    error('MATLAB:BASE2DEC:NumberOutsideRange',...
        'String %s contains characters which can not be converted to base %d', h,b);
end
a = fliplr(reshape(values(abs(upper(h))),size(h)));
d = sum((bArr .* a),2);
