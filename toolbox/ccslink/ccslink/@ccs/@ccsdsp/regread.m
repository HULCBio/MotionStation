function resp = regread(cc,regname,represent,timeout)
%REGREAD Returns the data value in the specified DSP register.
%   R = REGREAD(CC, REGNAME, REPRESENT, TIMEOUT) reads the data value
%   in the register of the DSP processor and returns it.  
%   REGNAME is the name of the source register.   This register 
%   is read from the DSP processor referenced by the CC object.  
%   The REPRESENT parameter defines the interpretation of the 
%   register's data format.  For convenience, the return value R is 
%   converted to the MATLAB 'double' type regardless of the data 
%   representation to simplify direct manipulation in MATLAB
%
%   REPRESENT - Representation of data in source register
%   '2scomp' - (default) 2's complement signed integer
%   'binary' - Unsigned binary integer 
%   'ieee'   - IEEE floating point (32 and 64 bit registers, only)
% 
%   TIMEOUT defines an upper limit (in seconds) on the time this method 
%   will wait for completion of the read.  If this period is exceeded, this 
%   method will immediately return with a timeout error. 
%
%   R = REGREAD(CC,REGNAME, REPRESENT) Same as above, except the timeout 
%   value defaults to the value provided by the CC object. Use 
%   CC.GET('timeout') to examine the default supplied by the object.
%
%   R = REGREAD(CC,REGNAME) Same as above, except the data type defaults to 
%   '2scomp' and this routine returns a signed integer interpretation of the
%   value stored in REGNAME.
%   
%   The supported values for REGNAME will depend on the DSP processor.  For 
%   example, the following registers are available on the TMS320C6xxx 
%   family of processors:
%   'A0' .. 'An' - Accumulator A registers
%   'B0' .. 'Bn' - Accumulator B registers
%   'PC','ISTP',IFR,'IER','IRP','NRP','AMR','CSR' - Other 32 bit registers
%   'A1:A0' .. 'B15:B14 ' - 64 bit Register pairs
%
%   See also REGWRITE, READ, DEC2HEX.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.23.4.4 $ $Date: 2004/04/06 01:04:52 $

error(nargchk(2,4,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a CCSDSP Handle.');
end

% Parse timeout
if( nargin >= 4) & (~isempty(timeout)),
    if ~isnumeric(timeout) | length(timeout) ~= 1,
        error(generateccsmsgid('InvalidInput'),'TIMEOUT parameter must be a single numeric value.');
    end
    dtimeout = double(timeout);
else
    dtimeout = double(get(cc,'timeout'));
end
if( dtimeout < 0)
    error(generateccsmsgid('NegativeTimeout'),['Negative TIMEOUT value "' num2str(dtimeout) '" not permitted.']);
end
% Check regname
if ~ischar(regname)
    error(generateccsmsgid('InvalidInput'),'??? RegRead: Second parameter must be a string.');
end
% Check represent
if nargin==2
    represent = '2scomp';
elseif nargin>=3
	CheckRepresent(regname,represent);
end


if cc.subfamily==84, % C54x Family
    if strcmpi(regname,'PC') %PC is not memory-mapped
        resp=callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum dtimeout cc.eventwaitms],regname,represent);
    else
        resp = mm54regread(cc,regname,represent,dtimeout);
    end
elseif cc.subfamily==85, % C55x Family
    resp = mm55regread(cc,regname,represent,dtimeout);
elseif cc.subfamily==40, % C28x Family
    resp = mm28regread(cc,regname,represent,dtimeout);
elseif cc.subfamily==39, % C27x Family
    resp = mm27regread(cc,regname,represent,dtimeout);
elseif cc.subfamily==36, % C24x Family
    resp = mm24regread(cc,regname,represent,dtimeout);
else % other processors
    resp=callSwitchyard(cc.ccsversion,[25 cc.boardnum cc.procnum dtimeout cc.eventwaitms],regname,represent);
end

%----------------------------
function CheckRepresent(reg,represent)
errid = generateccsmsgid('InvalidInput');
if ~ischar(represent)
    error(errid,'??? RegRead: Third parameter must be a string.');
elseif isempty(strmatch(lower(represent),{'binary','2scomp','ieee'},'exact'))
    error(errid,['??? RegRead: Representation ''' represent ''' is not supported. Representation must be ''binary'', ''2scomp'', or ''ieee''.']);
end

% [EOF] regread.m