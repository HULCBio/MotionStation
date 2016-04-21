function resp = write(nn,index,data)
%WRITE Writes data into DSP memory - 
%  WRITE(MM,DATA)
%  WRITE(MM,DATA,INDEX)
%  WRITE(MM,DATA,INDEX,TIMEOUT)
%  WRITE(MM,DATA,[],TIMEOUT)
%  
%   See also READ, WRITEBIN.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/11/30 23:10:31 $

error(nargchk(2,3,nargin));
if ~ishandle(nn),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a POINTER Handle.');
end
if nargin==2,   
    data = index;
elseif nargin==3 & isempty(index)
    index = 1;
end

if strcmp(nn.procsubfamily,'C55x'), % 23-bit check
    data = CheckValueIfWithinRange(nn,data);
end

if iscellstr(data) || ischar(data),
	if nargin == 2, write_numerichex(nn,data);
	else            write_numerichex(nn,index,data);
	end
    
elseif isnumeric(data),
	if nargin == 2, write_numeric(nn,data);
	else            write_numeric(nn,index,data);
	end

else
    errid = generateccsmsgid('DataMustBeNumericOrHexString');
    error(errid,'DATA must be a numeric array or a hexadecimal string (cell array) ');
end

%--------------------------------------
function data = CheckValueIfWithinRange(nn,data)
% If data pointer is in 'large memory mode', check if data is greater than
% 23-bits in value. If yes, throw an error.

ref = getprop(nn,'referent');
if isfield(ref,'uclass') && ~strcmp(ref.uclass,'function') && nn.wordsize==24,
    if isnumeric(data)
        greaterThanMax = (data>8388607); % 2^23-1
    elseif ischar(data) % hexadecimal
        greaterThanMax = (hex2dec(data)>8388607); % 2^23-1
    elseif iscellstr(data) % hexadecimal
        greaterThanMax = ([hex2dec(data)]>8388607); % 2^23-1
    else
        return;
    end
    if any(greaterThanMax)
        errid = generateccsmsgid('InvalidAddress');
        error(errid,'You are attempting to write an invalid address.');
    end
end

% [EOF] write.m