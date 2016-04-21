function valveHdls = valve(varargin)
%VALVE  Draw an automatically controlled valve

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/10 06:42:12 $

%---Default properties
p = struct(...
   'Parent',[],...
   'Position',[0 0],...
   'Size',1,...
   'Angle',0,...
   'LineWidth',2,...
   'LineStyle','-',...
   'Color','k',...
   'Clipping','off', ...
   'FaceColor','r', ...
   'EdgeColor','k');
plist = fieldnames(p);

%---Merge user-specified properties
for i=1:2:nargin-1
   Property = pnmatch(varargin{i},plist);
   Value = varargin{i+1};
   p.(Property) = Value;
end
if isempty(p.Parent), p.Parent = gca; end

%***************************************************************************************************
% Scaling factor in the x direction
q = 3;

% Draw the valve hood
hood_radius = 0.7;	hood_radius = hood_radius/2;	aspect_height = 0.5;
x_hood_centre = p.Position(1) + 0.5;
y_hood_bottom = p.Position(2) + q*0.12;

x_hood = x_hood_centre + (cos((0:5:180)*pi/180))*hood_radius;
y_hood = y_hood_bottom +  (2*sin((0:5:180)*pi/180))*aspect_height*hood_radius;

% Fill in the valve hood
Hood = patch( ...
	'Parent',p.Parent, ...
	'XData',p.Size*x_hood, ...
	'YData',p.Size*y_hood, ...
	'FaceColor',p.FaceColor, ...
	'EdgeColor',p.EdgeColor);

% Draw the valve input, output and stem
x_lhs_triangle = [ 0.0 0.5 NaN 0.0 0.5 NaN  0.0 0.0];
y_lhs_triangle = q*[-0.1 0.0 NaN 0.1 0.0 NaN -0.1 0.1];

x_rhs_triangle = [ 1.0 0.5 NaN 1.0 0.5 NaN 1.0  1.0];
y_rhs_triangle = q*[-0.1 0.0 NaN 0.1 0.0 NaN 0.1 -0.1];

x_stem = [0.5 0.5  NaN 0.15 0.85];
y_stem = q*[0.0 0.12 NaN 0.12 0.12];

x = [x_lhs_triangle x_rhs_triangle x_stem (x_hood - p.Position(1))];
y = [y_lhs_triangle y_rhs_triangle y_stem (y_hood - p.Position(2))];

line_Hdl = line(...
   'Parent',p.Parent,...
   'XData',p.Size*(p.Position(1) + x), ...
   'YData',p.Size*(p.Position(2) + y), ...   
   'LineWidth',p.LineWidth,...
   'LineStyle',p.LineStyle,...
   'Color',p.Color,...
   'Clipping',p.Clipping);

% Fill in the valve input, output and stem
x_lhs_patch = p.Position(1) + [0 0.5 0];
y_lhs_patch = p.Position(2) + q*[-0.1 0.0 0.1];

x_rhs_patch = p.Position(1) + [0.5  1.0 1.0];
y_rhs_patch = p.Position(2) + q*[0.0 -0.1 0.1];

x_patch = [x_lhs_patch x_rhs_patch]';
y_patch = [y_lhs_patch y_rhs_patch]';
all_patches = p.Size*[x_patch y_patch];

% Define how the faces are connected
faces_matrix = [1 2 3;4 5 6];
LRPorts = patch('Parent',p.Parent,'Vertices',all_patches,'Faces',faces_matrix,'FaceColor',p.FaceColor);

% Store the handles in an array
valveHdls = [Hood, LRPorts];

% Draw the arrow head to indicate it is a "fail shut valve"
x_arrow = p.Position(1) + [0.5 0.4 0.6]';
y_arrow = p.Position(2) + [0.0 0.2  0.2]';
all_patches = p.Size*[x_arrow y_arrow];

% Define how the faces are connected
faces_matrix = [1 2 3];
arrow_Hdls = patch(	'Parent',p.Parent,'Vertices',all_patches,'Faces',faces_matrix,'FaceColor',[0 0 0]);
