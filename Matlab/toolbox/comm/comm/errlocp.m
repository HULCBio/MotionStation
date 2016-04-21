function [sigma,err]=errlocp(syndrome,t,field,dim,err_flag,type_flag)
%ERRLOCP  calculates the error-location polynomial associated with BCH and 
%       Reed-Solomon decoding. SIGMA is a row vector that gives the coefficients
%       of the polynomial in ascending order. SYNDROME is the codeword syndrome, 
%       a row vector of length 2*T.  T is the error-correction capability 
%       of the code. FIELD is a matrix that lists all elements of GF(2m)
%
%       If type_flag=1, then errlocp uses Berlekamp's algorithm. If type_flag=0, 
%       then ERRLOCP uses a simplified method.  The simplified method can be used 
%       for binary code only.

%       Wes Wang 10/5/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.15 $
