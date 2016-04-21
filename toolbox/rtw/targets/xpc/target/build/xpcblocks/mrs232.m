function [formatsend, formatrec, dtypeout, maskdisplay, maskdescription, inPorts, outPorts, numInPorts, numOutPorts, formatSendInfo, formatRecInfo, WaitArg, numEOM, TimeoutArg] = mrs232(flag, block, direct)

% MRS232 - InitFcn and Mask Initialization for RS-232 Communications

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:10:33 $

persistent pool;

if flag == 0
  pool = [];
  return;
end


formatsend		=[];
formatrec		=[];
dtypeout		=[];
convString		=[];
outString		=[];
outPorts		=[];
inPorts			=[];
numInPorts  	=[];
numOutPorts 	=[];
fullString		=[];
formatSendInfo 	=[];
formatRecInfo	=[];
WaitArg     	=[];
TimeoutArg		=[];
convString 		='';
outString		='';
fullSendString	='';
fullRecString   ='';

numblocks = length(block);

% processing
% create all field that don't exist
% General
if ~isfield(block,'SendData')
  block(1).SendData=[];
end
% Initialization and Termination Only
if ~isfield(block,'Ack')
  block(1).Ack='';
end
if ~isfield(block,'Timeout')
  block(1).Timeout=[];
end
% Send/Receive Only
if ~isfield(block,'InputPorts')
  block(1).InputPorts=[];
end
if ~isfield(block,'RecData')
  block(1).RecData=[];
end
if ~isfield(block,'OutputPorts')
  block(1).OutputPorts=[];
end
if ~isfield(block,'OutputDataTypes')
  block(1).OutputDataTypes=[];
end
if ~isfield(block,'Wait')
  block(1).Wait=0;
  WaitArg = block(1).Wait;
end
if ~isfield(block,'EOM')
  block(1).EOM=[];
end

%set field created to default values

numEOM = [];

currentTimeout = [];

for i = 1:numblocks
  if isempty(block(i).SendData) & isa(block(i).SendData,'double')
    block(i).SendData=''; % default
  end
  if isempty(block(i).RecData) & isa(block(i).RecData,'double')
    block(i).RecData=''; % default
  end
  if isempty(block(i).Wait)
    block(i).Wait=0; % default
  end
  %if isempty(block(i).Timeout)
  %  block(i).Timeout=0; % default
  %end
  if isempty(block(i).EOM)
    block(i).EOM=1; % default
  end

  if ~isempty(block(i).Timeout)
    currentTimeout = block(i).Timeout;
  else
	if isempty(currentTimeout)
	  currentTimeout = 0.049;
	end
    block(i).Timeout = currentTimeout;
  end
  
  numEOM = [numEOM,block(i).EOM];
end

for i = 1:numblocks
  convString = '';
  outString = '';

  %Construct send message
  %Send message data
  if ~isempty(block(i).SendData)
	convString = [convString,block(i).SendData];
  end

  convString = replace_escapes(convString);
  formatSendInfo(i+1) = length(convString);
  fullSendString = [fullSendString,convString];

  %Setup and check output ports data types
  
  if isempty(block(i).OutputDataTypes)	& ~isempty(find(block(i).OutputPorts>0))
    block(i).OutputDataTypes = {'double'};
  end

  if size(block(i).OutputDataTypes,1)==1 & size(block(i).OutputDataTypes,2)==1 
    [block(i).OutputDataTypes{1:length(find(block(i).OutputPorts>0))}]=deal(block(i).OutputDataTypes{1});
  end      

  if length(block(i).OutputDataTypes) ~= length(find(block(i).OutputPorts>0))
	error('The number of output data types must be empty (default type double assumed), a scalar (scalar expension applies) or a row vector with the same number of element as the output ports');
  end
    
  %Setup receive message format
  if ismember(direct,[4]);
    if ~isempty(block(i).Ack)
      outString = block(i).Ack
    end

	outstring = replace_escapes(outString);
    formatRecInfo(i+1) = length(outString);
	fullRecString = [fullRecString,outString];
  else
    if ~isempty(block(i).RecData)
      outString = [outString,replace_escapes(block(i).RecData)];
    end
    formatRecInfo(i+1) = length(outString);
	fullRecString = [fullRecString,outString];
  end

  %Setup input and output port mapping
  inPorts (length (inPorts)+1:length(block(i).InputPorts)+length (inPorts)) = block(i).InputPorts;
  outPorts(length(outPorts)+1:length(block(i).OutputPorts)+length(outPorts)) = block(i).OutputPorts;   

  %Setup Wait(send and receive blocks) or Timeout(setup block)
  if ismember(direct,[4]);
    WaitArg = block(i).Timeout;
  else
	WaitArg(i) = block(i).Wait;
    if WaitArg(i) > 0.05
      error(['Command wait cannot be greater then 50ms']);
	end
	TimeoutArg(i) = block(i).Timeout;
    if TimeoutArg(i) > 0.05
	  error(['Timeout cannot be greater then 50ms']);
	end
  end
