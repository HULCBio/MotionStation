function setxpcenv(varargin)

%SETXPCENV Set xPC Target Environment Properties
%
%   SETXPCENV displays the property names and the supported property
%   values of the xPC Target environment in the MATLAB command window.
%
%   SETXPCENV(PROPERTYNAME, PROPERTYVALUE) sets the value PROPERTYVALUE
%   of the specified property PROPERTYNAME for the xPC Target environment.
%   If the value is different from the current value, the property is just
%   marked as having a new value. To finally update the environment use
%   updatexpcenv.
%
%   SETXPCENV(PROPERTYNAME1, PROPERTYVALUE1, PROPERTYNAME2, PROPERTYVALUE2, ...)
%   sets multiple property values with a single statement.
%
%   Examples  setxpcenv('HostCommPort','COM2')
%             setxpcenv('TargetScope','Enabled','TcpIpSubnetMask','255.255.255.224')
%
%   See also GETXPCENV, UPDATEXPCENV, XPCBOOTDISK, XPCSETUP

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.11.2.2 $ $Date: 2004/04/08 21:04:20 $

% check if environment mat file exists
xpcinit;

% load environment file
load(xpcenvdata);

n=length(varargin);

if n==0
   show_possible_settings(propname,actpropval);
   return;
end;


if rem(n,2)
   error('the number of input arguments must be a multiple of two');
end;

for i=1:n/2
   propn=varargin{i*2-1};
   index=strmatch(lower(propn),lower(propname));
   if isempty(index)
      error(['Invalid xPC Target environment property: ',propn]);
   end;
   if length(index)>1
      error(['Ambiguous xPC Target environment property: ',propn]);
   end;
   [err,newpropval]=set_new_value(actpropval,newpropval,index,deblank(varargin{i*2}));
   save(xpcenvdata,'propname','actpropval','newpropval');


end;


function [err,newpropval]=set_new_value(actpropval, newpropval, index, propv)

err=0;
propv=lower(propv);

