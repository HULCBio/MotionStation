function display(state)
%DISPLAY Display an MPCSTATE object

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/10 23:35:19 $   

stateOut.Plant = state.Plant(:)'; % Transpose, so that display(struct) shows numbers
stateOut.Disturbance = state.Disturbance(:)'; % Transpose, so that display(struct) shows numbers
stateOut.Noise = state.Noise(:)'; % Transpose, so that display(struct) shows numbers
stateOut.LastMove = state.LastMove(:)'; % Transpose, so that display(struct) shows numbers

disp('MPCSTATE object with fields');
disp(stateOut)