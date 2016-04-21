function [gain, offset, control, maskdisplay, maskdescription]= maddiamondmmx(boardType, startChannel, nChannels, mux, range, baseAddress)

% MDADIAMONDMMX - Mask Initialization function for Dimaond Systems MM driver blocks

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/03/25 04:08:22 $

switch boardType
case 1	
	maskdisplay='disp(''MM-32\nDiamond\n';
    description='MM-32';
    supRange=[-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25];
    supRangeStr='-10, -5, -2.5, -1.25, -0.625, 10, 5, 2.5, 1.25';
    supControl=[8, 0, 1, 2, 3, 12, 13, 14, 15]; 
    resolution=16;
	maxChannels=32;
end
maskdisplay=[maskdisplay,'Analog Input'');'];
for i=1:nChannels
	maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(i+startChannel-1),''');'];
end
maskdescription=[description,10,'Diamond Systems',10,'Analog Input'];
  
switch boardType
case 1	
	blocks=find_system(bdroot,'FollowLinks','on','LookUnderMasks','all','MaskType','addiamondmm32','baseaddress',baseAddress);
	if length(blocks)>1
		error('Only one instance of the Diamond Systems MM-32 A/D block per physical board allowed in a model');
	end
end

[m,n]= size(startChannel);
if length(m)>1 | length(n)>1
  error('First Channel must be a scalar value');
end

[m,n]= size(nChannels);
if length(m)>1 | length(n)>1
  error('Number of Channels must be a scalar value');
end

if mux==1
  if startChannel<1 | startChannel>maxChannels
	error('First Channel value must be in the range 1..32 (single-ended)');
  end
  lastChannel= startChannel+nChannels-1;
  if lastChannel > maxChannels
	error('The resulting last channel cannot be higher than 32 (single-ended)');
  end
else
  if startChannel<1 | startChannel>maxChannels/2
	error('First Channel value must be in the range 1..16 (differential)');
  end
  lastChannel= startChannel+nChannels-1;
  if lastChannel > maxChannels/2
	error('The resulting last channel cannot be higher than 16 (differential)');
  end
end
if lastChannel<startChannel
	error('The resulting last channel must be larger or equal to the First Channel');
end

rangeval= supRange(range);
control= supControl(range);
resolution=2^resolution;
if rangeval < 0
	gain= -rangeval*2/resolution;
    offset= 0;
else
	gain= rangeval/resolution;
    offset= -rangeval/2;
end





















	
	
	
	
	
	
	

	
  

  
  
  




