function resp = readhex(nn,index,timeout)
%READHEX Retrieves a block of DSP memory as hexadecimal strings.
%   DN = READHEX(NN)
%   DN = READHEX(NN,[],TIMEOUT)
%   DN = READHEX(NN,INDEX)
%   DN = READHEX(NN,INDEX,TIMEOUT)
%
%   HS = READHEX(NN) - returns a hex representation of the DSP's numeric 
%   values.  For arrays, the returned values will be a cell array
%   of hex strings.  Conversely, if NN.SIZE equals 1,
%   (indicating a scalar), the output is an array of hex characters. 
%
%   DN = READHEX(NN,TIMEOUT) - The time alloted to perform the read is 
%   limited  by the NN.TIMEOUT property of the NN object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, CAST, NUMERIC.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2003/11/30 23:06:38 $

error(nargchk(1,3,nargin));
if nargin == 1,
    resp = readbin(nn);
elseif nargin == 2, % index only (1 value)
    resp = readbin(nn,index);
elseif nargin == 3 & isempty(index),
    resp = readbin(nn);
elseif nargin == 3 & ~isempty(index),
    resp = readbin(nn,index);
else
    resp = readbin(nn,index,timeout);
end
resp = reshape(cellstr(dec2hex(bin2dec(resp))),size(resp));

% [EOF] readhex.m
