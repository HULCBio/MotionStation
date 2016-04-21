function d = mydnif(z,n)
%MYDNIF Example custom net input derivative function of MYNIF.
%
%  Use this function as a template to write your own function.
%  
%  Syntax
%
%    dN_dZ = dtansig(Z,N)
%      Z - SxQ matrix of Q weighted input (column) vectors.
%      N - SxQ matrix of Q net input (column) vectors.
%      dN_dZ - SxQ derivative dN/dZ.
%
%  Example
%
%    z1 = rand(4,5);
%    z2 = rand(4,5);
%    z3 = rand(4,5);
%    n = mynif(z1,z2,z3)
%    dn_dz1 = mydnif(z1,n)
%    dn_dz2 = mydnif(z2,n)
%    dn_dz3 = mydnif(z3,n)

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.3.2.1 $

% ** Replace the following calculation with your
% **  derivative calculation.

d = n.^2 .* z.^2;

% **  Note that you have both the net input Z in question
% **  and output N available to calculate the derivative.
