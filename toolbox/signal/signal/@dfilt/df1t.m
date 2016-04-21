function Hd = df1t(varargin)
%DF1T Direct-Form I Transposed.
%   Hd = DFILT.DF1T(NUM, DEN) constructs a discrete-time direct-form I
%   transposed filter object.
%
%   % EXAMPLE
%   [b,a] = butter(4,.5);
%   Hd = dfilt.df1t(b,a)
%
%   See also DFILT/DF1TSOS, DFILT/DF1, DFILT/DF1SOS, DFILT/DF2
%   DFILT/DF2SOS, DFILT/DF2T, DFILT/DF2TSOS.
  
%   Author: P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:52 $

Hd = dfilt.df1t(varargin{:});

% [EOF] 
