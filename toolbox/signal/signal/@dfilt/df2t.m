function Hd = df2t(varargin)
%DF2T Direct-Form II Transposed.
%   Hd = DFILT.DF2T(NUM, DEN) constructs a discrete-time direct-form II
%   transposed filter object.
%
%   % EXAMPLE
%   [b,a] = butter(4,.5);
%   Hd = dfilt.df2t(b,a)
%
%   See also DFILT/DF2TSOS, DFILT/DF2, DFILT/DF2SOS, DFILT/DF1
%   DFILT/DF1SOS, DFILT/DF1T, DFILT/DF1TSOS.

%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:53 $

Hd = dfilt.df2t(varargin{:});

% [EOF] 

