function x=bin2dec(s)
%BIN2DEC Convert binary string to decimal integer.
%   X = BIN2DEC(B) interprets the binary string B and returns in X the
%   equivalent decimal number.  
%
%   If B is a character array, or a cell array of strings, each row is
%   interpreted as a binary string. 
%   Embedded, significant spaces are removed. Leading spaces are converted to
%   zeros.
%
%   Example
%       bin2dec('010111') returns 23
%       bin2dec('010 111') also returns 23
%       bin2dec(' 010111') also returns 23
%
%   See also DEC2BIN, HEX2DEC, BASE2DEC.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.3 $  $Date: 2004/04/10 23:32:31 $

% handle input
if iscellstr(s) 
    s = char(s); 
end

if ~ischar(s) 
    error('MATLAB:bin2dec:InvalidInputClass','Input must be a string.'); 
end

if isempty(s)
    x = []; 
    return, 
end

if size(s,2)>52
    error('MATLAB:bin2dec:InputOutOfRange','Binary string must be 52 bits or less.'); 
end

% replace 0 with '0'
if ~isempty(find(s==0))
  s = strjust(s);
  s(s==0) = '0';
end

% replace leading spaces with '0'
i = 1;
lenS = length(s);
while (i<=lenS && s(i)==' ')
    s(i) = '0';
end

% remove significant spaces
for i = 1:size(s,1)
    spacesHere = s(i,:)==' ';
    if any(spacesHere)
        stmp = s(i,:);                                  % copy this row
        nrOfZeros=length(stmp(spacesHere));             % number zeros to prepend        
        stmp(spacesHere)='';                            % remove significant spaces
        stmp = [repmat('0',1,nrOfZeros) stmp];          % prepend '0' to pad this row
        s(i,:) = stmp;                                  % replace row
    else
        continue;
    end
end

% check for illegal binary strings
if any(any(~(s == '0' | s == '1')))
    error('MATLAB:bin2dec:IllegalBinaryString',...
        'Binary string may consist only of characters 0 and 1')
end

[m,n] = size(s);

% Convert to numbers
v = s - '0'; 
twos = pow2(n-1:-1:0);
x = sum(v .* twos(ones(m,1),:),2);
