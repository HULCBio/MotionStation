function [As,Bs,Cs,Ds,Ks,X0s,par,ny,nu] = sschk(A,B,C,D,K,X0,Ts);
%SSCHK  Exit checking for IDSS models

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:21 $

idparent = idmodel(ny, nu, ABCDKXT{7}, par, eye(length(par)));
sys = class(sys, 'idss', idparent);
