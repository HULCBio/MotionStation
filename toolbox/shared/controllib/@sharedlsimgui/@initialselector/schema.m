function schema
% SCHEMA  Defines properties for @intialselector class

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:46 $

% Register class 
c = schema.class(findpackage('sharedlsimgui'), 'initialselector');

% Properties

% Strucure of java handles describing import data GUI frame
schema.prop(c, 'importhandles', 'MATLAB array');
% workspace @varbrowser
schema.prop(c, 'workbrowser', 'handle');
schema.prop(c, 'frame','com.mathworks.mwswing.MJDialog');



