function mxpccanicon(name, type, canPort, range, ids, board)

% MXPCCANICON - Mask Initialization Icon function for Softing CAN driver blocks

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/03/25 03:58:57 $

if strcmp(type,'Send')
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
  tmp=['CAN 1 - ',type];
else
  tmp=['CAN 2 - ',type];
end
display=[display,'text(',num2str(xpos),',0.5,''',tmp,''',''horizontalAlignment'',''',al,''');'];
if range==1
  tmp='Standard 11bit';
else
  tmp='Extended 29bit';
end
display=[display,'text(',num2str(xpos),',0.25,''',tmp,''',''horizontalAlignment'',''',al,''');'];

if strcmp(type,'Send')
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










  
  
  