function name = getltiname(this,info)
%GETLTINAME  Adds a buttondownfcn to each curve in each view object

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:49 $

%% Get Model Name
sys_name = this.Name;
%% Get Model Size
sys_size = size(this.Model);
%% Get LTI Model Coordinates
if length(sys_size) > 2 
    ind = rguihelper('ind2sub',sys_size(3:end),info.ViewNumber);
else
    ind = 1;
end
%% Get I/O Dimensions
io_dim = sys_size(1:2);
%% Create String
name = rguihelper('labelsystem',sys_name,info.Row,info.Col,ind,io_dim,sys_size,'step');
