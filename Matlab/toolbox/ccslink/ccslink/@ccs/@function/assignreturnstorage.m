function ff = assignreturnstorage(ff,prop,locator)
% ASSIGNRETURNSTORAGE Assigns the location of a function's 'struct'/'union' 
%   output.
%   ASSIGNRETURNSTORAGE(FF,PROP,LOCATION) Assigns the location of the output
%   ff.outputvar to the location specified by PROP and LOCATION. PROP determines 
%   what LOCATION is and how the location of the output object is going to be set.
%
%   PROP can be 
%   a. 'handle'  - indicates that LOCATION is a memory object.
%                  The address assigned to the return object,
%                  ff.outputvar, is the 'address' property of the object
%                  LOCATION.
%   b. 'address' - indicates that LOCATION is the actual address value.
%                  The address assigned to the return object, ff.outputvar,
%                  is the value of LOCATION. LOCATION can be a hexadecimal
%                  or a numeric value.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $  $Date: 2003/11/30 23:08:12 $

nargchk(3,3,nargin);
if ~ishandle(ff)
    errid = generateccsmsgid('InvalidHandle');
    error(errid,'First parameter must be a FUNCTION handle.');
end
if ~ischar(prop)
    errid = generateccsmsgid('InvalidInput');
    error(errid,'Second parameter must be a string.');
end

if strcmp(ff.procsubfamily,'C6x'),
	if strcmp(prop,'address')
        locator = CheckAddressRange(ff.link,locator);
	end
    % PrepareFunctionStack(ff); % calls p_preparation(ff)
    ff = AssignC6x(lower(prop),ff,locator);
elseif ~isempty(strmatch(ff.procsubfamily,{'C54x','C28x','C55x'},'exact')),
    errid = generateccsmsgid('NotApplicable2Proc');
    error(errid,'You can only use ASSIGNRETURNSTORAGE to C6x functions with return type ''struct'' or ''union''. ');
else  
    errid = generateccsmsgid('ProcNotSupported');
    error(errid,'Processor not supported.');
end
    
%-------------------------------
function ff = AssignC6x(Prop,ff,locator)
if ~ff.is_return_struct,
    errid = generateccsmsgid('NotApplicable2Proc');
    error(errid,'Use ASSIGNRETURNSTORAGE only for C6x functions with return type ''struct'' or ''union''. ');
end
switch Prop
case 'address',
    addr = locator;
case 'handle',
    if ~ishandle(locator)
    errid = generateccsmsgid('InvalidInput');
    error(errid,'Third Parameter must be a handle.');
    end
    addr = locator.address;
otherwise
    errid = generateccsmsgid('InvalidOption');
    error(errid,['Input ''' Prop ''' is not supported. ']);
end

regwrite(ff.link,'A3',addr(1),'binary');
ff.outputvar.address = addr;
ff.returnstorage_assigned = 1;

%--------------------------------------------
function addr = CheckAddressRange(cc,addr)
if ischar(addr), % hex, change to numeric
    try 
        addr = hex2dec(addr); 
    catch  
        errid = generateccsmsgid('InvalidInput');
        error(errid,'Third parameter must be a valid hexadecimal string.') 
    end
elseif ~isnumeric(addr)
    errid = generateccsmsgid('InvalidInput');
    error(errid,'Third Parameter must be a numeric or string.');
end
if length(addr)==1,  
    addr(2) = 0;   
end
maxaddress = (2^32)-1;
if addr(1) > maxaddress
    errid = generateccsmsgid('InvalidAddress');
    error(errid,'ADDRESS parameter exceeds available address space.');
end

% [EOF] assignreturnstorage.m