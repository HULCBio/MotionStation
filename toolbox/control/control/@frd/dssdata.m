function [a,b,c,d,e,Ts,Td] = dssdata(sys)
%DSSDATA  Quick access to descriptor state-space data.
%
%   [A,B,C,D,E] = DSSDATA(SYS) returns the values of the A,B,C,D,E
%   matrices for the descriptor state-space model SYS (see DSS).  
%   DSSDATA is equivalent to SSDATA for regular state-space models
%   (i.e., when E=I).
%
%   [A,B,C,D,E,TS] = DSSDATA(SYS) also returns the sample time TS.
%   Other properties of SYS can be accessed with GET or by direct 
%   structure-like referencing (e.g., SYS.Ts).
%
%   For arrays of SS models with variable order, use the syntax
%      [A,B,C,D,E] = DSSDATA(SYS,'cell')
%   to extract the state-space matrices of each model as separate
%   cells in the cell arrays A,B,C,D,E.
%
%   See also GET, SSDATA, DSS, LTIMODELS, LTIPROPS.

%    Author(s): P. Gahinet, 4-1-96
%    Copyright 1986-2002 The MathWorks, Inc. 
%    $Revision: 1.8 $  $Date: 2002/04/10 06:18:00 $

error('DSSDATA is not supported for FRD models.')

