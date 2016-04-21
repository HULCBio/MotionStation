function [a,b,c,d,Ts,Td] = ssdata(sys)
%SSDATA  Quick access to state-space data.
%
%   [A,B,C,D] = SSDATA(SYS) retrieves the matrix data A,B,C,D
%   for the state-space model SYS.  If SYS is not a state-space 
%   model, it is first converted to a state-space representation.
%
%   [A,B,C,D,TS] = SSDATA(SYS) also returns the sample time TS.
%   Other properties of SYS can be accessed with GET or by direct 
%   structure-like referencing (e.g., SYS.Ts).
%
%   For arrays of SS models with the same order (number of states), 
%   SSDATA returns multi-dimensional arrays A,B,C,D where A(:,:,k),
%   B(:,:,k), C(:,:,k), D(:,:,k) are the state-space matrices of 
%   the k-th model SYS(:,:,k).
%
%   For arrays of SS models with variable order, use the syntax
%      [A,B,C,D] = SSDATA(SYS,'cell')
%   to extract the state-space matrices of each model as separate
%   cells in the cell arrays A,B,C,D.
%
%   See also SS, GET, DSSDATA, TFDATA, ZPKDATA, LTIMODELS, LTIPROPS.

%   Author(s): P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%    $Revision: 1.8 $  $Date: 2002/04/10 06:16:37 $

error('SSDATA is not supported for FRD models.')
