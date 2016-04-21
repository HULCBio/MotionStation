function schema
% Defines properties for @pzdamping class

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:10:50 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'pzdamping',findclass(pk,'designconstr'));

% Editor data
p = schema.prop(c,'Format','string');     % [damping|overshoot]
set(p,'AccessFlags.Init','on','FactoryValue','damping');
schema.prop(c,'Damping','double');        % Specified damping (in [0,1])
schema.prop(c,'Ts','double');             % Current sampling time
