function regwrite(cc,regname,value,represent,timeout)
%REGWRITE Writes a data value into the specified DSP register.
%   REGWRITE(CC, REGNAME, VALUE, REPRESENT, TIMEOUT) write the data 
%   from the VALUE parameter into in the specified register of the 
%   DSP processor.  The REGNAME parameter defines the destination 
%   register.  This operation is directed to the the processor 
%   referenced by the CC object.  The REPRESENT parameter specifies the 
%   interpretation of the register's data format.
%
%   REPRSENT - Representation of data in destination register
%   '2scomp' - (default) 2's complement signed integer
%   'binary' - Unsigned binary integer 
%   'ieee'   - IEEE floating point (32 and 64 bit registers, only)
%  
%   VALUE can be any scalar numeric value.   Note, the data type of the
%   this parameter does not effect the representation of the destination 
%   register. VALUE is automatically converted to the destination type, 
%   which in some cases may produce data loss.
%
%   TIMEOUT defines an upper limit (in seconds) on the time this method will wait
%   for completion of the write.  If this period is exceeded, this method will
%   immediately return with a timeout error.  In general, a timeout will not stop
%   the actual register write, but simply terminate waiting for a Code Composer 
%   response that indicates completion.  
%
%   REGWRITE(CC,REGNAME,VALUE,REPRESENT)  Same as above, except the timeout value 
%   defaults to the value provided by the CC object. Use CC.GET('timeout') 
%   to examine the default supplied by the object.
%
%   REGWRITE(CC,REGNAME,VALUE) Same as above, except the data type 
%   defaults to 'integer' and this routine writes VALUE as a signed 2's
%   complement data value
%
%   The supported values for REGNAME will depend on the DSP processor.  For 
%   example, the following registers are available on the TMS320C6xxx 
%   family of processors:
%   'A0' .. 'An' - Accumulator A registers
%   'B0' .. 'Bn' - Accumulator B registers
%   'PC','ISTP',IFR,'IER','IRP','NRP','AMR','CSR' - Other 32 bit registers
%   'A1:A0' .. 'B15:B14 ' - 64 bit Register pairs
%
%   See also REGREAD, WRITE, HEX2DEC.


%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.13.2.5 $ $Date: 2004/04/06 01:04:53 $

% Check input parameters
error(nargchk(2,5,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a CCSDSP Handle.');
end

% Parse timeout
if nargin<5
    dtimeout = double(get(cc,'timeout'));
else
    dtimeout = CheckTimeout(nargin,timeout,cc);
end
% Check regname
if ~ischar(regname)
    error(generateccsmsgid('InvalidInput'),'??? RegWrite: Second parameter must be a string.');
end
% Check input data
[value,HexFlag] = CheckInputValue(value);
% Check represent
if nargin<4
    represent = '2scomp';
end
represent = CheckRepresent(represent,nargin,HexFlag);

if cc.subfamily==84, % C54x Family
    mm54regwrite(cc,regname,value,represent,dtimeout);
elseif cc.subfamily==85, % C55x Family 
    mm55regwrite(cc,regname,value,represent,dtimeout);
elseif cc.subfamily==40, % C28x Family 
    mm28regwrite(cc,regname,value,represent,dtimeout);
elseif cc.subfamily==39, % C27x Family
    mm27regwrite(cc,regname,value,represent,dtimeout);
elseif cc.subfamily==36, % C24x Family 
    mm24regwrite(cc,regname,value,represent,dtimeout);
else
    if ischar(value)
        value = hex2dec(value);
    end
    callSwitchyard(cc.ccsversion,[26 cc.boardnum cc.procnum dtimeout cc.eventwaitms],regname,value,represent);
end

%----------------------------------
function [value,HexFlag] = CheckInputValue(value)
if isnumeric(value) 
    if length(value)>1
        warning(generateccsmsgid('TooManyData'),...
        sprintf('Input data has more than one element. Only first element will be stored on register.'));
        value = value(1);
    end
    HexFlag = 0;
elseif iscellstr(value) 
    if length(value)>1
        warning(generateccsmsgid('TooManyData'),...
        sprintf('Input data has more than one element. Only first element will be stored on register.'));
        value = value{1};
    end
    HexFlag = 1;
elseif ischar(value) 
    if size(value,1)>1
        warning(generateccsmsgid('TooManyData'),...
        sprintf('Input data has more than one element. Only first element will be stored on register.'));
        value = value(1,:);
    end
    HexFlag = 1;
else
    HexFlag = 0;
end

%----------------------------
function represent = CheckRepresent(represent,nargs,isDataHex)
errid = generateccsmsgid('InvalidInput');
if nargs>=4 % represent specified
	if ~ischar(represent)
        error(errid,'??? RegWrite: Fourth parameter must be a string.');
	elseif isempty(strmatch(lower(represent),{'binary','2scomp','ieee'},'exact'))
        error(errid,['??? RegWrite: Representation ''' represent ''' is not supported. Representation must be ''binary'', ''2scomp'', or ''ieee''.']);
    elseif isDataHex==1 && ~isempty(strmatch(represent,{'2scomp', 'ieee'},'exact'))
        warning(generateccsmsgid('InvalidConversion'),sprintf(['Cannot convert hexadecimal value to ''2scomp'' or ''ieee'' format,\n' ...
                'data will be represented in ''binary'' format.']));
        represent = 'binary'; % raw value is being written
	end
elseif nargs==3 % represent not specified
    if isDataHex==1
        warning(generateccsmsgid('InvalidConversion'),sprintf(['Cannot convert hexadecimal value to ''2scomp'' format,\n' ...
                'data will be represented in ''binary'' format.']));
        represent = 'binary'; % raw value is being written
    else, % numeric data, represent no specified
        represent = '2scomp';
    end
end

%-------------------------------
function dtimeout = CheckTimeout(nargs,timeout,cc)
% Parse timeout
if( nargs >= 5) && (~isempty(timeout)),
    if ~isnumeric(timeout) || length(timeout) ~= 1,
        error(generateccsmsgid('InvalidInput'),'TIMEOUT parameter must be a single numeric value.');
    end
    dtimeout = double(timeout);
else
    dtimeout = double(get(cc,'timeout'));
end
if( dtimeout < 0)
    error(generateccsmsgid('NegativeTimeout'),['Negative TIMEOUT value "' num2str(dtimeout) '" not permitted.']);
end

% [EOF] regwrite.m
