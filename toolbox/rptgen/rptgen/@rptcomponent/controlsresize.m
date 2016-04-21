function c=controlsresize(c)
%CONTROLSRESIZE resizes a component's attribute page uicontrols
%   C=CONTROLSRESIZE(C) lays out uicontrols specified in
%   C.x.LayoutManager.  C.x.LayoutManager is a cell array containing
%   other cell arrays, handles, strings, or frame structures.
%
%   Each cell array forms its own grid.  Grids dynamically size
%   to fit the available horizontal space and expand downward 
%   without considering available vertical space.
%
%   Each element in the array must be one of the following:
%   * a single UIcontrol handle (vectors of uicontrols are not allowed)
%   * a number - numbers act as spacers
%       -1x1 [M] numbers insert M points of space horizontally and vertically
%       -2x1 [M N] numbers insert M points horizontally and N vertically
%       -if M=inf, the spacer will take up as much space as an edit box
%       -if m=-inf, the spacer will take up as much space as allowed
%   *a string - certain strings are equivalent to certain number combinations
%       -'indent' is the same as [20 1]
%       -'spacer' is the same as [inf 1]
%       -'buffer' is the same as [-inf 1]
%   *a structure - CONTROLSFRAME returns a structure which can be
%       read by CONTROLSRESIZE.  The 'FrameContent' field follows the
%       same rules as C.x.LayoutManager
%
%   The lowest Y position of the last UIcontrol is returned in
%   c.x.lowLimit.  If c.x.lowLimit is less than the lowest allowable
%   Y position (c.x.yzero), c.x.allInvisible is turned on and the
%   "error" screen shows instead of the attribute page.
%
%   See also: CONTROLSMAKE, CONTROLSUPDATE, CONTROLSFRAME

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:55 $

%--------1---------2---------3---------4---------5---------6---------7---------8
x=subsref(c,substruct('.','x'));

x.pad=10;
[x.lowLimit,rsHandles,rsPositions]=LocProcessCell(...
   x.LayoutManager,...
   x.xzero+x.pad,...
   x.xext-x.pad,...
   x.ylim,0);

