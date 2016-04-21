function createmem(cc, startaddress, size)
% CREATEMEM (Private) Creates a scratch memory area where data can be
% stored temporarily. 
% CREATEMEM(CC,STARTADDRESS,SIZE) creates a scratch area in the DSP memory.
%  This area starts at address STARTADDRESS and its length is defined by
%  SIZE.
% The STARTADDRESS parameter can be specified in two ways. First, as a
%  numerical value which is a decimal representation of the DSP address.
%  Second, as a string which is interpreted as a hexadecimal representation
%  of the address offset.  (See HEX2DEC, which is used for the conversion
%  to a decimal value).  When STARTADDRESS is defined by a string, the
%  page is always derived from the CC object.  Thus, there is no method of  
%  explicitly defining the page when STARTADDRESS is passed as a
%  hexadecimal string. 
% 
% Examples of the STARTADDRESS parameter:
%  '1F'  Offset is decimal 31, with the page taken from CC.page
%  10  Offset is decimal 10, with the page taken from CC.page
%  [18,1]  Offset is decimal 18, with page equal to decimal 1
%
% SIZE is the size of the memory space requested to be allocated, size is 
%  specified in K words.
% 
% Example: Create a memory block that starts at address 0x400 and is 10
%  memory/address units long.
%  >> createmem(cc,'400',10)
% 	Stack Object: 
%       Stack area defined : start=0x400, length=0xA
%       Objects allocated  : 0
%       Top of stack       : 0x40A
%
% See also DELETEMEM.

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/06 01:04:42 $

if ~isempty(cc.stack.startaddress)
    error(sprintf(['A memory block is still defined. To create a new memory block, first\n',...
    'deallocate all objects and delete the defined memory using ''deletemem''.']));
end

% Determine procsubfamily
prosubfamily = getprocsubfamily(cc);
set(cc.stack, 'procsubfamily', prosubfamily);

% Parse startaddress
if ischar(startaddress)
    startaddress = [hex2dec(startaddress) 0];
elseif length(startaddress) == 1
    startaddress = [startaddress cc.page];
elseif length(startaddress) == 2
    startaddress = [startaddress(1) startaddress(2)];
else 
    error('Invalid address.');
end

% Parse size
if ischar(size)
    size = hex2dec(size);
end

% Determine endaddress
endaddress = startaddress(1) + size;

% Set Stack object's properties
set(cc.stack, 'startaddress', startaddress);
set(cc.stack, 'endaddress', endaddress);
set(cc.stack, 'size' , size);
set(cc.stack, 'storageUnitsLeft', cc.stack.size);
set(cc.stack, 'growsToLowAddr', stackGrowsToLowerAddress(cc.stack));
if cc.stack.growsToLowAddr
    % TOS starts at the end address
    set(cc.stack, 'topofstack', [endaddress startaddress(2)]);
else
    % TOS starts at the start address
    set(cc.stack, 'topofstack', startaddress);
end
set(cc.stack, 'toslist', cc.stack.topofstack(1));

% Display Stack info
stack = cc.stack

%-------------------------------------------
function resp = stackGrowsToLowerAddress(ccstack)
if strcmp(ccstack.procsubfamily,'C28x')
    % C28x stack grows to higher addresses
    resp = 0;
else
    resp = 1;
end
    
% [EOF] createmem.m