function m=str2rng(str)
%STR2RNG Convert spreadsheet range string to numeric array.
%   M = STR2RNG(RNG) converts a range in spreadsheet notation into a
%   numeric range M = [R1 C1 R2 C2].  
%
%   Example
%      str2rng('A2..AZ10') returns the vector [1 0 9 51]
%
%   See also XLSWRITE, XLSREAD, WK1WRITE, WK1READ.

%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2004/03/26 13:26:34 $

if ~isstr(str), error('RNG must be a string.'); end

m = [];

% convert to upper case
str = upper(str);

% parse the upper-left and bottom-right cell locations
k = findstr(str,'..');
if length(k)~=1, return; end % Couldn't find '..'

ulc = str(1:k-1);
brc = str(k+2:end);

% get upper-left col
k = min(find(~isletter(ulc)));
if isempty(k) | k<2, return; end
topl(2) = sum(cumprod([1 26*ones(1,k-2)]).*(ulc(k-1:-1:1)-'A'+1))-1;
topl(1) = str2double(ulc(k:end))-1;

% get bottom-right col
k = min(find(~isletter(brc)));
if isempty(k) | k<2, return; end
botr(2) = sum(cumprod([1 26*ones(1,k-2)]).*(brc(k-1:-1:1)-'A'+1))-1;
botr(1) = str2double(brc(k:end))-1;

m=[topl botr];
