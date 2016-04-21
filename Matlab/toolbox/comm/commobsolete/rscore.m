function [msg, err, ccode] = rscore(code, k, tp, dim, pow_dim);
%RSCORE The core function in Reed-Solomon decode.
%       MSG = RSCORE(CODE, K, TP, M, POW_M, T2) decodes a single codeword
%       vector CODE using the Reed-Solomon decoding technique. The message length
%       is K. The complete (and correct) list of all members in GF(2^M) is
%       in TP. The code word length is provided in POW_M, which equals
%       2^M - 1. The decoding result is provided in the output variable MSG.
%
%       [MSG, ERR] = RSCORE(CODE, K, TP, M, POW_M, T2) outputs the error 
%       detected in the decoding.
%
%       [MSG, ERR, CCODE] = RSCORE(CODE, K, TP, M, POW_M, T2) outputs the
%       corrected codeword in CCODE.
%
%       NOTE: Unlike all of the other encoding/decoding functions,
%       this function takes exponential input instead of regular input for
%       processing. For example [-Inf, 0, 1, 2, ...] represents
%       [0 1 alpha, alpha^2, ...] in GF(2^m). There are 2^M elements in
%       GF(2^M). Hence, the input CODE represents 2^M * (2^M - 1) bits of
%       information. The decoded MSG represents 2^M * K bits of information.
%       To speed computation, no error-checking is placed in this function,
%       all input variables must be present.
%       

%       Wes Wang 8/11/94, 10/11/95.
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.12 $
