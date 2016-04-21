function schema
% A helper function for CFTOOL

% $Revision: 1.28.2.1 $  $Date: 2004/02/01 21:38:40 $
% Copyright 2001-2004 The MathWorks, Inc.


pk = findpackage('cftool');

% Create a new class called data

c = schema.class(pk, 'fit');

% Add properties

% the fit itself (a cfit object)
p=schema.prop(c, 'fit', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

p=schema.prop(c, 'isGood', 'bool');

% the dataset for this fit
p=schema.prop(c, 'dshandle', 'MATLAB array');
p.AccessFlags.Serialize='off';

% the options for this fit
p=schema.prop(c, 'fitOptions', 'handle');

% labels
schema.prop(c, 'name', 'string');
schema.prop(c, 'type', 'string');
schema.prop(c, 'dataset', 'string');
schema.prop(c, 'results', 'string');
p=schema.prop(c, 'outlier', 'string');

% goodness
p=schema.prop(c, 'goodness', 'MATLAB array');
p=schema.prop(c, 'sse', 'double');
p=schema.prop(c, 'rsquare', 'double');
p=schema.prop(c, 'adjsquare', 'double');
p=schema.prop(c, 'rmse', 'double');
p=schema.prop(c, 'dfe', 'double');
p=schema.prop(c, 'ncoeff', 'double');

% output
p=schema.prop(c, 'output', 'MATLAB array');

% ingredients for confidence bounds
schema.prop(c, 'R', 'MATLAB array');

% a place to store plotting state
p=schema.prop(c, 'plot', 'int32');
p.AccessFlags.Serialize='off';
p=schema.prop(c, 'line', 'MATLAB array');
p.AccessFlags.Serialize='off';
p=schema.prop(c, 'rline', 'MATLAB array');   % residual line
p.AccessFlags.Serialize='off';

% A hint to make it easier to open in the editor.  Also used by
% code generation.
schema.prop(c, 'hint', 'string');

% starting values
schema.prop(c, 'start', 'MATLAB array');

% x and y limits
schema.prop(c, 'xlim', 'MATLAB array');
schema.prop(c, 'ylim', 'MATLAB array');

% a place to store listeners
p=schema.prop(c, 'listeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

% Remember line color, marker, style, etc.
p=schema.prop(c, 'ColorMarkerLine', 'MATLAB array');
