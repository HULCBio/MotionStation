function data = readhex(nn,index,timeout)
%READ2HEX Retrieves a block of DSP memory as hexadecimal strings.
%   DN = READ2HEX(NN)
%   DN = READ2HEX(NN,[],TIMEOUT)
%   DN = READ2HEX(NN,INDEX)
%   DN = READ2HEX(NN,INDEX,TIMEOUT)
%
%   HS = READ2HEX(NN) - returns a hex representation of the DSP's numeric 
%   values.  For arrays, the returned values will be a cell array
%   of hex strings.  Conversely, if NN.SIZE equals 1,
%   (indicating a scalar), the output is an array of hex characters. 
%
%   DN = READ2HEX(NN,TIMEOUT) - The time alloted to perform the read is 
%   limited  by the NN.TIMEOUT property of the NN object.  However, 
%   this method can be used to explicitly define a different timeout
%   for the read.  For example, this may be necessary for very large 
%   data transfers.
%  
%   See also WRITE, READ, CAST, NUMERICMEM.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2003/11/30 23:11:44 $

error(nargchk(1,3,nargin));

% Read binary format
if nargin==1 || (nargin==2 && isempty(index)), % read all
    data = readbin(nn); 
elseif nargin==2, % index only (one value)
    data = readbin(nn,index);
elseif nargin==3 && isempty(index), % all but timeout specified
    data = readbin(nn,[],timeout);
else
    data = readbin(nn,index,timeout); % all inputs specified
end

% Change into hexadecimal format
siz = size(data);
nvalues = prod(siz);
for i=1:nvalues
    data{i} = ConvertBinDataToHex(data{i});
end
    

%-----------------------------------------------------
function data = ConvertBinDataToHex(data)
idx = find(data=='1');
data = data(idx:end);
if length(data)<=50,
    data = [dec2hex(bin2dec(data))];
else  
    % if too long - converting data to dec to hex will result to incorrect conversion - bin2dec limitation
    % therefore, split into 2 and then concatenate
    data = [ConvertBinDataToHex(data(1:end-32)) , dec2hex(bin2dec(data(end-31:end)),8)];
end
if isempty(data)
    data = '0';
end

% [EOF] readhex.m