function resp = read_registerobj(mm,index,timeout)
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

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $ $Date: 2003/11/30 23:10:43 $

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

resp = [];
autype = 'binary';
if nargin == 1, % Full read
    for i=1:mm.numberofstorageunits
        resp = horzcat(resp,regread(mm.link,mm.regname{i},autype,mm.timeout));
	end
    
elseif nargin == 3 & isempty(index),  % Full read
    for i=1:mm.numberofstorageunits
        resp = horzcat(resp,regread(mm.link,mm.regname{i},autype,mm.timeout));
	end

else    % indexed

    if nargin == 2,
         dtimeout = mm.timeout;
    else
         dtimeout = timeout;
    end
    
    for j=1:length(index)
        for i=1:mm.numberofstorageunits,
		    resp = horzcat(resp,regread(mm.link,mm.regname{i},autype,dtimeout));
		end
    end
    
end

% [EOF] read_registerobj.m