set(rsHandles,{'Position'},rsPositions');
x.allInvisible = (x.lowLimit<x.yzero+x.pad);
c=subsasgn(c,substruct('.','x'),x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Bottom,rH,rP]=LocProcessCell(myCell,Left,Right,Top,prevColHt)

if iscell(myCell)
   numCol=size(myCell,2);
   numRow=size(myCell,1);

   %-----------get column widths-----------------
   if numCol<=1
      colWidths=[Left, Right];
   else
      for j=numCol:-1:1
         cwSize(j)=LocGetWidth(myCell(:,j));
      end
      whichInf=find(cwSize==inf);
      whichNegInf=find(cwSize==-inf);
      notInf=setxor([1:numCol],[whichInf whichNegInf]);
      if isempty([whichInf whichNegInf])
         allWid=sum(cwSize);
         if allWid>Right-Left
            cwSize=cwSize*(Right-Left)/allWid;
         end
      else
         %if there are indefinite-length columns
         tempNumCol=numCol-length(whichNegInf);
         cwSize(notInf)=min(cwSize(notInf),(Right-Left)/tempNumCol);
         infWidth=max(0,(Right-Left-sum(cwSize(notInf)))/...
            (length(whichInf)+length(whichNegInf)));
         cwSize(whichInf)=infWidth*ones(1,length(whichInf));
         cwSize(whichNegInf)=infWidth*ones(1,length(whichNegInf));
      end   
      colWidths=cumsum([Left cwSize]);
   end
   
   %-----------process cells---------------------
   Bottom=Top;
   rH=[];
   rP={};
   for i=1:numRow;
      Top=Bottom;
      for j=1:numCol
         cellContent=myCell{i,j};
         if length(cellContent)==1
            prevHt=Top-min(Bottom);
         else
            prevHt=0;
         end
         
         hIndex=(i-1)*numRow+j;
         [Bottom(j),trH,trP]=LocProcessCell(...
            cellContent,colWidths(j),colWidths(j+1),Top,prevHt);
         rH=[rH trH];
         rP={rP{:} trP{:}};
      end
      Bottom=min(Bottom);
   end
elseif ishandle(myCell) & floor(myCell)~=myCell
   switch get(myCell,'type')
   case 'axes'
      controlHt=max(prevColHt,layoutbarht(rptparent)*5);
   case 'uicontrol'
      switch get(myCell,'style')
      case 'text'
         textExtent=get(myCell,'extent');
         controlHt=max(textExtent(4)*1.05,prevColHt);
      case 'listbox'
         controlHt=max(prevColHt,layoutbarht(rptparent)*5);
      case 'edit'
         eMax=get(myCell,'max');
         eMin=get(myCell,'min');
         if eMax-eMin>1
            %if a multiple-line edit box
            controlHt=max(prevColHt,layoutbarht(rptparent)*5);
         else
            controlHt=layoutbarht(rptparent);
         end         
         case {'togglebutton' 'pushbutton'}
            cData=get(myCell,'CData');
            if isempty(cData)
               controlHt=layoutbarht(rptparent); %pad the width a bit
            else
               controlHt=(size(cData,1)+3)*pointsperpixel(rptparent)*1.2;               
            end
            

      otherwise
         controlHt=layoutbarht(rptparent);
      end
   otherwise
      controlHt=0;
   end
   Bottom=Top-controlHt;
   rH=myCell;
   rP={[Left Bottom Right-Left controlHt]};
elseif isnumeric(myCell)
   if length(myCell)>1
      Bottom=Top-myCell(2);
   elseif length(myCell)==1
      Bottom=Top-myCell(1);
   else
      Bottom=Top;
   end
   rH=[];
   rP={};
elseif isstruct(myCell)
   %we're drawing a frame
   frameOffset=1;
   [Bottom,rH,rP]=LocProcessCell(myCell.FrameContent,...
      Left+5,Right-5,Top-10-frameOffset,0);
   
   rH=[rH myCell.Frame myCell.FrameName];
   
   [pH,pV]=pointsperpixel(rptparent);
   
   lightFramePos=[Left Bottom-5+frameOffset ...
         (Right-Left) (Top-Bottom-frameOffset)];   
   darkFramePos=[Left-pH Bottom-5+frameOffset+pV ...
         (Right-Left) (Top-Bottom-frameOffset)];   

   fnExt=get(myCell.FrameName,'extent');
   
   nameWidth=min(fnExt(3)+5,Right-Left-10);
   nameOffset=min(15,Right-Left);
   nPos=[Left+nameOffset Top-9 nameWidth 10];
   rP={rP{:}  darkFramePos lightFramePos nPos};
   Bottom=Bottom-5;
elseif ischar(myCell)
   rH=[];
   rP={};
   Bottom=Top-layoutbarht(rptparent);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function colWid=LocGetWidth(colCells);

for i=length(colCells):-1:1
   myCell=colCells{i};
   if isa(myCell,'cell')
      colWid(i)=LocGetWidth(myCell);
   elseif ischar(myCell)
      switch myCell
      case 'spacer'
         colWid(i)=inf;
      case 'buffer'
         colWid(i)=-inf;
      case 'indent'
         colWid(i)=20;
      otherwise
         colWid(i)=0;
      end
   elseif ishandle(myCell) & ...
         length(myCell)==1 & ...
         rem(myCell,1)~=0 %can't take integer handles
      switch get(myCell,'type')
      case 'uicontrol'
         controlExtent=get(myCell,'extent');
         colWid(i)=controlExtent(3);
         switch get(myCell,'style')
         case {'radiobutton' 'checkbox'}
            colWid(i)=colWid(i)+20; %accounts for room taken by box
         case {'slider' 'edit' 'listbox' 'popupmenu' 'frame'}
            colWid(i)=inf; %try to take as much space as possible
         case {'pushbutton' 'togglebutton'}
            cData=get(myCell,'CData');
            if isempty(cData)
               colWid(i)=colWid(i)+10; %pad the width a bit
            else
               colWid=(size(cData,2)+3)*pointsperpixel(rptparent)*1.2;               
            end
            
            %case 'text' - keep colWid
         end
      case 'axes'
         colWid(i)=inf;
      otherwise
         colWid(i)=0;
      end
   elseif isnumeric(myCell)
      if length(myCell)>0
         colWid(i)=myCell(1);
      else
         colWid(i)=0;
      end
   elseif isstruct(myCell)
      colWid(i)=inf;
   else
      colWid(i)=0;
   end
end
colWid=max(colWid);