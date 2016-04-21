function resp = read(cc,address,datatype,count,timeout)
%READ Retrieves a block of data values from the DSP processor's memory.
%   MEM = READ(CC,ADDRESS,DATATYPE,COUNT,TIMEOUT) returns a block of data 
%   values from the memory space of the DSP processor referenced by the CC 
%   object.  The read blocks begins from the DSP memory location given by 
%   the ADDRESS parameter.  The data format of the raw memory image is 
%   supplied by the DATATYPE option.  A Block read of multiple data values 
%   is possible by specifying a COUNT parameter.
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
%        '1F'  Hex, Offset is decimal 31, with the page taken from cc.page
%          10  Decimal, Offset is decimal 10, with the page taken from cc.page
%      [18,1]  Decimal with page, Offset is decimal 18, with page equal to 1
%
%   DATATYPE defines the interpretation of the raw values read from the DSP memory.
%   The data is read starting from ADDRESS without regard to type-alignment 
%   boundaries in the DSP.  Conversely, the byte ordering of the data type is 
%   automatically applied. The following MATLAB data types are supported:
%
%    'double'  IEEE Double-precision floating point
%    'single'  IEEE Single-precision floating point
%     'uint8'  8-bit unsigned binary integer
%    'uint16'  16-bit unsigned binary integer
%    'uint32'  32-bit unsigned binary integer
%      'int8'  8-bit signed 2's complement integer
%     'int16'  16-bit signed 2's complement integer
%     'int32'  32-bit signed 2's complement integer
%
%   The COUNT parameter defines the dimensions of the returned data block 
%   (MEM).  COUNT can be a scalar value which causes read to return a column 
%   vector which has COUNT values.  Multidimensional reads are possible by 
%   passing a vector for COUNT.  The elements of count define the dimensions 
%   of the returned data matrix.  The memory is read in column-major order.  
%   COUNT defines the dimensions of the returned data array (MEM) as follows:
%
%           n  Read n values into a column vector.
%       [m,n]  Read m-by-n values into m by n matrix in column-major order.
%   [m,n,...]  Read a multidimensional matrix of values.
%
%   TIMEOUT defines an upper limit (in seconds) on the time this method will wait
%   for completion of the read.  If this period is exceeded, this method will
%   immediately return with a timeout error.  
%
%   MEM = READ(CC,ADDRESS,DATATYPE,COUNT) Same as above, except the timeout
%   value defaults to the value specified by the CC object. Use CC.GET to 
%   examine the default supplied by the object.
%
%   MEM = READ(CC,ADDRESS,DATATYPE) Same as above, except the count value 
%   defaults to 1 value of type DATATYPE.
%
%   Note - this routine does not coerce data type alignment.  This means that
%   certain combinations of ADDRESS and DATATYPE will be difficult for the target
%   DSP to use.  To ensure seamless operation, it's recommended that the CC.ADDRESS 
%   method is used to extract address values that are compatible with the alignment 
%   requirements of the target DSP processor.
%
%   Examples
%   1. Read 16-bit integer 'var'.
%     >mlvar = read(cc,address(cc,'var'),'int16')
%   2. Read 100 integers (32-bits) from address F000(Hex) and plot it.
%     >mlplt = read(cc,'F000','int32',100)
%     >plot(double(mlplt))
%   3. Increment integer value at address 10 (decimal) of target DSP.
%     >mlinc = read(cc,10,'int32')
%     >mlinc = int32(double(mlinc)+1)
%     >write(cc,10,mlinc)
%
%   See also WRITE, ADDRESS, HEX2DEC, INT32, CEXPR.

% Copyright 2004 The MathWorks, Inc.
