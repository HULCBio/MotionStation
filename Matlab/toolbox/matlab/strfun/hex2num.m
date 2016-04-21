function x = hex2num(s)
%HEX2NUM Convert IEEE hexadecimal string to double precision number.
%   HEX2NUM(S), where S is a 16 character string containing
%   a hexadecimal number, returns the IEEE double precision
%   floating point number it represents.  Fewer than 16
%   characters are padded on the right with zeros.
%
%   If S is a character array, each row is interpreted as a double
%   precision number.
%
%   NaNs, infinities and denorms are handled correctly.  
%
%   Example:
%       hex2num('400921fb54442d18') returns Pi.
%       hex2num('bff') returns -1.
%
%   See also NUM2HEX, HEX2DEC, SPRINTF, FORMAT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.15.4.3 $  $Date: 2004/04/16 22:08:39 $

if iscellstr(s), s = char(s); end
if ~ischar(s)
    error('Input to hex2num must be a string.')
end
if isempty(s), x = []; return, end

[row,col] = size(s);
blanks = find(s==' '); % Find the blanks at the end
if ~isempty(blanks), s(blanks) = '0'; end % Zero pad the shorter hex numbers.

% Convert characters to numeric digits.
% More than 16 characters are truncated.
d = zeros(row,16);
d(:,1:col) = abs(lower(s)) - '0';
d = d + ('0'+10-'a').*(d>9);
neg = d(:,1) > 7;
d(:,1) = d(:,1)-8*neg;

if any(d > 15) | any(d < 0)
    error('Input string to hex2num should have just 0-9, a-f, or A-F.')
end

% Floating point exponent.
% e = 16*(16*(d(:,1)-4) + d(:,2)) + d(:,3) + 1;
e = 256*d(:,1) + 16*d(:,2) + d(:,3) - 1023;

% Floating point fraction.
sixteens = [16;256;4096;65536;1048576;16777216;268435456];
sixteens2 = 268435456*sixteens(1:6);
multiplier = 1./[sixteens;sixteens2];
f = d(:,4:16)*multiplier;

x = zeros(row,1);
% Scale the fraction by 2 to the exponent.
overinf = find((e>1023) & (f==0));
if ~isempty(overinf), x(overinf) = inf; end

overNaN = find((e>1023) & (f~=0));
if ~isempty(overNaN), x(overNaN) = NaN; end

underflow = find(e<-1022);
if ~isempty(underflow), x(underflow) = pow2(f(underflow),-1022); end

allothers = find((e<=1023) & (e>=-1022));
if ~isempty(allothers), x(allothers) = pow2(1+f(allothers),e(allothers)); end

negatives = find(neg);
if ~isempty(negatives), x(negatives) = -x(negatives); end
