function [Props,AsgnVals] = pnames(MPCSIMOPT)
%PNAMES  All public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(MPCSIMOPT)  returns the list PROPS of
%   public properties of the object MPCSIMOPT (a cell vector), as well as 
%   the assignable values ASGNVALS for these properties (a cell vector
%   of strings).  PROPS contains the true case-sensitive property names.
%
%   See also  GET, SET.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:33:11 $   


% MPC properties

Props = {'PlantInitialState';'ControllerInitialState';'UnmeasuredDisturbance';
'InputNoise';'OutputNoise';'RefLookAhead';'MDLookAhead';'Constraints';
'Model';'StatusBar';'MVSignal';'OpenLoop'};

% Also return assignable values if needed
if nargout>1,
   AsgnVals = {'Nxp-by-1 array';...
         'MPCSTATE object';...
         'T-by-Nud array';...
         'T-by-Nu array';
         'T-by-Nym array';
         '[ on | {off} ]';
         '[ on | {off} ]';
         '[ {on} | off ]';
         'LTI object or structure of models';
         '[ on | {off} ]';
         'T-by-Nu array';
         '[ on | {off} ]'};
end

% end MPCSIMOPT/pnames.m
