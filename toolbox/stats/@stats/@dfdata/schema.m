function schema
%
% $Revision: 1.1.6.6 $	   $Date: 2004/01/24 09:32:36 $
% Copyright 2003-2004 The MathWorks, Inc.

pk = findpackage('stats');

% Create a new class called dfdata: distribution fitting data set
c = schema.class(pk, 'dfdata');

% Fields from information supplied by user when data set is created
schema.prop(c, 'y',         'MATLAB array'); % data vector
schema.prop(c, 'frequency', 'MATLAB array'); % frequency/weight vector
schema.prop(c, 'censored',  'MATLAB array'); % boolean indicating censoring
schema.prop(c, 'name',      'string');       % data set name
schema.prop(c, 'yname',     'string');       % y variable name
schema.prop(c, 'freqname',  'string');       % frequency variable name
schema.prop(c, 'censname',  'string');       % censoring variable name
schema.prop(c, 'yexp',      'string');       % y expression
schema.prop(c, 'freqexp',   'string');       % frequency expression
schema.prop(c, 'censexp',   'string');       % censoring expression

% Bin width information for GUI
schema.prop(c, 'binDlgInfo', 'MATLAB array'); 
% binDlgInfo.rule = 1: Freedman, 2: Scott, 3: Num bins, 4: Integers, 5: Width
% binDlgInfo.nbinsExpr = (String for GUI) number of bins
% binDlgInfo.nbins = number of bins
% binDlgInfo.widthExpr = (String for GUI) bin width
% binDlgInfo.width = bin width
% binDlgInfo.placementRule = 1: automatic, 2: specify
% binDlgInfo.anchorExpr = (String for GUI) set boundary at
% binDlgInfo.anchor =  set boundary at
% binDlgInfo.applyToAll = 1: apply to all, 0: do not apply to all
% binDlgInfo.setDefault = 1: set default, 0: do not set default

% Fields computed from input data, but saved for convenience
schema.prop(c, 'ylength', 'double');       % length of y
schema.prop(c, 'datalo', 'double');        % min of all y values
schema.prop(c, 'datahi', 'double');        % max of all y values
schema.prop(c, 'isinteger', 'bool');       % true if all values are integers
schema.prop(c, 'iscensored','bool');       % true if censored
schema.prop(c, 'datalim', 'MATLAB array'); % [min,max] of non-censored y values
schema.prop(c, 'xlim',    'MATLAB array'); % [min,max] of xdata on plot
schema.prop(c, 'ylim',    'MATLAB array'); % [min,max] of ydata on plot
schema.prop(c, 'cdfx',    'MATLAB array'); % array of x values for cdf
schema.prop(c, 'cdfy',    'MATLAB array'); % array of y values for cdf
schema.prop(c, 'cdfLower','MATLAB array'); % lower bounds for cdf
schema.prop(c, 'cdfUpper','MATLAB array'); % upper bounds for cdf
schema.prop(c, 'plotx',   'MATLAB array'); % array of x values for plot
schema.prop(c, 'ploty',   'MATLAB array'); % array of y values for plot
schema.prop(c, 'plotbnds','MATLAB array'); % array of bounds on y for plot
schema.prop(c, 'ftype',   'string');       % function type for plotx/ploty

% Fields whose values come from interactions with the gui
p=schema.prop(c, 'plot',             'int32');        % true to plot
p.AccessFlags.Serialize = 'off';
p=schema.prop(c, 'plotok',           'int32');        % 1 if ok to plot
p=schema.prop(c, 'showbounds',       'int32');        % true to show bounds
p=schema.prop(c, 'line',             'MATLAB array'); % handle(s) for data line
p.AccessFlags.Serialize = 'off';
p=schema.prop(c, 'boundline',        'MATLAB array'); % handle(s) for bounds
p.AccessFlags.Serialize = 'off';
p=schema.prop(c, 'listeners',        'MATLAB array'); % place to store listeners
p.AccessFlags.Serialize = 'off';
p=schema.prop(c, 'ColorMarkerLine',  'MATLAB array'); % line properties (cell)
p=schema.prop(c, 'conflev',          'double');       % conf. level 0<clev<1