switch index

 case 1
  error('property Version is read only');

 case 2
  error('property Path is read only');

 case 3
  index1=strmatch(propv,{'watcom','visualc'});
  if isempty(index1)
    error('invalid property value for property: CCompiler');
  end;
  if length(index1)>1
    error('Ambiguous value for property: CCompiler');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'Watcom');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'VisualC');
  end;

 case 4
  newpropval=update_propval(actpropval,newpropval,index,propv);
  if strcmp(newpropval{index-1},'noWatcom')
    if ~isempty(newpropval{index})
      if ~exist(newpropval{index},'dir')
        disp('Error: invalid property value for property CompilerPath: specified directory does not exist');
        newpropval=update_propval(actpropval,newpropval,index,actpropval{index});
        err=1;
      end;
      if ~exist([newpropval{index},'\binnt'],'dir')
        disp('Error: invalid property value for property CompilerPath: specified directory is not a valid Compiler directory');
        newpropval=update_propval(actpropval,newpropval,index,actpropval{index});
        err=1;
      end;
    end;
  end;

 case 5

 case 6

 case 7
  num=str2num(propv);
  if isempty(num)
    index1=strmatch(propv,{'auto'});
    if isempty(index1)
      error('invalid property value for property: TargetRAMSizeMB');
    end;
    newpropval=update_propval(actpropval,newpropval,index,'Auto');
  else
    newpropval=update_propval(actpropval,newpropval,index,propv);
  end;

 case 8
  index1=strmatch(propv,{'1mb','4mb','16mb'});
  if isempty(index1)
    error('invalid property value for property: MaxModelSize');
  end;
  if length(index1)>1
    error('Ambiguous value for property: MaxModelSize');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'1MB');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'4MB');
   case 3
    newpropval=update_propval(actpropval,newpropval,index,'16MB');
  end;

 case 9
  index1=strmatch(propv,{'small','large'});
  if isempty(index1)
    error('invalid property value for property: SystemFontSize');
  end;
  if length(index1)>1
    error('Ambiguous value for property: SystemFontSize');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'Small');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'Large');
  end;

 case 10
  index1=strmatch(propv,{'none','200 isa','527 isa','1000 pci','1000 mb pci','pc104'});
  if isempty(index1)
    error('invalid property value for property: CANLibrary');
  end;
  if length(index1)>1
    error('Ambiguous value for property: CANLibrary');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'None');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'200 ISA');
   case 3
    newpropval=update_propval(actpropval,newpropval,index,'527 ISA');
   case 4
    newpropval=update_propval(actpropval,newpropval,index,'1000 PCI');
   case 5
    newpropval=update_propval(actpropval,newpropval,index,'1000 MB PCI');
   case 6
    newpropval=update_propval(actpropval,newpropval,index,'PC104');
  end;

 case 11
  index1=strmatch(propv,{'rs232','tcpip'});
  if isempty(index1)
    error('invalid property value for property: HostTargetComm');
  end;
  if length(index1)>1
    error('Ambiguous value for property: HostTargetComm');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'RS232');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'TcpIp');
  end;

 case 12
  index1=strmatch(propv,{'com1','com2'});
  if isempty(index1)
    error('invalid property value for property: RS232HostPort');
  end;
  if length(index1)>1
    error('Ambiguous value for property: RS232HostPort');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'COM1');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'COM2');
  end;

 case 13
  index1=strmatch(propv,{'115200','57600','38400','19200','9600','4800','2400','1200'});
  if isempty(index1)
    error('invalid property value for property: RS232Baudrate');
  end;
  if length(index1)>1
    error('Ambiguous value for property: RS232Baudrate');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'115200');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'57600');
   case 3
    newpropval=update_propval(actpropval,newpropval,index,'38400');
   case 4
    newpropval=update_propval(actpropval,newpropval,index,'19200');
   case 5
    newpropval=update_propval(actpropval,newpropval,index,'9600');
   case 6
    newpropval=update_propval(actpropval,newpropval,index,'4800');
   case 7
    newpropval=update_propval(actpropval,newpropval,index,'2400');
   case 8
    newpropval=update_propval(actpropval,newpropval,index,'1200');
  end

 case 14
  newpropval=update_propval(actpropval,newpropval,index,propv);

 case 15
  if str2num(propv)<20000
    error('invalid property value for property: Port number must be higher than 20000');
  end;
  newpropval=update_propval(actpropval,newpropval,index,propv);

 case 16
  newpropval=update_propval(actpropval,newpropval,index,propv);

 case 17
  newpropval=update_propval(actpropval,newpropval,index,propv);

 case 18
  index1=strmatch(propv,{'ne2000','smc91c9x','i82559','rtlance'});
  if isempty(index1)
    error('invalid property value for property: TcpIpTargetDriver');
  end;
  if length(index1)>1
    error('Ambiguous value for property: TcpIpTargetDriver');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'NE2000');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'SMC91C9X');
   case 3
    newpropval=update_propval(actpropval,newpropval,index,'I82559');
   case 4
    newpropval=update_propval(actpropval,newpropval,index,'RTLANCE');
  end;

 case 19
  index1=strmatch(propv,{'pci','isa'});
  if isempty(index1)
    error('invalid property value for property: TcpIpTargetBusType');
  end;
  if length(index1)>1
    error('Ambiguous value for property: TcpIpTargetBusType');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'PCI');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'ISA');
  end;

 case 20
  newpropval=update_propval(actpropval,newpropval,index,propv);

 case 21
  if str2num(propv)<5 | str2num(propv)>15
    error('invalid property value for property TcpIpTargetISAIRQ: IRQ number must be in between 5 and 15');
  end;
  newpropval=update_propval(actpropval,newpropval,index,propv);

 case 22
  error('property RLPro is read only');

 case 23
  index1=strmatch(propv,{'disabled','enabled'});
  if isempty(index1)
    error('invalid property value for property: TargetScope');
  end;
  if length(index1)>1
    error('Ambiguous value for property: TargetScope');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'Disabled');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'Enabled');
  end;

 case 24
  index1=strmatch(propv,{'none','ps2','rs232 com1','rs232 com2'});
  if isempty(index1)
    error('invalid property value for property: TargetMouse');
  end;
  if length(index1)>1
    error('Ambiguous value for property: TargetMouse');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'None');
   case 2
    newpropval=update_propval(actpropval,newpropval,index,'PS2');
   case 3
    newpropval=update_propval(actpropval,newpropval,index,'RS232 COM1');
   case 4
    newpropval=update_propval(actpropval,newpropval,index,'RS232 COM2');
  end;

 case 25
  index1=strmatch(propv,{'bootfloppy','dosloader','standalone'});
  if isempty(index1)
    error('invalid property value for property: TargetBoot');
  end;
  if length(index1)>1
    error('Ambiguous value for property: TargetBoot');
  end;
  switch index1
   case 1
    newpropval=update_propval(actpropval,newpropval,index,'BootFloppy');
   case 2
    if strcmp(actpropval{22},'Disabled')
      newpropval=update_propval(actpropval,newpropval,index,'BootFloppy');
      disp('Error: property TargetBoot cannot be set to DOSLoader: xPC Target Embedded Option is not installed');
    else
      newpropval=update_propval(actpropval,newpropval,index,'DOSLoader');
    end;
   case 3
    if strcmp(actpropval{22},'Disabled')
      newpropval=update_propval(actpropval,newpropval,index,'BootFloppy');
      disp('Error: property TargetBoot cannot be set to StandAlone: xPC Target Embedded Option is not installed');
    else
      newpropval=update_propval(actpropval,newpropval,index,'StandAlone');
    end;
  end;

