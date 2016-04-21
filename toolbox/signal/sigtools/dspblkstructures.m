function s = dspblkstructures
%DSPBLKSTRUCTURES Returns the structures supported by the Digital Filter Block.

%   Author(s): J. Schickler
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:31:34 $

s = {'df1', 'df2', 'df1t', 'df2t', 'df1sos', 'df2sos', 'df1tsos', ...
    'df2tsos', 'latticemamin', 'latticear', 'dffir', 'dffirt', ...
    'dfsymfir', 'dfasymfir'};

% [EOF]
