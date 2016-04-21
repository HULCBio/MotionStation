function schema
%SCHEMA  Class definition for @wavechar (waveform characteristics).

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:03 $
superclass = findclass(findpackage('wrfc'),'dataview');
c = schema.class(findpackage('wavepack'), 'wavechar', superclass);

schema.prop(c,'Identifier','string');   % Constraint type identifier