function [port, ctype]= canfifofilterutil(portin, ctypein, direction)

% CANFIFOFILTERUTIL - Mask Initialization for CAN message filtering (FIFO mode)

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/03/25 04:02:57 $

switch portin
case 1
  port=[1,1];
case 2
  port=[1,0];
case 3
  port=[0,1];
end
  
tokens={'SDF','SRF','EDF','ERF','EF','NE','CBS'};
tindex= [2,3,10,13,16,1,6];
values=zeros(7,16);
values(1,2)=1;
values(2,3)=1;
values(3,10)=1;
values(4,13)=1;
values(5,16)=1;
values(6,1)=1;
values(7,6)=1;

if direction
  ctype= ones(1,16);
else
  ctype= zeros(1,16);
end

for i=1:length(tokens)
  index=findstr(ctypein,tokens{i});
  if ~isempty(index)
	if direction
	  ctype(tindex(i))=0;
	else
	  ctype(tindex(i))=1;
	end
  end
end

		




  







