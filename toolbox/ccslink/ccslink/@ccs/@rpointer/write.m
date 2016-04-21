function resp = write(rr,index,data)
%WRITE Writes data into DSP memory - 
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2003/11/30 23:12:07 $

error(nargchk(2,3,nargin));
if ~ishandle(rr),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a RPOINTER Handle.');
end
if nargin==2,   
    data = index;
elseif nargin==3 & isempty(index)
    index = 1;
end

if strcmp(rr.procsubfamily,'C55x'), % 23-bit check
    data = CheckValueIfWithinRange(rr,data);
end

if iscellstr(data) | ischar(data),
	if nargin == 2,
        write_rnumerichex(rr,data);
	else
        write_rnumerichex(rr,index,data);
	end
elseif isnumeric(data),
	if nargin == 2,
        write_rnumeric(rr,data);
	else
        write_rnumeric(rr,index,data);
	end
else
    errid = generateccsmsgid('DataMustBeNumericOrHexString');
    error(errid,'Input must be a numeric array or hexadecimal string array ');
end

%--------------------------------------
function data = CheckValueIfWithinRange(rr,data)
% If data pointer is in 'large memory mode', check if data is greater than
% 23-bits in value. If yes, throw an error.

ref = getprop(rr,'referent');
if isfield(ref,'uclass') && ~strcmp(ref.uclass,'function') && rr.wordsize==24,
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