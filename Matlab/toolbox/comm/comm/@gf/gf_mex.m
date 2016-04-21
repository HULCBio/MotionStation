%GF_MEX  Arithmetic in finite field.
%   MEX file for arithmetic in GF(2^m).
%   Calling sequence: 
%   out=gf_mex(x,y,m,msg,p)  where 
%      x - first uint16 matrix
%      y - second uint16 matrix
%      m - double - number of bits per element
%      msg - string - message indicating what to do:
%          'plus' ==> add x+y (element-wise) --> same as subtraction
%          'times' ==> multiply: x.*y (element-wise)
%          'mtimes' ==> multiply: x*y (matrix fashion)
%          'rdivide' ==> multiplicative inverse: 1./x (element-wise)
%          'power' ==> raise x to the y power: x.^y  (element-wise)
%      p - uint32 scalar - primitive polynomial
%          - optional argument, default depends on m:
%          m    prim. polynomial       decimal represent.
%          2        1+D+D^2                   7
%          3        1+D+D^3                  11
%          4        1+D+D^4                  19
%          5        1+D^2+D^5                37
%          6        1+D+D^6                  67
%          7        1+D^3+D^7               137
%          8        1+D^2+D^3+D^4+D^8       285
%          9        1+D^4+D^9               529
%         10        1+D^3+D^10             1033
%         11        1+D^2+D^11             2053
%         12        1+D+D^4+D^6+D^12       4179
%         13        1+D+D^3+D^4+D^13       8219
%         14        1+D+D^6+D^10+D^14     17475
%         15        1+D+D^15              32771
%         16        1+D+D^3+D^12+D^16     69643
%      table1 - uint16 array - length 2^m-1
%        lookup table for converting from exponential form
%        to polynomial
%      table2 - uint16 array - length 2^m-1
%        lookup table for converting from polynomial form
%        to exponential
%      table1 and table2 are optional, if omitted, slow
%        multiplication, exponentiation and inversion are done.
%        If table1 is provided, table2 must also be provided.
%        These parameters may also be passed, but be empty,
%        in which case they will be ignored.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:15:32 $ 

