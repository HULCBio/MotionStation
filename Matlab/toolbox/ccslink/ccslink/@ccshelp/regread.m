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

% Copyright 2004 The MathWorks, Inc.
