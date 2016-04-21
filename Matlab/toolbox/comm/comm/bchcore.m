function [msg, err, ccode] = bchcore(code, pow_dim, dim, k, t, tp)
%BCHCORE The core part of the BCH decode.
%       [MSG, ERR, CCODE] = BCHCORE(CODE, POW_DIM, DIM, K, T, TP) decodes
%       a BCH code, in which CODE is a code word row vector,  with its column
%       size being POW_DIM. POW_DIM equals 2^DIM -1. K is the message length,
%       T is the error correction capability. TP is a complete list of the
%       elements in GF(2^DIM).
%
%       This function can share information between a Simulink file and
%       MATLAB functions. It is not designed to be called directly. There is
%       no error checking in order to eliminate overhead.
%

%       Wes Wang 8/5/94, 9/30/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.12 $
