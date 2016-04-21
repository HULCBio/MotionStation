function result = subsref(obj, Struct)
%SUBSREF Reference into data acquisition objects.
%
%    Supported syntax for device objects:
%    a = ai.samplerate;       calls    get(ai,'samplerate');
%    a = ai.channel;          calls    get(ai,'channel');
%    a = ai.channel(1:2);     calls    get(ai,'channel',[1 2]);
%    a = ai.channel(3).Units; calls    get(get(ai,'channel',3), 'Units');
%    a = ai.channel.Units;    calls    get(get(ai,'channel'), 'Units');                                  
%
%    Supported syntax for channels or lines:
%    a = obj.Units;               calls    get(obj,'Units');
%    a = obj(1:2).SensorRange;    calls    get(obj(1:2),'SensorRange');
%
%    See also DAQDEVICE/GET, ANALOGINPUT, ANALOGOUTPUT, DIGITALIO, PROPINFO, 
%    ADDCHANNEL, ADDLINE.
%

%    MP 3-26-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:39:21 $

% Initialize variables
StructL = length(Struct);

% Parse the input into PROP1 and INDEX.
try
   [prop1, index, errflag] = daqgate('privateparsechild',obj,Struct);
catch
   error('daq:subsref:unexpected', lasterr)
end

% Return empty brackets if the index is empty.
if errflag == 2 
   result = [];
   return;
end

% Error if an error occurred in privateparsechild.
if errflag
   error('daq:subsref:unexpected', lasterr)
end

% From the parsed input, obtain the information.
switch StructL
case 1
   if isempty(prop1)
      % chan([1 3])
	  % Check to see that object is a vector array
	  if length(index{1}) ~= numel(index{1})
		  error('daq:subsref:size', 'Only a row or column vector of device objects can be created.')
	  end
	  
	  try
         handles = obj.handle;
         obj.handle = handles(index{1});
         result = obj;
      catch
        error('daq:subsref:unexpected', lasterr)
      end
   else
      % INDEX = [], PROP1 = 'Property Name'
      % chan.ChannelName
      % result contains the property information.
      try
         result = get(obj, prop1);
      catch
        localCheckError;
        error('daq:subsref:unexpected', lasterr)
      end
   end
case 2
   % chan(1:2).ChannelName
   try
      % Obtain the constructor name (aichannel, aochannel, dioline)
      % and pass the handle to the constructor to get the specific
      % channel or line object.
      h = struct(obj);
      hparentstruct = struct(daqmex(obj,'get','parent'));
      constr = hparentstruct.info.childconst;
      h1 = feval(constr,h.handle(index{1}(:)));
      % result contains property information. 
      result = get(h1, prop1);
   catch
      localCheckError;
      error('daq:subsref:unexpected', lasterr)
   end
otherwise  
   error('daq:subsref:invalidsyntax', 'Invalid syntax: Too many subscripts.')
end

% *************************************************************************
% Remove any extra carriage returns.
function localCheckError

errmsg = lasterr;

while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

lasterr(errmsg);