end

%Set the number of messages
formatSendInfo(1) = length(block);
formatRecInfo(1) = length(block);

formatsend = replace_escapes(fullSendString);
formatrec  = replace_escapes(fullRecString);

%Setup number of input and output ports
if isempty(max(inPorts))
  numInPorts = 0;
else
  numInPorts = max(inPorts);
end

if isempty(max(outPorts))
  numOutPorts = 0;
else
  if max(outPorts) > 0;
    numOutPorts = max(outPorts);
  else
    numOutPorts = 0;
  end
end


%Set maskdisplay
%Note: due to dynamic datatype the set_param must be done inside the mask
maskdisplay='disp(''RS-232\nMainboard\n';

description=['RS-232',10,'Mainboard',10];

dtypeout = 0;

if direct==1 %rs232 receive

  maskdisplay=[maskdisplay,'Receive'');'];
  maskdescription=[description,'Receive'];

  for i=1:numOutPorts
	  maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(i),''');'];
  end 

  formatrec = replace_escapes(formatrec);

elseif direct==2 %rs232 send

  maskdisplay=[maskdisplay,'Send'');'];
  maskdescription=[description,'Send'];

  for i=1:numInPorts
	 maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(i),''');'];
  end 

  formatsend = replace_escapes(formatsend);

elseif direct==3 %rs232 synchronized send/receive

  maskdisplay=[maskdisplay,'Send/Receive'');'];
  maskdescription=[description,'Send/Receive'];

  for i=1:numOutPorts
	  maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(i),''');'];
  end 

  for i=1:numInPorts
	 maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(i),''');'];
  end 

  formatrec  = replace_escapes(formatrec);
  formatsend = replace_escapes(formatsend);

else %rs232 setup

  maskdisplay=[maskdisplay,'Setup'');'];  
  maskdescription=[description,'Setup'];
end


%Setup data types
if direct==1 | direct==3
  dtypeout = zeros(1,numOutPorts);
  for i=1:numblocks
    if ~isempty(block(i).OutputDataTypes)
	  k = 1;
	  for j=1:length(block(i).OutputPorts)
		if k <= length(block(i).OutputDataTypes)
		  if block(i).OutputPorts(j) > 0
	        dtypee = block(i).OutputDataTypes{k};
            if ~isa(dtypee,'char')
              error('the elements of the data type argument must be strings');
            end
            if strcmp(dtypee,'double')
              dtypeout(block(i).OutputPorts(j))=0;
            elseif strcmp(dtypee,'int8')
              dtypeout(block(i).OutputPorts(j))=2;
            elseif strcmp(dtypee,'uint8')
              dtypeout(block(i).OutputPorts(j))=3;
            elseif strcmp(dtypee,'int16')
              dtypeout(block(i).OutputPorts(j))=4;
            elseif strcmp(dtypee,'uint16')
              dtypeout(block(i).OutputPorts(j))=5;
            elseif strcmp(dtypee,'int32')
              dtypeout(block(i).OutputPorts(j))=6;
            elseif strcmp(dtypee,'uint32')
              dtypeout(block(i).OutputPorts(j))=7;
            else
              error('the supported data types are: double, int, uint8, int16, uint16, int32 and uint32');
            end
		    k = k + 1;
		  end
        end
      end
    end
  end
end

% Check For Multipule instances using the same channel (RS232 Setup Only)
% RS232 Setup
if direct == 4 
  MAX_COMM = 4;
  portString = get_param(gcb,'MaskValueString');
  i = find(portString=='|');
  port = str2num(portString(i(1)-1));
end

if direct == 4
  if flag ~= 2
    portref=['ref',num2str(port)];
    if ~isfield(pool,portref)
      eval(['pool.',portref,'.portUsed=zeros(1,8);']);
    end
    level1=getfield(pool,portref);
    if port<1 | port > MAX_COMM
      error(['Elements comm port number must be in between 1 and ',num2str(MAX_COMM)]);
    end
    if level1.portUsed(port)==1
      error(['Comm port ',num2str(port),' already in use']);
    end
    level1.portUsed(port)=1;
    pool=setfield(pool,portref,level1);
  end
end

function output=replace_escapes(input)

tokens={'\\','\a','\b','\f','\r','\t','\v','\''','\"','\n'};
output=input;

for i=1:length(tokens)
  if strcmp(tokens{i},'\\')
    j = 1;
    m = length(input);
    while j < m
	  if output(j) == char(92) & output(j+1) == char(92)
	    output(j) = char(200);
        if (j+2) <= m 
  	      output(j+1:m-1) = output(j+2:m);
        end
        output(m) = char(0);
       m = m - 1;
      end
     j = j + 1;
    end
  else
    output=strrep(output,tokens{i},sprintf(tokens{i}));
  end
end

for i = 1:length(output)
  if output(i) == char(200)
   output(i) = abs(sprintf('\\'));
  end
end

