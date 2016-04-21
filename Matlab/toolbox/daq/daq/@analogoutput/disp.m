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

%    CP 4-19-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.10.2.6 $  $Date: 2003/12/04 18:38:28 $

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

% Find the device name:
hw = daqmex(obj, 'daqhwinfo');
devname = hw.DeviceName;

% ==========================================================================================
% AO - OBJECT PROPERTY VARIABLES:
% ==========================================================================================
objprops={...
      'Running',           'SampleRate',     'SamplesOutput', ...
      'SamplesAvailable',  'Sending',        'TriggerType', ...
      'RepeatOutput' };

nprops = length(objprops);
ObjVals = cell(1,nprops);
for p=1:nprops,
   ObjVals{1,p} = daqmex(obj,'get',objprops{p});
end

[     Run,         SmplRt,   SmplOut, ...
      SmplAvl,     Send,     TrgTyp, ...
      RptOut      ] = deal(ObjVals{:});

% ==========================================================================================
% DYNAMIC DISPLAY BEGINS HERE...
% ==========================================================================================

% Displaying:  " Display Summary of Analog Output (AO) Object Using 'Sound Blaster Playback'. "
strind = findstr(lower(info.child),lower(info.childconst));
objInitials = upper(info.childconst(1:strind-1));
fprintf(fid,'Display Summary of%s %s (%s) Object Using ''%s''.\n','',objtype,objInitials,devname);
fprintf(fid,newline);

% Indentation format for each subject line.
format='%27s';

% Output Parameters:
fprintf(fid,format,'Output Parameters:  ')
fprintf(fid,'%0.10g samples per second on each channel.\n',SmplRt)

fprintf(fid,newline)

% Trigger Parameters:
fprintf(fid,format,'Trigger Parameters:  ')
trgstr = '';
switch TrgTyp,
case 'Immediate'
   fprintf(fid,'1 ''%s'' trigger on START.\n',TrgTyp)
case 'Manual'
   trgstr = 'TRIGGER';
   fprintf(fid,'1 ''%s'' trigger on TRIGGER.\n',TrgTyp)
otherwise
   fprintf(fid,'1 ''%s'' trigger.\n',TrgTyp)
end

fprintf(fid,newline)

% Engine status:
fprintf(fid,format,'Engine status:  ')
ison = strcmp({Send, Run}, {'On', 'On'});
Running = ison(2);
switch sum(ison),
case 0,
   fprintf(fid,'%s\n','Waiting for START.');
case 1,
   if Running,
      if isempty(trgstr),
         fprintf(fid,'%s\n','Waiting for trigger.');
      else
         fprintf(fid,'%s\n','Waiting for TRIGGER.');
      end      
   else
      fprintf(fid,'%s\n','Not running but sending...how can this be?');
   end   
case 2,
   fprintf(fid,'%s\n','Sending data.');
end

fprintf(fid,format,' ')

% Catch Inf repeat outputs to avoid 0*Inf to produce NaNs.
if isinf(RptOut),
   temptime = RptOut;
else
	if (SmplRt == 0)
		temptime = 0;
	else
		temptime = (SmplAvl/SmplRt)*(RptOut+1);
	end
end
if strcmp(TrgTyp,'Immediate'),
    if temptime == floor(temptime),
        fprintf(fid,'%d total sec. of data currently queued for START.\n',temptime)
    else      
        fprintf(fid,'%2.4g total sec. of data currently queued for START.\n',temptime)
    end   
else
    if temptime == floor(temptime),
        fprintf(fid,'%d total sec. of data currently queued per trigger.\n',temptime)
    else
        fprintf(fid,'%2.4g total sec. of data currently queued per trigger.\n',temptime)
    end   
end

fprintf(fid,format,' ')

fprintf(fid,'%d samples currently queued by PUTDATA.\n',SmplAvl)

fprintf(fid,format,' ')

fprintf(fid,'%d samples sent to output device since START.\n',SmplOut)

fprintf(fid,newline);

% Display children info:
fprintf(fid,'%s object contains ',objInitials);
daqgate('childdisp',obj, info, fid, newline);