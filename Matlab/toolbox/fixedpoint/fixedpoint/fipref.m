function this = fipref(varargin)
%FIPREF  FI display preferences object.
%   P = FIPREF creates a FI display preferences object P.  The FI object
%   is a fixed-point data type.
%
%   P = FIPREF(Property1, Value1, ...) also sets the properties and
%   values indicated by the property/value pairs.
%
%   The FI display options are
%  
%          NumberDisplay: {RealWorldValue, bin, dec, hex, int}
%     NumericTypeDisplay: {full, none, short}
%          FimathDisplay: {full, none}
%
%   To save the display preferences between MATLAB sessions, type
%   SAVEFIPREF.
%
%   Examples:
%
%     format long g   % Best of fixed or floating point format with 15 decimal digits.
%     format compact  % Suppress extra line-feeds.
%
%     p = fipref;
%     p.NumberDisplay      = 'RealWorldValue';
%     p.NumericTypeDisplay = 'short';
%     p.FimathDisplay      = 'none';
%
%   Then the display of fi fixed-point objects will display the stored
%   value as a "real world value", the numerictype in a coded short
%   format, and suppress the display of the fimath properties.
%
%      a=fi(pi)
%        % a = 
%        %    3.1416015625
%        %       s16,13
%
%   Note that the stored integer value does not change by changing the
%   fipref.  The fipref only affects the display.
%
%      p.NumberDisplay = 'bin';
%
%   Then the display of fi fixed-point objects will display the stored
%   value in binary.
%
%     a = fi(0.1)
%        % a =
%        % 0110011001100110
%        % (two's complement bin)
%        %       s16,18
%
%   To save the fipref display preferences between MATLAB sessions,
%   type:
%
%     savefipref
%
%   See also FI, FIMATH, NUMERICTYPE, QUANTIZER, SAVEFIPREF, FORMAT, FIXEDPOINT.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/20 23:18:39 $
this = embedded.fipref(varargin{:});