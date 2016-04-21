function mxpccanicon(name, type, canPort, range, ids, board)

% MXPCCANICON - Mask Initialization Icon function for Intel 82527 Can bus (Targetbox)

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/15 22:25:05 $

if strcmp(type,'Transmit')
  xpos=0.98;
  al='right';
else
  xpos=0.05;
  al='left';
end

if board~=0
name=[name,' B',num2str(board)];
end


display=['text(',num2str(xpos),',0.75,''',name,''',''horizontalAlignment'',''',al,''');'];
if canPort==1
  tmp=['CAN - ',type];
else
  tmp=['CAN - ',type];
end
display=[display,'text(',num2str(xpos),',0.5,''',tmp,''',''horizontalAlignment'',''',al,''');'];
if range==1
  tmp='Standard 11bit';
else
  tmp='Extended 29bit';
end
display=[display,'text(',num2str(xpos),',0.25,''',tmp,''',''horizontalAlignment'',''',al,''');'];

if strcmp(type,'Transmit')
  tmp='';
  for i=1:length(ids)
    tmp=[tmp,'port_label(''input'',',num2str(i),',''',num2str(ids(i)),''');'];
  end         
else
  tmp='';
  for i=1:length(ids)
    tmp=[tmp,'port_label(''output'',',num2str(i),',''',num2str(ids(i)),''');'];
  end 
end

set_param(gcb,'MaskDisplay',[display,tmp]);




  
  
  