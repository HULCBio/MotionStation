function out=propfigure(c,action,varargin)
%PROPFIGURE returns properties of figures
%   FLIST  = PROPFIGURE(ZHGMETHODS,'GetFilterList');
%   PLIST  = PROPFIGURE(ZHGMETHODS,'GetPropList',FILTERNAME);
%   PVALUE = PROPFIGURE(ZHGMETHODS,'GetPropValue',FIGUREHANDLES,PROPNAME);

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:45 $

switch action
case 'GetFilterList'
   out={'main' 'Main Properties'
      'all' 'All Properties'
      'gui' 'GUI Properties'
      'print','Print Properties'};
case 'GetPropList'
   out=LocGetPropList(varargin{1});
case 'GetPropValue'
   Property=varargin{2};
   fHandles=varargin{1};
   
   switch Property
   case {'Children' 'PaperSize' 'PaperPosition'}
      out=feval(['LocProp' Property],fHandles);
   otherwise
      out=LocGetParam(fHandles,Property);
   end %case Property
end %primary case


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=LocGetPropList(filter)

switch filter
case 'main'
   list={'Children'
      'FileName'
      'Name'
      'Tag'};
case 'all'
   h=tempfigure(zhgmethods);
   list=fieldnames(get(h.Figure));
   delete(h.Figure);
case 'gui'
   list={'BusyAction'
      'IntegerHandle'
      'MenuBar'
      'NumberTitle'
      'Resize' 
      'Tag'
      'UserData'
      'WindowButtonDownFcn'
      'ButtonDownFcn'
      'CloseRequestFcn'
      'WindowButtonMotionFcn'
      'WindowButtonUpFcn'
      'WindowStyle'};
case 'print'  
   list={'PaperOrientation'
      'PaperPosition'
      'PaperPositionMode'
      'PaperSize'
      'PaperType'
      'PaperUnits'
      'InvertHardcopy'};      
end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocGetParam(figHandles,Property);


try
   out=get(figHandles,Property);
   if length(figHandles)==1
      out={out};
   end
catch
   for i=length(figHandles):-1:1
      try
         out{i,1}=get(figHandles(i),Property);
      catch
         out{i,1}='N/A';
      end
   end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valCells=LocPropChildren(figHandles)

valCells=LocGetParam(figHandles,'Children');

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
function valCells=LocPropPaperPosition(figHandles)

valCells=LocGetParam(figHandles,'PaperPosition');

for i=1:length(valCells)
   currCell=valCells{i};
   valCells{i}=sprintf('(%0.2f, %0.2f) %0.2f x %0.2f',...
      currCell(1),currCell(2),currCell(3),currCell(4));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function valCells=LocPropPaperSize(figHandles)

valCells=LocGetParam(figHandles,'PaperSize');

for i=1:length(valCells)
   currCell=valCells{i};
   valCells{i}=sprintf('%0.2f x %0.2f',currCell(1),currCell(2));
end
