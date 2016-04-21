function disp(obj)
%DISP Display method for data acquisition objects.
%
%    DISP(OBJ) dynamically displays information pertaining to data
%    acquisition object OBJ.
%

%    To expand the display, only two variables should be modified:
%      1) OBJPROPS (along with its' list of corresponding variable names)
%      2) CHILDPROPS ( See private/childdisp. )
%
%    OBJPROPS is the list of OBJ properties used for the dynamic
%    display.  Changing OBJPROPS may require re-formatting the dynamic
%    display a bit.

%    OBJ fields:
%       .handle     - hidden unique handle from DAQMEX associated with the
%                     channel.
%       .version    - class version number.
%       .info       - Structure containing strings used to provide object
%                     methods with information regarding the object.  Its
%                     fields are:
%                       .prefix     - 'a' or 'an' prefix that would preceed the
%                                     object type name.
%                       .objtype    - object type with first characters capitalized.
%                       .addchild   - method name to add children, ie. 'addchannel'
%                                     or 'addline'.
%                       .child      - type of children associated with the object
%                                     such as 'Channel' or 'Line'.
%                       .childconst - constructor used to create children, ie. 'aichannel',
%                                     'aochannel' or 'dioline'.

%    MP 3-29-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.6 $  $Date: 2003/12/04 18:38:33 $

if length(obj)>1
    display(obj);
    return;
elseif ~all(isvalid(obj))
   disp([...
         'Invalid Data Acquisition object.', sprintf('\n'),...
         'This object is not associated with any hardware and',sprintf('\n'),...
         'should be removed from your workspace using CLEAR.',sprintf('\n')]);
   return
end

% File identifier...fid=1 outputs to the screen.
fid=1;

% Determine if we want a compact or loose display.
isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

% Get the structure containing object descriptions.
s=struct(obj);
info=s.info;
objtype=info.objtype;

% Find the device name and port information.  DAQHWINFO needs to be
% called rather than daqmex since the Port structure is created within
% DAQHWINFO M-code.
hw = daqhwinfo(obj);
devname = hw.DeviceName;
portinfo = hw.Port;

% ==========================================================================================
% DYNAMIC DISPLAY BEGINS HERE...
% ==========================================================================================

% Displaying:  " Display Summary of Analog Input (AI) Object Using 'Sound Blaster Record'. "
strind = findstr(lower(info.child),lower(info.childconst));
objInitials = upper(info.childconst(1:strind-1));
fprintf(fid,'Display Summary of%s %s (%s) Object Using ''%s''.\n','',objtype,objInitials,devname);
fprintf(fid,newline);

% Indentation format for each subject line.
format='%27s';

% Port Parameters:
fprintf(fid,format,'Port Parameters:  ');
for i = 1:length(portinfo)
   
   % Translate the direction into reading and writing.
   switch portinfo(i).Direction
   case 'in'
      portdir = 'reading';
   case 'out'
      portdir = 'writing';
   case 'in/out'
      portdir = 'reading and writing';
   end 
   
   % Write the port parameter information.
   fprintf(fid, 'Port %d is %s configurable for %s.\n', portinfo(i).ID,...
      portinfo(i).Config, portdir);
   
   fprintf(fid,format,' ')
end

fprintf(fid, newline);

% Engine status. The Engine status is dependent upon whether the 
% TimerFcn is defined and whether the engine is running.
timerFcn = daqmex(obj, 'get', 'TimerFcn');
ison = strcmp(lower(get(obj, 'Running')), 'on');

fprintf(fid,format,'Engine status:  ');
switch isempty(timerFcn)
case 0
   % TimerFcn is defined.  Display the message which is dependent
   % upon whether or not the engine is running.
   switch ison
   case 0 
      % Engine is not running.
      fprintf(fid, 'Waiting for START.\n');
   case 1
      % Engine is running.
      fprintf(fid, 'Running.\n');
   end
case 1
   % TimerFcn is not defined.
   fprintf(fid, 'Engine not required.\n');
end

% Display children info:
fprintf(fid, newline);
fprintf(fid,'%s object contains ',objInitials);
daqgate('childdisp',obj, info, fid, newline);