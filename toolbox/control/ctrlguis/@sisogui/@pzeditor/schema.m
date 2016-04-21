function schema
% Defines properties for @pzeditor class

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 04:55:34 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'pzeditor');

% Data properties
schema.prop(c,'EditedObject','handle');         % Handle to edited model object
schema.prop(c,'LoopData','handle');             % Handle to model database
schema.prop(c,'Parent','handle');               % Parent object (@sisotool)
hpz = schema.prop(c,'PZGroup','handle vector'); % Internal pole/zero groups

% Public properties
schema.prop(c,'FontSize','MATLAB array');            % Font size
hf = schema.prop(c,'Format','string');          % Format [{RealImag}|[Damping}]
schema.prop(c,'FrequencyUnits','string');       % Frequency units
hg = schema.prop(c,'HG','MATLAB array');             % HG database
schema.prop(c,'Visible','on/off');        % Editor visibility

% Defaults and accesses
set(hpz,'AccessFlags.AbortSet','off');     % To sync up
set(hf,'AccessFlags.Init','on','FactoryValue','RealImag');
set(hg,'AccessFlags.PublicSet','off');

% Private properties
p(1) = schema.prop(c,'Listeners','handle vector');          % Listeners
p(2) = schema.prop(c,'TargetListeners','handle vector');    % Listener to EditedObject
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

% Hidden modes
%     EditMode:     [{off}|idle]
p = schema.prop(c,'EditMode','string');       
set(p,'AccessFlags.PublicSet','off',...
    'AccessFlags.Init','on','FactoryValue','off');
