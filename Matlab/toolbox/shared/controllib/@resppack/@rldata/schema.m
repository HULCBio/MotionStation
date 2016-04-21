function schema
%SCHEMA  Defines properties for @rldata class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:53 $

% Find parent class (superclass)
supclass = findclass(findpackage('wrfc'), 'data');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'rldata', supclass);

% Class attributes
schema.prop(c,'Gains','MATLAB array');        % Locus gains (ngains-by-1)
schema.prop(c,'Roots','MATLAB array');        % Locus roots (ngains-by-nbranches)
schema.prop(c,'SystemGain', 'double');        % System gain
schema.prop(c,'SystemZero', 'MATLAB array');  % System zeros
schema.prop(c,'SystemPole', 'MATLAB array');  % System poles
schema.prop(c,'Ts','double');                 % Sample time (for equivalent frequency)
schema.prop(c,'XFocus', 'MATLAB array');      % X-Focus (preferred X range)
schema.prop(c,'YFocus', 'MATLAB array');      % Y-Focus (preferred Y range)
