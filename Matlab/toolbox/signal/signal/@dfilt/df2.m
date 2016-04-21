function Hd = df2(varargin)
%DF2 Direct-Form II.
%   Hd = DFILT.DF2(NUM, DEN) constructs a discrete-time direct-form II
%   filter object.
%
%   % EXAMPLE
%   [b,a] = butter(4,.5);
%   Hd = dfilt.df2(b,a)
%
%   See also DFILT/DF2SOS, DFILT/DF2T, DFILT/DF2TSOS, DFILT/DF1 
%   DFILT/DF1SOS, DFILT/DF1T, DFILT/DF1TSOS.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:53 $

Hd = dfilt.df2(varargin{:});

% [EOF] 
