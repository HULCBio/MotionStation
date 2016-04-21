function schema 

% Copyright 2004 The MathWorks, Inc.

% Abstract class for tables which receive imported data
c = schema.class(findpackage('sharedlsimgui'), 'abstractimporttable');

% Table type: state or signal
if isempty(findtype('lsimTableType'))
     schema.EnumType('lsimTableType', {'state','io'});
end

% Properties used by Import tool 
schema.prop(c,'Visible','on/off'); 
p = schema.prop(c,'Type','lsimTableType'); 
p.FactoryValue = 'io';
schema.prop(c,'Numstates','double'); 
schema.prop(c,'copieddatabuffer','MATLAB array'); 