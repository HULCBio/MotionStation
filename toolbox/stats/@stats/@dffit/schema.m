function schema
%SCHEMA Definition of distfit virtual class for dfittool function

% $Revision: 1.1.8.7 $  $Date: 2004/01/24 09:32:51 $
% Copyright 2003-2004 The MathWorks, Inc.

pk = findpackage('stats');
c = schema.class(pk, 'dffit');

% Properties specified at creation
p=schema.prop(c, 'name', 'string');                % fit name
p=schema.prop(c, 'dataset', 'string');             % dataset name
p=schema.prop(c, 'dshandle', 'MATLAB array');      % data set being fitted
p.AccessFlags.Serialize='off';
p=schema.prop(c, 'fitframe', 'com.mathworks.toolbox.stats.DFFrame'); % dfittool gui new/edit frame
p.AccessFlags.Serialize='off';
p=schema.prop(c, 'fittype', 'string');             % 'param' or 'smooth'
p=schema.prop(c, 'exclusionrulename', 'string');   % exclusion rule name
p=schema.prop(c, 'exclusionrule', 'MATLAB array'); % exclusion rule used
p.AccessFlags.Serialize='off';

% ... if fit type is 'smooth'
p=schema.prop(c, 'kernel', 'string');            % name of smoothing kernel
p=schema.prop(c, 'bandwidth', 'MATLAB array');   % kernel width (empty to use default)
p=schema.prop(c, 'bandwidthtext', 'string');     % GUI kernel width 
p=schema.prop(c, 'bandwidthradio','double');     % radio button state for bandwidth 0 = auto, 1 = specify
p=schema.prop(c, 'supportradio','double');       % radio button state for domain 0 = unbounded, 1 = positive, 2 = specify
p=schema.prop(c, 'supportlower','string'); % lower limit text box contents
p=schema.prop(c, 'supportupper','string'); % upper limit text box contents

% ... if fit type is 'parametric'
p=schema.prop(c, 'distname', 'string');          % name of probability distribution
p=schema.prop(c, 'pfixed', 'MATLAB array');      % logical vector of fixed parameters
p=schema.prop(c, 'pfixedtext', 'string vector'); % GUI vector of fixed parameters as strings
p=schema.prop(c, 'pestimated', 'NReals');        % GUI 1 = estimated, 0 = fixed;

% Properties derived from creation values
p=schema.prop(c, 'distspec', 'MATLAB array'); % distribution properties from dfgetdistributions (empty for smooth fit)
p=schema.prop(c, 'support', 'MATLAB array');  % extent of distribution
p=schema.prop(c, 'isgood', 'bool');          % true if fit is calculated

% Results from fit
p=schema.prop(c, 'params', 'MATLAB array'); % parameter values (empty if smooth)
p=schema.prop(c, 'pcov', 'MATLAB array');   % estimated coovariance of params
p=schema.prop(c, 'loglik', 'double');       % log likelihood
p=schema.prop(c, 'resultstext', 'string');  % results

% Properties of the GUI, set into each object at any time
p=schema.prop(c, 'conflev', 'double');       % confidence level, 0<clev<1
p=schema.prop(c, 'ftype', 'string');         % function type: cdf, pdf, etc.
p=schema.prop(c, 'enablebounds', 'double');  % 0 = disable bounds field, 1 = enable bounds field

% Graph-related properties
p=schema.prop(c, 'numevalpoints', 'int32');  % number of evaluation points
p=schema.prop(c, 'x', 'MATLAB array');       % evaluation locations
p=schema.prop(c, 'y', 'MATLAB array');       % evaluation of function at x
p=schema.prop(c, 'ybounds', 'MATLAB array'); % confidence bounds on y
p=schema.prop(c, 'linehandle', 'MATLAB array'); % handle of plotted line
p=schema.prop(c, 'boundline', 'MATLAB array');  % handle of conf bnds line

schema.prop(c, 'xlim', 'MATLAB array');      % x limits
schema.prop(c, 'ylim', 'MATLAB array');      % y limits

p=schema.prop(c, 'plot', 'int32');           % true to plot
p.AccessFlags.Serialize='off';
p=schema.prop(c, 'showbounds', 'int32');     % true if conf bnds requested
p=schema.prop(c, 'listeners', 'MATLAB array'); % storage array for listeners
p.AccessFlags.Serialize = 'off';

p=schema.prop(c, 'ColorMarkerLine', 'MATLAB array');  % line properties (cell)


