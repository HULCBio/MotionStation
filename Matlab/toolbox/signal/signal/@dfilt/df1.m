function Hd = df1(varargin)
%DF1 Direct-Form I.
%   Hd = DFILT.DF1(NUM, DEN) constructs a discrete-time direct-form I
%   filter object.
%
%   % EXAMPLE
%   [b,a] = butter(4,.5);
%   Hd = dfilt.df1(b,a)
%
%   See also DFILT/DF1SOS, DFILT/DF1T, DFILT/DF1TSOS, DFILT/DF2
%   DFILT/DF2SOS, DFILT/DF2T, DFILT/DF2TSOS.
  
%   Author: P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:51 $

Hd = dfilt.df1(varargin{:});

% [EOF] 
