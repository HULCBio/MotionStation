function schema
% Defines properties for @pzsettling class

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:08:28 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'pzsettling',findclass(pk,'designconstr'));

% Editor data
schema.prop(c,'SettlingTime','double');   % Specified settling time
schema.prop(c,'Ts','double');             % Current sampling time
