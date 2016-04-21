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

% Copyright 2004 The MathWorks, Inc.
