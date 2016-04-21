function schema
% SCHEMA  Defines properties for @table class

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:04 $

% Find parent package

pkg = findpackage('sharedlsimgui');

% Register class (subclass)
superclass = findclass(findpackage('sharedlsimgui'), 'abstractimporttable');
c = schema.class(findpackage('sharedlsimgui'), 'table', superclass);

pkg.JavaPackage  =  'com.mathworks.toolbox.control.spreadsheet';
c.JavaInterfaces = {'com.mathworks.toolbox.control.spreadsheet.SheetObject'};

% Properties

p = schema.prop(c, 'celldata','MATLAB array'); % 1xn data populating spreadsheet (doubles or string only)
set(p,'AccessFlags.PublicSet','off'); 
schema.prop(c, 'colnames','MATLAB array');   
schema.prop(c, 'importSelector','handle'); % Handle to importselector
schema.prop(c, 'menulabels','MATLAB array');
p = schema.prop(c, 'leadingcolumn','on/off'); 
p.FactoryValue = 'on';
p = schema.prop(c, 'readonly','on/off');
p.FactoryValue = 'off';
schema.prop(c, 'readonlycols','MATLAB array');
schema.prop(c, 'readonlyrows','MATLAB array');
schema.prop(c, 'STable','com.mathworks.toolbox.control.spreadsheet.STable'); % STable handle
schema.prop(c, 'userdata','MATLAB array'); 

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'on', 'AccessFlags.PublicSet', 'on');

% define events
schema.event(c,'rightmenuclick'); 
schema.event(c,'rightmenuselect');
schema.event(c,'userentry');
schema.event(c,'tablecellchanged');

if isempty(javachk('jvm'))
  % Define signatures for overridden method
  % inserted new
 
  m1 = schema.method(c, 'getColNames');
  s1 = m1.Signature;
  s1.varargin    = 'off';
  s1.InputTypes  = {'handle'};
  s1.OutputTypes = {'java.lang.String[]'};
  
  m2 = schema.method(c, 'sizeof');
  s2 = m2.Signature;
  s2.varargin    = 'off';
  s2.InputTypes  = {'handle'};
  s2.OutputTypes = {'java.lang.Double[]'}; 

  m3 = schema.method(c, 'resetCells');
  s3 = m3.Signature;
  s3.varargin    = 'off';
  s3.InputTypes  = {'handle','java.lang.String[][]'};
  s3.OutputTypes = {'double'}; 
 
  m4 = schema.method(c, 'getmenus');
  s4 = m4.Signature;
  s4.varargin    = 'off';
  s4.InputTypes  = {'handle'};
  s4.OutputTypes = {'java.lang.String[]'}; 
  
  m6 = schema.method(c, 'javasend');
  s6 = m6.Signature;
  s6.varargin    = 'off';
  s6.InputTypes  = {'handle','string','string'};
  s6.OutputTypes = {}; 

  m7 = schema.method(c, 'geteditcols');
  s7 = m7.Signature;
  s7.varargin    = 'off';
  s7.InputTypes  = {'handle'};
  s7.OutputTypes = {'java.lang.Boolean[]'}; 
  
  m8 = schema.method(c, 'getCells');
  s8 = m8.Signature;
  s8.varargin    = 'off';
  s8.InputTypes  = {'handle'};
  s8.OutputTypes = {'java.lang.String[][]'};
    
  m9 = schema.method(c, 'geteditrows');
  s9 = m9.Signature;
  s9.varargin    = 'off';
  s9.InputTypes  = {'handle'};
  s9.OutputTypes = {'java.lang.Boolean[]'}; 
end
