function L = d2c(L)
%D2C  Manages LTI properties in D2C conversion
%
%   CSYS.LTI = D2C(DSYS)  sets the LTI properties of the 
%   system CSYS produced by
%
%             CSYS = D2C(DSYS)

%       Author(s): P. Gahinet, 5-28-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $  $Date: 2002/04/10 05:51:25 $

% Delete Notes and UserData
L.Notes = {};
L.UserData = [];

% Multiply delay times by Ts and set sample time to zero
L.InputDelay = L.InputDelay * L.Ts;
L.OutputDelay = L.OutputDelay * L.Ts;
L.ioDelay = L.ioDelay * L.Ts;
L.Ts = 0;

