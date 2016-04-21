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
%    $Revision: 1.13.2.6 $  $Date: 2003/12/04 18:38:25 $

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

% =============================================================================
% AI - OBJECT PROPERTY VARIABLES:
% =============================================================================
objprops={...
      'Running',          'SampleRate',        'SamplesAcquired',...
      'SamplesAvailable', 'SamplesPerTrigger', 'Logging',...
      'LoggingMode',      'LogToDiskMode',     'TriggerType',...
      'TriggerRepeat',    'TriggersExecuted'};

nprops = length(objprops);
ObjVals = cell(1,nprops);
for p=1:nprops,
   ObjVals{1,p} = daqmex(obj,'get',objprops{p});
end

[     Run,                SmplRt,              SmplAcq,...
      SmplAvl,            SmplPerTrg,          Log,...
      LogMode,            Log2DiskMode,        TrgTyp,...
      TrgRpt,             TrgTm ] = deal(ObjVals{:});

% =============================================================================
% DYNAMIC DISPLAY BEGINS HERE...
% =============================================================================

% Displaying:  " Display Summary of Analog Input (AI) Object Using 'Sound Blaster Record'. "
strind = findstr(lower(info.child),lower(info.childconst));
objInitials = upper(info.childconst(1:strind-1));
st='';
st=[st  sprintf('Display Summary of%s %s (%s) Object Using ''%s''.\n','',objtype,objInitials,devname)];
st=[st  sprintf(newline)];

% Indentation format for each subject line.
format='%27s';

% Acquisition Parameters:
st=[st sprintf(format,'Acquisition Parameters:  ')];
st=[st sprintf('%0.10g samples per second on each channel.\n',SmplRt)];

st=[st sprintf(format,' ')];

if SmplPerTrg==Inf,
   st=[st sprintf('Continuous sampling on each channel.\n')];
else
   st=[st sprintf('%d samples per trigger on each channel.\n',SmplPerTrg)];
end

st=[st sprintf(format,' ')];

if strcmp(TrgTyp,'Immediate'),
	if (SmplRt == 0)
		time = 0;
	else
 	 	time = (SmplPerTrg/SmplRt)*(TrgRpt+1);
	end
   if time == floor(time),
      st=[st sprintf(['%d ', 'sec. of data to be logged upon START.\n'],time)];
   else
      st=[st sprintf(['%2.4g ', 'sec. of data to be logged upon START.\n'],time)];
   end  
else
   	if (SmplRt == 0)
		time = 0;
	else
		time = SmplPerTrg/SmplRt;
	end
   if time == floor(time),
      st=[st sprintf(['%d ', 'sec. of data to be logged per trigger.\n'],time)];
   else
      st=[st sprintf(['%2.4g ', 'sec. of data to be logged per trigger.\n'],time)];
   end  
end

st=[st sprintf(format,' ')];

switch LogMode,
case 'Disk',
   st=[st sprintf('Log data to ''%s'' on trigger.\n',LogMode)];
   st=[st sprintf(format,' ')];
   st=[st sprintf('''%s'' data to file on trigger.\n',Log2DiskMode)];
case 'Disk&Memory',
   st=[st sprintf('Log data to ''%s'' on trigger.\n',LogMode)];
   st=[st sprintf(format,' ')];
   st=[st sprintf('''%s'' data to file on trigger.\n',Log2DiskMode)];
otherwise
   st=[st sprintf('Log data to ''%s'' on trigger.\n',LogMode)];
end

st=[st sprintf(newline)];

% Trigger Parameters:
st=[st sprintf(format,'Trigger Parameters:  ')];
trgstr = '';
switch TrgTyp,
case 'Immediate'
   st=[st sprintf('%d ''%s'' trigger(s) on START.\n',TrgRpt+1,TrgTyp)];
case 'Manual'
   trgstr = 'TRIGGER';
   st=[st sprintf('%d ''%s'' trigger(s) on TRIGGER.\n',TrgRpt+1,TrgTyp)];
otherwise
   st=[st sprintf('%d ''%s'' trigger(s).\n',TrgRpt+1,TrgTyp)];
end

st=[st sprintf(newline)];

% Engine status:
st=[st sprintf(format,'Engine status:  ')];
ison = strcmp({Log, Run}, {'On', 'On'});
Running = ison(2);
switch sum(ison),
case 0,
   st=[st  sprintf('%s\n','Waiting for START.')];
case 1,
   if Running,
      % Determine which trigger we're waiting for.
      trigL = TrgTm;
      trigN = trigL+1;
      
      % In case we have triggered all we will want, but have not stopped yet,
      % we will not display....waiting for trigger 3 of 2.
      if trigN > TrgRpt+1,
         trigN = TrgRpt;
      end      
         
      if isempty(trgstr),
         % May not ever really need this, since  this is for immediate triggers.
         st=[st  sprintf('%s %d of %d.\n','Waiting for trigger',trigN,TrgRpt+1)];
      else
         st=[st  sprintf('%s %d of %d.\n','Waiting for TRIGGER',trigN,TrgRpt+1)];
      end      
   else
      st=[st  sprintf('%s\n','Not running but logging...how can this be?')];
   end   
case 2,
   st=[st  sprintf('%s\n','Logging data.')];
end

st=[st sprintf(format,' ')];

st=[st sprintf('%d samples acquired since starting.\n',SmplAcq)];

st=[st sprintf(format,' ')];

st=[st sprintf('%d samples available for GETDATA.\n',SmplAvl)];

st=[st  sprintf(newline)];

% Display children info:
st=[st  sprintf('%s object contains ',objInitials)];
fprintf(fid,st)
daqgate('childdisp',obj, info, fid, newline);