function schema
%  SCHEMA  Defines properties for LinearAnalysisResultNode class

%  Author(s): 
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:35:42 $

% Find parent package
pkg = findpackage('GenericLinearizationNodes');

% Find parent class (superclass)
supclass = findclass(pkg, 'LinearAnalysisResultNode');

% Register class (subclass) in package
inpkg = findpackage('mpcnodes');
c = schema.class(inpkg, 'LinearAnalysisResultNode', supclass);
