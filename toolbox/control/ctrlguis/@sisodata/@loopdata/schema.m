function schema
% Defines properties for @loopdata class

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2002/06/11 17:30:08 $

c = schema.class(findpackage('sisodata'),'loopdata');

% Public properties
schema.prop(c,'Compensator','handle');     % Data for compensator C (@tunedmodel object)
schema.prop(c,'Configuration','double');   % Loop configuration
schema.prop(c,'FeedbackSign','double');    % Feedback sign
schema.prop(c,'Filter','handle');          % Data for compensator F (@tunedmodel object)
schema.prop(c,'Plant','handle');           % Plant data (@fixedmodel object)
schema.prop(c,'SavedDesigns','MATLAB array');   % Design history
schema.prop(c,'Sensor','handle');          % Sensor data (@fixedmodel object)
schema.prop(c,'SystemName','string');      % Control system name
schema.prop(c,'Ts','double');              % Sample time

% Private properties
p(1) = schema.prop(c,'ClosedLoop','MATLAB array');  % Closed loop model
p(2) = schema.prop(c,'Margins','MATLAB array');     % Stability margins
p(3) = schema.prop(c,'MinorLoop','MATLAB array');   % Minor loop formed by filter in configuration 4
p(4) = schema.prop(c,'OpenLoop','MATLAB array');    % (Normalized) open loop
p(5) = schema.prop(c,'Listeners','handle vector');  % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

% Events
schema.event(c,'LoopDataChanged');    % Change in loop data
schema.event(c,'FirstImport');        % First data import
schema.event(c,'MoveGain');           % Dynamic gain update (start/finish)
schema.event(c,'MovePZ');             % Dynamic pole/zero update (start/finish)
schema.event(c,'SingularInnerLoop');  % Algebraic loop in inner loop (config 4)
