function out=propaxes(c,action,varargin)
%PROPAXES returns properties of axes
%   FLIST  = PROPAXES(ZHGMETHODS,'GetFilterList');
%   PLIST  = PROPAXES(ZHGMETHODS,'GetPropList',FILTERNAME);
%   PVALUE = PROPAXES(ZHGMETHODS,'GetPropValue',AXESHANDLES,PROPNAME);

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:44 $

switch action
case 'GetFilterList'
   out={'all' 'All Properties'
      'xyz' 'XYZ Axis Properties'
      'camera','Camera Properties'};
case 'GetPropList'
   out=LocGetPropList(varargin{1});
case 'GetPropValue'
   Property=varargin{2};
   aHandles=varargin{1};
   
   switch Property
   case {'Children' 'Parent' 'UIContextMenu'}
      out=LocObjectNames(aHandles,Property);
   case {'Title' 'Xlabel' 'Ylabel' 'Zlabel'}
      out=LocTextString(aHandles,Property);
   otherwise
      out=LocGetParam(aHandles,Property);
   end %case Property
end %primary case


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=LocGetPropList(filter)

switch filter
case 'all'
   h=tempfigure(zhgmethods);
   list=fieldnames(get(h.Axes));
   delete(h.Figure);
case 'xyz'
   list={'XAxisLocation'
    'XColor'
    'XDir'
    'XGrid'
    'XLabel'
    'XLim'
    'XLimMode'
    'XScale'
    'XTick'
    'XTickLabel'
    'XTickLabelMode'
    'XTickMode'
    'YAxisLocation'
    'YColor'
    'YDir'
    'YGrid'
    'YLabel'
    'YLim'
    'YLimMode'
    'YScale'
    'YTick'
    'YTickLabel'
    'YTickLabelMode'
    'YTickMode'
    'ZColor'
    'ZDir'
    'ZGrid'
    'ZLabel'
    'ZLim'
    'ZLimMode'
    'ZScale'
    'ZTick'
    'ZTickLabel'
    'ZTickLabelMode'
    'ZTickMode'};
case 'camera'  
    list={'CameraPosition'
    'CameraPositionMode'
    'CameraTarget'
    'CameraTargetMode'
    'CameraUpVector'
    'CameraUpVectorMode'
    'CameraViewAngle'
    'CameraViewAngleMode'
    'View'
    'Projection'};
end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocGetParam(axHandles,Property);


try
   out=get(axHandles,Property);
   if length(axHandles)==1
      out={out};
   end
catch
   for i=length(axHandles):-1:1
      try
         out{i,1}=get(axHandles(i),Property);
      catch
         out{i,1}='N/A';
      end
   end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valCells=LocObjectNames(aHandles,Property)

valCells=LocGetParam(aHandles,Property);

z=zhgmethods;
for i=1:length(valCells)
   currCell=valCells{i};
   nameString='';
   currCellLength=length(currCell);
   for j=1:currCellLength
      if j==currCellLength
         commaString='';
      else
         commaString=', ';
      end
      %insert LINKING once we support it
      nameString=[nameString objname(z,currCell(j),logical(0)) commaString];      
   end
   valCells{i}=nameString;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valCells=LocTextString(aHandles,Property);
%Gets the text string of axes relatives which are text uicontrols
%like Title and Xlabel

valCells=LocGetParam(aHandles,Property);

z=zhgmethods;
for i=1:length(valCells)
   try
      valCells{i}=get(valCells{i},'String');
   catch
      valCells{i}='';
   end
end
