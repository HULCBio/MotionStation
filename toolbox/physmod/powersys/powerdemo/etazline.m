function [z_ser,y_sh] =  etazline(long,r,x,b)
%
%  ETAZLINE  computes the equivalent PI model of a transmission line
%
% [z_ser,y_sh] =  zligne(long,r,x,b)
%
% 
% Input arguments:
% ---------------
%  long	: Length (any unit)
%    r	: resistance  (Ohms/per unit length )
%    x	: reactance   (Ohms/per unit length  
%    b	: susceptance (Siemens per unit length)
%
% output arguments:
% ----------------
%   z_ser : series impedance of the PI section   
%   y_sh  : shunt admittance connected at each end of the PI section

%   G. Sybille ; Nov. 1990
%   Copyright 1997-2003 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.2.4 $

z=r+j*x;
y=j*b;
gamal=(y*z)^0.5*long;
zc=(z/y)^0.5;
z_ser=sinh(gamal)*zc;
y_sh=tanh(gamal/2.0)/zc;
