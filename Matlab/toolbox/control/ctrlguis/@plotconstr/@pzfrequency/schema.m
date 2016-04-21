function schema
% Defines properties for @pzfrequency class
%      Natural frequency constraint in pole/zero plots

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:10:20 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'pzfrequency',findclass(pk,'designconstr'));

% Editor data
schema.prop(c,'Frequency','double');         % Specified natural frequency (rad/sec)
schema.prop(c,'FrequencyUnits','String');    % Frequency units currently in use
schema.prop(c,'Ts','double');                % Current sampling time
