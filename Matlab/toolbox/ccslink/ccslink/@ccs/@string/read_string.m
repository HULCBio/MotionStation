function resp = read_string(nn,index,timeout)
% Private. READ_STRING : reads a string of characters.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2003/11/30 23:12:56 $

error(nargchk(1,3,nargin));
if ~ishandle(nn),
    errid = generateccsmsgid('InvalidHandle');
    error(errid,'First Parameter must be a STRING handle.');
end

% Read numeric value(s) from memory
if nargin == 1,
    resp = read_numeric(nn);
    IsEmptyIndex = 1;
elseif nargin == 2,
    resp = read_numeric(nn,index); 
    IsEmptyIndex = isempty(index);
else
    resp = read_numeric(nn,index,timeout);
    IsEmptyIndex = isempty(index);
end

% Format numeric values
if length(nn.size) > 1 % reading a char/string matrix 
    if strcmp(nn.arrayorder,'row-major')
        for k = 1:size(resp,1)
            nullfound = find(resp(k,:)==0);
            temp = resp(k,:);
            if (~isempty(nullfound))
                resp(k,:) = temp(1:nullfound(1));
            end
        end
    else
        errid = generateccsmsgid('ReadingColMajorNotSupported');
        error(errid,'Reading from a character matrix is not supported for ''col-major'' arrays.');
    end
else % 1 dimensional string/char
    nullfound = find(resp==0);
    if ~isempty(nullfound),
        resp = resp(1:nullfound);
    elseif (isempty(nullfound) && prod(nn.size)~=1 && IsEmptyIndex)
        warnid = generateccsmsgid('NoNULLCharAtTheEnd');
        warnmsg = 'Character array does not end with a NULL character.';
        throwWarning(warnid,warnmsg);
    end
end

resp = checkforNonASCII(resp);

% Get ASCII character equivalent
resp = equivalent(nn,resp);

%-----------------------------------
function resp = checkforNonASCII(resp)
lessThanMin = find(resp<0);   % index of all values <0
moreThanMax = find(resp>127); % index of all values >127
if any(lessThanMin) || any(moreThanMax),
    % Saturate
    resp(lessThanMin) = 0;
    resp(moreThanMax) = 127;
    % Throw a warning
    warnid = generateccsmsgid('DataIsSaturated');
    warnmsg = 'Non-ASCII characters in the result are saturated. Use READNUMERIC to get the exact numeric values.';
    throwWarning(warnid,warnmsg);
end

% [EOF] read_string.m