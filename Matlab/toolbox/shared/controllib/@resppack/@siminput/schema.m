function schema
%SCHEMA  Defines properties for @siminput class

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:32 $
superclass = findclass(findpackage('wavepack'), 'waveform');
c = schema.class(findpackage('resppack'), 'siminput', superclass);

schema.prop(c, 'ChannelName', 'string vector');   % input channel names
schema.prop(c, 'Interpolation', 'string');        % interpolation method
