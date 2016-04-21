function write(cc,address,data,timeout)
%WRITE Puts a block of data values into the DSP processor's memory.
%   WRITE(CC,ADDRESS,DATA,TIMEOUT) writes a block of DATA values into the 
%   memory space of the DSP processor referenced by the CC object.  The 
%   write begins from the memory location defined by the ADDRESS parameter.  
%   The WRITE method can accept DATA as a scalar, vector, matrix or 
%   multi-dimensional array.  DATA is written in column-major order.
%
%   ADDRESS is a decimal or hexadecimal representation of a memory address 
%   in the target DSP.  In all cases, the full address consist of two 
%   parts: the offset and the memory page.  However, many DSP processors have 
%   only a single page, in which case the page portion of the full address 
%   should always be 0.  The page value can be explicitly defined using a 
%   numeric vector representation of the address (see below).  Alternatively, 
%   the CC object has a default page value which is applied if the page value 
%   is not explicitly incorporated into the passed address parameter.  In DSP 
%   processors with only a single page, by setting the CC object page value 
%   to zero it is possible to specify all addresses using the abbreviated 
%   (implied page) format.  The address parameter can be specified in two ways, 
%   first as a numerical value which is a decimal representation of the DSP 
%   address.  Alternatively, a string is interpreted as a hexadecimal 
%   representation of the address offset.  (See HEX2DEC, which is used for the 
%   conversion to a decimal value).  When the address is defined by a string, 
%   the page is always derived from the CC object.  Thus, there is no method of 
%   explicitly defining the page when the address parameter is passed as a 
%   hexadecimal string.
%
%   Examples of the address parameter:
%       '1F'  Offset is decimal 31, with the page taken from CC.page
%         10  Offset is decimal 10, with the page taken from CC.page
%     [18,1]  Offset is decimal 18, with page equal to decimal 1
%
%   DATA is a scalar, vector or array of values which will be written to the memory
%   of the DSP processor. The WRITE routine supports the following numeric data types:
%
%     double  IEEE Double-precision floating point
%     single  IEEE Single-precision floating point
%      uint8  8-bit unsigned binary integer
%     uint16  16-bit unsigned binary integer
%     uint32  32-bit unsigned binary integer
%       int8  8-bit signed 2's complement integer
%      int16  16-bit signed 2's complement integer
%      int32  32-bit signed 2's complement integer
%
%   TIMEOUT defines and upper limit (in seconds) on the period this method will wait
%   for completion of the write.  If this period is exceeded, this method will
%   immediately return with a timeout error. 
%
%   WRITE(CC,ADDRESS,DATA) Same as above, except the timeout value defaults to
%   the value provided by the CC object. Use CC.GET('timeout') to examine the default 
%   supplied by the object.
%  
%   Note - this routine does not coerce data type alignment.  This means that
%   certain combinations of ADDRESS and DATATYPE will be difficult for the target
%   DSP to use.  To ensure seamless operation, it's recommended that the ADDRESS 
%   method be used to extract address values that are compatible with the alignment 
%   requirements of the target DSP processor.
%
%   Examples
%   1. Write array of integer (16-bits) and at location of target symbol 'data'.
%     >write(cc,address(cc,'data'),int16([1:100]))
%   2. Write a single-precision IEEE floating point value (32-bits) at address FF00(Hex).
%     >write(cc,'FF00',single(23.5))
%   3. Write a 2-D array of integers in Row-Major (C-style) format at address 65280 (decimal).
%     mlarr = int32([1:10; 101:110])
%     >write(cc,65280,mlarr')
%
%   See also READ, ADDRESS, HEX2DEC, INT32, CEXPR.

% Copyright 2004 The MathWorks, Inc.
