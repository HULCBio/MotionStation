function a = fi(varargin)
%FI  Fixed-point numeric object.
%
%   Syntax:
%     a = fi(v)
%     a = fi(v, s)
%     a = fi(v, s, w)
%     a = fi(v, s, w, f)
%     a = fi(v, s, w, slope, bias)
%     a = fi(v, s, w, slopeadjustmentfactor, fixedexponent, bias)
%     a = fi(v, T)
%     a = fi(v, T, F)
%     a = fi(..., property1, value1, ...)
%     a = fi(property1, value1, ....)
%
%   Description:
%     fi(v) returns a signed fixed-point object with value v, 16-bit
%     word length, and best-precision fraction length.
%
%     fi(v,s) returns a fixed-point object with value v, signedness s,
%     16-bit word length, and best-precision fraction length. s can be 0
%     (false) for unsigned or 1 (true) for signed.
%
%     fi(v,s,w) returns a fixed-point object with value v, signedness s,
%     word length w, and best-precision fraction length.
%
%     fi(v,s,w,f) returns a fixed-point object with value v, signedness
%     s, word length w, and fraction length f.
%
%     fi(v,s,w,slope,bias) returns a fixed-point object with value v,
%     signedness s, word length w, slope, and bias.
%
%     fi(v,s,w,slopeadjustmentfactor,fixedexponent,bias) returns a
%     fixed-point object with value v, signedness s, word length w,
%     slopeadjustmentfactor, fixedexponent, and bias.
%
%     fi(v,T) returns a fixed-point object with value v and
%     embedded.numerictype T.
%
%     fi(v,T,F) returns a fixed-point object with value v,
%     embedded.numerictype T, and embedded.fimath F.
%
%     fi(...'PropertyName',PropertyValue...) and
%     fi('PropertyName',PropertyValue...) allow you to set fixed-point
%     objects for a fi object by property name/property value pairs.
%
%   The fi object has the following three general types of properties:
%     DATA Properties
%     FIMATH Properties
%     NUMERICTYPE Properties
%
%   DATA Properties:
%     The data properties of a fi object are always writable.
%
%     bin    - Stored integer value of a fi object in binary
%     data   - Numerical real-world value of a fi object
%     dec    - Stored integer value of a fi object in decimal
%     double - Numerical real-world value fi object, stored as a MATLAB double
%     hex    - Stored integer value of a fi object in hexadecimal
%     int    - Stored integer value of a fi object, stored in a built-in
%              MATLAB integer data type.
%     oct    - Stored integer value of a fi object in octal
%
%   NUMERICTYPE Properties:
%     When you create a fi object, a numerictype object is also
%     automatically created as a property of the fi object.
%
%     NUMERICTYPE           - Object containing all the numeric type 
%                             attributes of a fi object
%
%     The following numerictype properties are, by transitivity, also
%     properties of a fi object.  The properties of the numerictype
%     object listed below are not writable once the fi object has been
%     created. However, you can create a copy of a fi object with new
%     values specified for the numerictype properties.
%
%     Bias                  - Bias of a fi object
%     DataType              - Data type category associated with a fi object
%     DataTypeMode          - Data type and scaling mode of a fi object
%     FixedExponent         - Fixed-point exponent associated with a fi object
%     SlopeAdjustmentFactor - Slope adjustment associated with a fi
%                             object
%     FractionLength        - Fraction length of the stored integer value of a
%                             fi object in bits
%     Scaling               - Fixed-point scaling mode of a fi object
%     Signed                - Whether a fi object is signed or unsigned
%     Slope                 - Slope associated with a fi object
%     WordLength            - Word length of the stored integer value of a fi 
%                             object in bits
% 
%
%   FIMATH Properties:
%     When you create a fi object, a fimath object is also automatically
%     created as a property of the fi object.
%
%     FIMATH                - fimath object associated with a fi object
%
%     The following fimath properties are, by transitivity, also
%     properties of a fi object. The properties of the fimath object
%     listed below are always writable.
%
%     CastBeforeSum         - Whether both operands are cast to the sum 
%                             data type before addition
%     MaxProductWordLength  - Maximum allowable word length for the
%                             product data type
%     MaxSumWordLength      - Maximum allowable word length for the sum 
%                             data type
%     ProductFractionLength - Fraction length, in bits, of the product
%                             data type
%     ProductMode           - Defines how the product data type is determined
%     ProductWordLength     - Word length, in bits, of the product data type
%     RoundMode             - Rounding mode
%     SumFractionLength     - Fraction length, in bits, of the sum data type
%     SumMode               - Defines how the sum data type is determined
%     SumWordLength         - Word length, in bits, of the sum data type
%
%   FI Display Properties:
%     The command-line display of a fi object is controlled by the
%     FIPREF object, and by the FORMAT command.  
%
%     The value of a fi object can be displayed as a "real-world value",
%     in binary, octal, decimal, hex, or integer.
%
%     The NUMERICTYPE properties of a fi object can be displayed in a
%     short-hand display, a full display of all properties, or not
%     displayed.
%
%     The FIMATH properties of a fi object can be displayed or not
%     displayed.
%
%     Sometimes the display does not reflect the full precision of the
%     number, for example, when real-world value is being displayed.
%     However, the full precision is always stored in the fi object in
%     binary.  We suggest that you use FORMAT LONG G when displaying
%     real-world values, and that you use BIN or HEX to display the
%     values as they are stored in full precision.
%
%     After setting the display preferences with FIPREF, use SAVEFIPREF
%     to save the settings in the MATLAB preferences file so that the
%     settings will be persistent between sessions.
%
%     See FIPREF for a full description of how to set the display
%     properties.
%
%   Examples:
%
%     % If you omit all properties other than the value, the word length
%     % defaults to 16 bits, the fraction length sets itself to the best 
%     % precision possible, and signed is true.
%     a = fi(pi)
%
%     % The value v can also be an array. 
%     a = fi(magic(3))
%
%     % An unsigned fi.
%     a = fi(pi, 0)
%
%     % A signed fi with word length 8 bits, and fraction length best 
%     % precision.
%     a = fi(pi, 1, 8)
%
%     % Using property name/property value pairs to set the round mode
%     % to floor, and the overflow mode to wrap.
%     a = fi(pi, 'RoundMode', 'floor', 'OverflowMode','wrap')
%
%     % Setting the stored integer value from hex strings.  
%     % Can you identify these three familiar numbers from
%     %  their signed 32-bit hex representations?
%     a = fi(0,1,32,29);
%     a.hex = ['6487ed51';'56fc2a2c';'03333333']
%
%     % Getting the binary representation of a 16-bit sine wave.
%     a = fi(sin(2*pi*((0:10)'*0.1)))
%     a.bin
%
%   See also FIMATH, FIPREF, NUMERICTYPE, QUANTIZER, SAVEFIPREF, FORMAT, FIXEDPOINT.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/20 23:18:37 $

a = embedded.fi(varargin{:});
