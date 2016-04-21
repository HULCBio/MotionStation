function [P,N] = seqperiod(X)
%SEQPERIOD Find minimum-length repeating sequence in a vector.
% 
%  P = SEQPERIOD(X) returns the index P of the sequence of samples
%  X(1:P) which is found to repeat (possibly multiple times) in
%  X(P+1:end).  P is the sample period of the repetitive sequence.
%  No intervening samples may be present between repetitions.  An
%  incomplete repetition is permitted at the end of X.  If no
%  repetition is found, the entire sequence X is returned as the
%  minimum-length sequence and hence P=length(X).
%
%  [P,N] = SEQPERIOD(X) returns the number of repetitions N of the
%  sequence X(1:P) in X.  N will always be >= 1 and may be non-
%  integer valued.
%
%  If X is a matrix or N-D array, the sequence period is determined
%  along the first non-singleton dimension of X.

%  Author: D. Orofino
%  Copyright 1988-2002 The MathWorks, Inc.
%  $Revision: 1.7 $ $Date: 2002/04/15 01:13:52 $

% The following comment, MATLAB compiler pragma, is necessary to avoid compiling 
% this M-file instead of linking against the MEX-file.  Don't remove.
%# mex

error('MEX file for SEQPERIOD not found');

% [EOF] seqperiod.m
