function schema
%SCHEMA Defines properties for @timemetadata class (data set variable).
%
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:33:41 $

% Register class 
p = findpackage('tsdata');
c = schema.class(p,'timemetadata',findclass(p,'abstracttimemetadata'));

% Public properties
p = schema.prop(c,'Start','double');  
p.SetFunction = @PrivateSetStart;
p = schema.prop(c,'End','double'); 
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'Increment','double');
p.FactoryValue = NaN;
p.SetFunction = @PrivateSetIncrement;
p = schema.prop(c,'Length','MATLAB array');
p.FactoryValue = 0;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% Format and startdate props
p = schema.prop(c,'Format','string');
p.setFunction = @LocalSetFormat;
p = schema.prop(c,'Startdate','string');
p.setFunction = @LocalSetRef;


function propout = LocalSetRef(eventSrc, eventData)

% Ensures that the Startdate property is a valid datastr
% Converts to 'DD-MMM-YYYY HH:MM:SS'
if isempty(eventData)
   propout = '';
   return
end
if ischar(eventData)
	try 
        propout = datestr(eventData,0);
	catch
        error('abstracttimemetadata:LocalSetRef:invStartStr', ...
            'The startdate property must be a datestr')
	end
else
    error('abstracttimemetadata:LocalSetRef:invRef',...
        'The startdate property must be a datestr')
end

function propout = LocalSetFormat(eventSrc, eventData)

% Ensures that the Format property is a valid dateform
if isempty(eventData)
   propout = '';
   return
end
if ischar(eventData)
	try 
        datestr(0,eventData);
        propout = eventData;
	catch
        error('abstracttimemetadata:LocalSetRef:invdateform',...
            'The format property is an invalid dataform string')
	end
else
    error('abstracttimemetadata:LocalSetRef:invdateform',...
        'The format property must be a dateform string')
end





