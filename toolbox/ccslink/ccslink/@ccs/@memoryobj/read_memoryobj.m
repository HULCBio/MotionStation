function resp = read_memoryobj(mm,index,timeout)
%READRAW Retrieves a block of DSP numeric values as integers.
%   DN = READ(MM)
%   DN = READ(MM,[],TIMEOUT) - reads the entire memory area specfied by MM.  The raw
%   data is returned as a column vector of unsigned integer values.  The return
%   type (uint8, uint16 or uint32), will be sufficently large to contain all
%   on the data reference by a single memory location (bitsperstorageunit).  The elements of 
%   the column vector represent sequential memory addresses. A new TIMEOUT value can 
%   be explicitly passed to temporarily modify the default timeout property of the
%   MM object.  
%
%   DN = READ(MM,INDEX) 
%   DN = READ(MM,INDEX,TIMEOUT) - read a subset of the memory values specified by the
%   memory object MM. For example, if INDEX is a scalar integer, the return value will be
%   the binary value from the memory location offset by INDEX-1.  INDEX is one-based and is
%   limited to the following range: (1<INDEX<MM.NUMBEROFSTORAGEUNITS).  If INDEX is a vector, each
%   entry will be taken as a memory offest, with the resulting output a vector of memory 
%   values read from each respective INDEX location.  A new TIMEOUT value can be
%   explicitly passed to temporarily modify the default timeout property of the MM object.  
%   
%  Memoryobj Properties
%   MM.ADDRESS - The first address of the defined memory area.
%   MM.BITSPERSTORAGEUNIT - The wordsize (bits) per address value.  For example, on byte-addressable
%   processors, this value will be 8.
%   MM.NUMBEROFSTORAGEUNITS - Number of addresses in this memory object.  
%  
%  Examples:
%   DSP Hex Memory dump (byte addressable):
%   0x0100 : 0A 1F 55 31 55 A2 00 BF E2 EE 09 9A FF 00 F1 3C 
%   0x0110 : 22 ....
%   
%   >get(mm) 
%       address: [64 0]
%        bitsperstorageunit: 8
%      numberofstorageunits: 5
%       ....
%   > mm.read
%   ans = 10    31    85    49    85
%   > mm.read(4)
%   ans = 85
%   > mm.read(2:4)
%   ans = 31    85    49
%
%   See also READ, WRITE, CAST, INT32.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $ $Date: 2004/04/08 20:46:25 $

error(nargchk(1,3,nargin));
if ~ishandle(mm),
    error('First Parameter must be a CCSDSP Handle.');
end

if mm.bitsperstorageunit <= 8, % (we've already applied rounding)
    autype = 'uint8';
elseif mm.bitsperstorageunit <= 16,
    autype = 'uint16';
elseif mm.bitsperstorageunit <= 32,
    autype = 'uint32';
else
    warning('Host computer does not natively support integer values > 32, data truncation likely')
    autype = 'uint32';
end

if nargin == 1, % Full read
    resp = read(mm.link,mm.address,autype,mm.numberofstorageunits,mm.timeout);
elseif nargin == 3 & isempty(index),
    resp = read(mm.link,mm.address,autype,mm.numberofstorageunits,timeout);
else    % index
    if nargin == 2,
         dtimeout = mm.timeout;
    else
         dtimeout = timeout;
    end
    index = reshape(index,1,[]);
    if(any(index < 1) | any(index >mm.numberofstorageunits)),
        error('INDEX exceeds region specified by memory object');
    end
    resp = [];
    for rboc = collapse(index),
        resp = horzcat(resp,read(mm.link,suoffset(mm,rboc(1)-1),autype,rboc(2),dtimeout));
    end
end

%-------------------------------------------
function blockfetch = collapse(array)
% Takes a vector of indices and collapses it into a seqeuence of consecutive block reads
% This step is taken to improve read efficiency.  Each row of the output is an index followed
% by a count, which indicates the number of consecutive indices.
%  For example:
%  Inputs = [ 1 2 3 4 10 11 12 55]
%  Output =
%      1    10  55
%      4    3   1
ib = 1;
blockfetch(1,ib) = array(1);
blockfetch(2,ib) = 1;
for elem = array(2:end)
    if elem == blockfetch(1,ib) + blockfetch(2,ib),
        blockfetch(2,ib) = blockfetch(2,ib)+1;
    else
        ib = ib+1;
        blockfetch(1,ib) = elem;
        blockfetch(2,ib) = 1;
    end
end

% [EOF] read_memoryobj.m