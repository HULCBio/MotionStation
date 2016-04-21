function q = quantizer(varargin)
%QUANTIZER   Constructor for QUANTIZER object.
%   Q = QUANTIZER creates a quantizer with all default values.
%
%   Q = QUANTIZER(Value1, Value2, ... ) creates a QUANTIZER object with
%   values Value1, Value2, ....  If two values conflict, then the last
%   value in the list is the one that is set.
%
%   Q = QUANTIZER(a) where a is a structure whose field names are object
%   property names, sets the properties named in each field name with
%   the values contained in the structure.
%  
%   Q = QUANTIZER(pn,pv) sets the named properties specified in the cell
%   array of strings pn to the corresponding values in the cell array
%   pv.
%  
%   Q = QUANTIZER('Property1',Value1, 'Property2',Value2,...) assigns
%   values associated with named properties.
%
%   It is permissible to use property/value string pairs, structures,
%   and property/value cell array pairs in the same call to SET.
%
%   Values sorted by property name:
%   'Mode'
%      'double' - Double-precision mode.  Override all other parameters.
%      'float'  - Custom-precision floating-point mode.
%      'single' - Single-precision mode.  Override all other parameters. 
%      'fixed'  - Signed fixed-point mode.
%      'ufixed' - Unsigned fixed-point mode.
%   
%   'Roundmode'
%      'ceil'       - Round towards positive infinity.
%      'convergent' - Convergent rounding.
%      'fix'        - Round towards zero.
%      'floor'      - Round towards negative infinity.
%      'round'      - Round towards nearest.
%
%   'Overflowmode' (fixed-point only)
%      'saturate' - Saturate at max value on overflow.
%      'wrap'     - Wrap on overflow.
%
%   'Format'
%      [wordlength  fractionlength] - The format for fixed and ufixed mode.
%      [wordlength  exponentlength] - The format for float mode.
%
%
%   Besides properties, a QUANTIZER object also has states 'max', 'min',
%   'noverflows', 'nunderflows', 'noperations'.  They can be accessed
%   through QUANTIZER/GET or Q.max, Q.min, Q.noverflows, Q.nunderflows,
%   but they cannot be set.  They are updated during the
%   QUANTIZER/QUANTIZE method, and are reset by the QUANTIZER/RESET
%   method.
%  
%   States:
%     'max'         - Maximum value before quantizing.
%     'min'         - Minimum value before quantizing.
%     'noverflows'  - Number of overflows.
%     'nunderflows' - Number of underflows.
%     'noperations' - Number of elements quantized.
%
%   Help is available for all the properties by typing at the command line:
%     HELP QUANTIZER/<PROPERTY> 
%   or
%     HELPWIN QUANTIZER/<PROPERTY>
%   where <PROPERTY> is one of the properties.  For
%   example
%     help quantizer/mode
%     help quantizer/roundmode
%     help quantizer/overflowmode
%     help quantizer/format
%
%   Example:
%     q = quantizer('fixed', 'ceil', 'saturate', [5 4])
%
%   See also FIXEDPOINT, QUANTIZER/GET, QUANTIZER/SET, QUANTIZER/MODE,
%   QUANTIZER/ROUNDMODE, QUANTIZER/OVERFLOWMODE, QUANTIZER/FORMAT,
%   QUANTIZER/QUANTIZE, QUANTIZER/RESET,
%   FI, FIMATH, FIPREF, NUMERICTYPE, SAVEFIPREF.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/20 23:18:41 $

registerembedded;

% Built-in UDD constructor

q = embedded.quantizer;

if nargin > 0
  setquantizer(q,varargin{:});
end

