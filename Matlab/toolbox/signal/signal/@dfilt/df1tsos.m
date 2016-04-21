function Hd = df1tsos(varargin)
%DF1TSOS Direct-Form I Transposed, Second-Order Sections.
%   Hd = DFILT.DF1TSOS(S) returns a discrete-time, second-order section, 
%   direct-form I transposed filter object, Hd, with coefficients given in 
%   the S matrix. 
% 
%   Hd = DFILT.DF1TSOS(b1,a1,b2,a2,...) returns a discrete-time, second-order 
%   section, direct-form I transposed filter object, Hd, with coefficients for 
%   the first section given in the b1 and a1 vectors, for the second section given 
%   in the b2 and a2 vectors, etc. 
% 
%   Hd = DFILT.DF1TSOS(...,g) includes a gain vector g. The elements of g are the 
%   gains for each section. The maximum length of g is the number of sections plus 
%   one. If g is not specified, all gains default to one.
%
%   % Example: Form a Direct-Form I Transposed, Second-Order Sections 
%   % discrete-time filter with coefficients from a 6th order low-pass 
%   % elliptic design.                                                         
%   [z,p,k] = ellip(6,1,60,.4);                                                  
%   [s,g] = zp2sos(z,p,k);                                                     
%   Hd = dfilt.df1tsos(s,g)  
%
%   See also DFILT/DF1T, DFILT/DF1, DFILT/DF1SOS, DFILT/DF2
%   DFILT/DF2SOS, DFILT/DF2T, DFILT/DF2TSOS.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:59:57 $

Hd = dfilt.df1tsos(varargin{:});

% [EOF] 
