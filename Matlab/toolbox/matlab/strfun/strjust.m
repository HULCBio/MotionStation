function t = strjust(s,justify)
%STRJUST Justify character array.
%   T = STRJUST(S) or T = STRJUST(S,'right') returns a right justified 
%   version of the character array S.
%
%   T = STRJUST(S,'left') returns a left justified version of S.
%
%   T = STRJUST(S,'center') returns a center justified version of S.
%
%   See also DEBLANK, STRTRIM.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:08:49 $

if nargin<2, justify = 'right'; end

if isempty(s), t = s; return, end

% Find non-pad characters
ch = (s ~= ' ' & s ~= 0);
[r,c] = find(ch);
[m,n] = size(s);

% Determine offset
switch justify
case 'right'
    [dum,offset] = max(fliplr(ch),[],2);
    offset =  offset - 1;
case 'left'
    [dum,offset] = max(ch,[],2);
    offset = 1 - offset;
case 'center'
    [dum,offsetR] = max(fliplr(ch),[],2);
    [dum,offsetL] = max(ch,[],2);
    offset = floor((offsetR - offsetL)/2);
end

% Apply offset to justify character array
newc = c + offset(r);
t = repmat(' ',m,n);
t(r + (newc-1)*m) = s(r + (c-1)*m);
