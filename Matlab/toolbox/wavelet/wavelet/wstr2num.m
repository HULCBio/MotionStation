function x = wstr2num(s)
%WSTR2NUM Convert string to number.
%   X = WSTR2NUM(S) converts the string S, which should be an
%   ASCII character representation of a numeric value, to MATLAB's
%   numeric representation.  The string may contain digits, a decimal
%   point, a leading + or - sign, an 'e' preceding a power of 10 scale
%   factor, and an 'i' for a complex unit.  
%
%   WSTR2NUM converts a character array representation of a matrix of
%   numbers to a numeric matrix. For example,
%       
%        A = ['1 2'         wstr2num(A) => [1 2;3 4]
%             '3 4']
%
%   If the string S does not represent a valid number or matrix,
%   WSTR2NUM(S) returns the empty matrix.
%
%   Spaces can be significant. For instance, 
%      wstr2num('1+2i') and wstr2num('1 + 2i') 
%   produce x = 1+2i while 
%      wstr2num('1 +2i') 
%   produces x = [1 2i].
%    
%   See also NUM2STR, HEX2NUM, CHAR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Apr-98.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 19:38:16 $

% Mask for str2num (later we use str2double).
x = str2num(s);
