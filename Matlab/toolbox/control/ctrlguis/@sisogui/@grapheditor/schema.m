function schema
%SCHEMA  Schema for abstract graphical editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $ $Date: 2002/04/10 05:02:27 $

% Register class 
c = schema.class(findpackage('sisogui'), 'grapheditor');

% Data and graphical components
schema.prop(c,'Axes','handle vector');        % Host axes (@axesgroup object)
schema.prop(c,'ConstraintEditor','handle');   % Design constraint editor (@tooldlg instance)
schema.prop(c,'EditedObject','handle');       % Handle to edited model object
% REVISIT: should be handle matrix
schema.prop(c,'EditedPZ','MATLAB array');     % Edited poles and zeros (@pzview objects)
schema.prop(c,'EventManager','handle');       % Event coordinator (@framemgr object)
schema.prop(c,'LoopData','handle');           % Handle to @loopdata repository
schema.prop(c,'TextEditor','handle');         % Text editor for EditedObject

schema.prop(c,'MenuAnchors','handle vector'); % Edit menus for Editor

% Style parameters
schema.prop(c,'LabelColor','MATLAB array');      % Label, ruler, and grid color
schema.prop(c,'LineStyle','MATLAB array');       % Style parameters

% Modes.  Possible mode values are
%     EditMode:     [{off}|idle|addpz|deletepz|zoom]
%     EditModeData: addpz --> Root   = [pole|zero]
%                             Group  = [real|complex|lead|lag|notch]
%                    zoom --> Type   = [in-x|in-y|x-y]
%     RefreshMode:  [{normal}|quick]
p = schema.prop(c,'EditMode','string');             % Edit mode 
set(p,'AccessFlags.Init','on','FactoryValue','off');     
schema.prop(c,'EditModeData','MATLAB array');       % Edit mode data & submodes
p = schema.prop(c,'RefreshMode','string');          % Refresh mode
set(p,'AccessFlags.Init','on','FactoryValue','normal');  
schema.prop(c,'Visible','on/off');                  % Editor visibility

% Private properties
p(1) = schema.prop(c,'HG','MATLAB array');          % HG objects (struct)
p(2) = schema.prop(c,'SingularLoop','bool');        % Flags singular loop 
p(3) = schema.prop(c,'Listeners','handle vector');  % Listeners
p(4) = schema.prop(c,'XLabelVisible','on/off');     % Visibility of X labels
p(5) = schema.prop(c,'YLabelVisible','on/off');     % Visibility of Y labels

% ATTN: Temporary fix. Revert back when properties can be changed in local
% functions within the class methods of bodeditorF 
%set(p(1:2),'AccessFlags.PublicSet','off');    % allow get for qe testing
set(p(2),'AccessFlags.PublicSet','off');    % allow get for qe testing
set(p(3:5),'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');
