function out = dec2binvec(dec,n)
%DEC2BINVEC Convert decimal number to a binary vector.
%
%    DEC2BINVEC(D) returns the binary representation of D as a binary
%    vector.  The least significant bit is represented by the first 
%    column.  D must be a non-negative integer. 
% 
%    DEC2BINVEC(D,N) produces a binary representation with at least
%    N bits.
% 
%    Example:
%       dec2binvec(23) returns [1 1 1 0 1]
%
%    See also BINVEC2DEC, DEC2BIN.
%

%    MP 11-11-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:40:56 $

% Error if dec is not defined.
if nargin < 1
   error('daq:dec2binvec:argcheck', 'D must be defined.  Type ''daqhelp dec2binvec'' for more information.');
end

% Error if D is not a double.
if ~isa(dec, 'double')
   error('daq:dec2binvec:argcheck', 'D must be a double.');
end

% Error if a negative number is passed in.
if (dec < 0)
   error('daq:dec2binvec:argcheck', 'D must be a positive integer.');
end

% Convert the decimal number to a binary string.
switch nargin
case 1
   out = dec2bin(dec);
case 2
   out = dec2bin(dec,n);
end

% Convert the binary string, '1011', to a binvec, [1 1 0 1].
out = logical(str2num([fliplr(out);blanks(length(out))]')');