end;


function newpropval=update_propval(actpropval,newpropval,index,token)

if strcmp(actpropval{index},token)
   newpropval{index}=[];
else
   newpropval{index}=token;
end;

function show_possible_settings(propname,actpropval)

fprintf(2,'\n\n');
fprintf(2,'    %-25s: ''xPC Target version, read-only''\n',propname{1});
fprintf(2,'    %-25s: ''xPC Target root directory, read-only''\n',propname{2});
fprintf(2,'\n');
fprintf(2,'    %-25s: {''Watcom'',''VisualC''}\n',propname{3});
fprintf(2,'    %-25s: ''valid Compiler root directory''\n',propname{4});
fprintf(2,'\n');
fprintf(2,'    %-25s: {''Auto'',''xxx''}, where xxx is a positive value specifying MB of RAM\n',propname{7});
fprintf(2,'    %-25s: {''1MB'',''4MB'',''16MB''}\n',propname{8});
fprintf(2,'    %-25s: {''Small'',''Large''}\n',propname{9});
fprintf(2,'    %-25s: {''None,'',''200 ISA'',''527 ISA'',''1000 PCI'',''1000 MB PCI'',''PC104''}\n',propname{10});
fprintf(2,'\n');
fprintf(2,'    %-25s: {''RS232'',''TcpIp''}\n',propname{11});
fprintf(2,'    %-25s: {''COM1'',''COM2''}\n',propname{12});
fprintf(2,'    %-25s: {''115200'',''57600'',''38400'',''19200'',''9600'',''4800'',''2400'',''1200''}\n',propname{13});
fprintf(2,'    %-25s: ''xxx.xxx.xxx.xxx''\n',propname{14});
fprintf(2,'    %-25s: ''xxx'', where xxx>=20000\n',propname{15});
fprintf(2,'    %-25s: ''xxx.xxx.xxx.xxx''\n',propname{16});
fprintf(2,'    %-25s: ''xxx.xxx.xxx.xxx''\n',propname{17});
fprintf(2,'    %-25s: {''NE2000'',''SMC91C9X'',''I82559'',''RTLANCE''}\n',propname{18});
fprintf(2,'    %-25s: {''PCI'',''ISA''}\n',propname{19});
fprintf(2,'    %-25s: ''0xnnnn''\n',propname{20});
fprintf(2,'    %-25s: ''xxx'', where 4<xxx<15\n',propname{21});
fprintf(2,'\n');

fprintf(2,'    %-25s: {''Disabled'',''Enabled''}\n',propname{23});
fprintf(2,'    %-25s: {''None'',''PS2'',''RS232 COM1'',''RS232 COM2''}\n', ...
        propname{24});
fprintf(2,'\n');
fprintf(2,'    %-25s: {''Disabled'',''Enabled''} read-only\n',propname{22});
fprintf(2,'    %-25s: {''BootFloppy'',''DOSLoader'',''StandAlone''}\n', ...
        propname{25});
fprintf(2,'\n\n');
