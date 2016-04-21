function d = hex2dec(h)
%HEX2DEC Convert hexadecimal string to decimal integer.
%   D = HEX2DEC(H) interprets the hexadecimal string H and returns in D the
%   equivalent decimal number.  
%  
%   If H is a character array or cell array of strings, each row is interpreted
%   as a hexadecimal string. 
%
%   EXAMPLES:
%       hex2dec('12B') and hex2dec('12b') both return 299
%
%   See also DEC2HEX, HEX2NUM, BIN2DEC, BASE2DEC.

%   Author: L. Shure, Revised: 12-23-91, CBM.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.17.4.3 $  $Date: 2004/04/10 23:32:37 $

if iscellstr(h), h = char(h); end
if isempty(h), d = []; return, end

% Work in upper case.
h = upper(h);

[m,n]=size(h);

% Right justify strings and form 2-D character array.
if ~isempty(find((h==' ' | h==0),1))
  h = strjust(h);

  % Replace any leading blanks and nulls by 0.
  h(cumsum(h ~= ' ' & h ~= 0,2) == 0) = '0';
else
  h = reshape(h,m,n);
end

% Check for out of range values
if any(any(~((h>='0' & h<='9') | (h>='A'&h<='F'))))
   error('MATLAB:hex2dec:IllegalHexadecimal',...
      'Input string found with characters other than 0-9, a-f, or A-F.');
end

sixteen = 16;
p = fliplr(cumprod([1 sixteen(ones(1,n-1))]));
p = p(ones(m,1),:);

d = h <= 64; % Numbers
h(d) = h(d) - 48;

d =  h > 64; % Letters
h(d) = h(d) - 55;

d = sum(h.*p,2);
