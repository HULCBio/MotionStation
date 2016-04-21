function [portout, maskdisplay, dtypeout]=mxpcportio(ports,type,dtype)

% MXPCPORTIO - Mask Initialization for I/O-Port Access driver blocks 

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/03/25 04:10:36 $

if ~isa(ports,'cell')
   error('port argument must be a cell array');
end

portout=zeros(1,length(ports));
for i=1:length(ports)
   port=ports{i};
   if isa(port,'double')
      portout(i)=port;
   elseif isa(port,'char')
      index=findstr(lower(port),'0x');
      if isempty(index)
         try
            portout(i)=str2num(port);
         catch
            error('invalid port format');
         end
      else
         if index==1
            port=port(3:end);
         	try
            	portout(i)=hex2dec(port);
         	catch
            	error('invalid port format');
            end
         else
            error('invalid port format');
         end
      end
   else
      error('invalid port format');
   end
end

if nargin==3

	if ~isa(dtype,'cell')
   	error('data type argument must be a cell array');
	end

	if length(dtype)~=length(ports)
   	error('data type argument must have the same number of elements as the port argument');
	end

	dtypeout=zeros(1,length(ports));
   
   for i=1:length(dtype)
      dtypee=dtype{i};
      if ~isa(dtypee,'char')
         error('the elements of the data type argument must be strings');
      end
      if strcmp(dtypee,'int8')
         dtypeout(i)=2;
      elseif strcmp(dtypee,'uint8')
         dtypeout(i)=3;
      elseif strcmp(dtypee,'int16')
         dtypeout(i)=4;
      elseif strcmp(dtypee,'uint16')
         dtypeout(i)=5;
      elseif strcmp(dtypee,'int32')
         dtypeout(i)=6;
      elseif strcmp(dtypee,'uint32')
         dtypeout(i)=7;
      else
         error('the supported data types are: int, uint8, int16, uint16, int32 and uint32');
      end
   end
   
end

      
if type==1
	maskdisplay=[];
	for i=1:length(portout)
		maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),','' 0x',dec2hex(portout(i)),', ',num2str(portout(i)),''');'];
   end         
elseif type==2
 	maskdisplay=[];
	for i=1:length(portout)
		maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''0x',dec2hex(portout(i)),', ',num2str(portout(i)),' '');'];
   end         
end   

      

         

            
               
      
   
      
   

         
         
         

         
   



