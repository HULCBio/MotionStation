function mech_toroid_setup(ModelName)
% This script sets up a toroid in the workspace for the SimMechanics demo
% mech_toroid. It also renders the toroid point-curve in the SimMechanics
% visualization window.

% Copyright 2004 The MathWorks, Inc.

if nargin < 1
    [X,Y,Z] = create_toroid_points;
    assignin('base','toroid_X',X);
    assignin('base','toroid_Y',Y);
    assignin('base','toroid_Z',Z);
else
    plot_toroid(ModelName);
end
%------------------------------------------------------------------------
function [X,Y,Z] = create_toroid_points
% Creates the toroid with the parameters specified

r = 2;
R = 10;
w1 = 50;
w2 = 1;
t = 0:0.01:2*pi;
%------------------------
x = r * cos (w1*t);
y = r * sin (w1*t);

X = (R + x) .* cos (w2*t);
Z = (R + x) .* sin (w2*t);
Y = y;
%------------------------------------------------------------------------
function plot_toroid(ModelName)
% Plots the point curve in SimMechanics visualization.
%
% This functionality is not supported externally and can change without
% notice or backwards compatibility.

ModelH = get_param(ModelName,'Handle');
if isequal(get_param(ModelH,'Open'),'on')
    [X,Y,Z] = create_toroid_points;
    % Draw point-curve    
    FigH = feature('SimMechanicsGetVisualizationId', ModelH);
    axesH = get(FigH,'CurrentAxes');
    plot3(X,Y,Z,'Parent',axesH);
end
%------------------------------------------------------------------------