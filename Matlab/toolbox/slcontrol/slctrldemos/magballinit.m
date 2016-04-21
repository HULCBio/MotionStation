function magballinit
%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:08:21 $

%% Open the model
open_system('magballdemo')
%% Open The Control and Estimation Tools Manager
X = simcontdesigner('initialize_linearize','magballdemo');
h=handle(getObject(X.getSelected));
%% Linearize the model
h.LinearizeModel;
