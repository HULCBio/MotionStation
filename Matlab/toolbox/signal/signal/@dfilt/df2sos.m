function Hd = df2sos(varargin)
%DF2SOS Direct-Form II, Second-Order Sections.
%   Hd = DFILT.DF2SOS(S) returns a discrete-time, second-order section, 
%   direct-form II filter object, Hd, with coefficients given in 
%   the S matrix. 
% 
%   Hd = DFILT.DF2SOS(b1,a1,b2,a2,...) returns a discrete-time, second-order 
%   section, direct-form II filter object, Hd, with coefficients for the first 
%   section given in the b1 and a1 vectors, for the second section given in 
%   the b2 and a2 vectors, etc. 
% 
%   Hd = DFILT.DF2SOS(...,g) includes a gain vector g. The elements of g are the 
%   gains for each section. The maximum length of g is the number of sections plus 
%   one. If g is not specified, all gains default to one.
%
%   % Example: Form a Direct-Form II, Second-Order Sections discrete-time filter
%   % with coefficients from a 6th order low-pass elliptic design.                                                      
%   [z,p,k] = ellip(6,1,60,.4);                                                  
%   [s,g] = zp2sos(z,p,k);                                                     
%   Hd = dfilt.df2sos(s,g)  
%
%   See also DFILT/DF2, DFILT/DF2T, DFILT/DF2TSOS, DFILT/DF1
%   DFILT/DF1SOS, DFILT/DF1T, DFILT/DF1TSOS.
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:59:58 $

Hd = dfilt.df2sos(varargin{:});

% [EOF] 
