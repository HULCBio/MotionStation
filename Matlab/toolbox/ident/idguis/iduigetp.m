function figno=iduigetp(handle,arg)
%IDUIGETP Help function for managing XIDplow handles.
%   Arguments:
%   find_number (Default) Returns the XIDplotw number of the figure
%               whose handle is entered. That is 'handle=XIDplotw(figno,1)'
%               If the handle does not correspond to an XIDplotw [] is returned.
%   check       Returns 1 if XIDplotw(handle,1) has the correct name, else 0.
%   name        Returns the name of window.  No HANDLE is returned.

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $ $Date: 2004/04/10 23:19:42 $

if nargin<2 arg='find_number';end
figure_names=str2mat(...
'Time Plot',...                         %1
'Frequency Function',...                %2
'Model Output',...                      %3
'Zeros and Poles',...                   %4
'Transient Response',...                %5
'Residual Analysis',...                 %6
'Noise Spectrum',...                    %7
'Data/model Info',...                   %8
'ARX Model Structure Selection');       %9

figure_names=str2mat(figure_names,...
'Model Order Selection',...             %10
'Choice of Auxiliary Order',...         %11
[],...                                  %12
'Data Spectra',...                      %13
'Select Range',...                      %14
'Filter',...                            %15
'Frequency Function Data');                              %40=16

 if handle==40, handle = 16;end %
%global XIDplotw
if strcmp(arg,'name')
   
      
  figno=deblank(figure_names(handle,:));
  
  return
end
if strcmp(arg,'check'),
  [nrr,nrc]=size(XIDplotw);
  if nrr<handle,figno=0;return,end
  handle1=XIDplotw(handle,1);
else
  handle1=handle;
end
eval('fig=get(handle1,''name'');','fig=[];')
colno=find(fig==':');
if ~isempty(colno);fig=fig(1:colno(1)-1);end
if strcmp(arg,'find_number')
	for k=1:16
		if strcmp(fig,deblank(figure_names(k,:)))
			figno=k;break
		end
	end
    if figno==16, figno=40;end
elseif strcmp(arg,'check')
	try
		figno=strcmp(fig,deblank(figure_names(handle,:)));
	catch
		figno=0;
	end
end