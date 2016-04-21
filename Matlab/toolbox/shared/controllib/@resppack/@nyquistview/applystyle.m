function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies line styles to @nyquistview.

%  Author(s): John Glass, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:52 $
Curves = cat(3,this.PosCurves,this.NegCurves);
Arrows = cat(3,this.PosArrows,this.NegArrows);
for ct1 = 1:size(Curves,1)
   for ct2 = 1:size(Curves,2)
      [Color,LineStyle,Marker] = getstyle(Style,RowIndex(ct1),ColumnIndex(ct2),RespIndex);
      set(Curves(ct1,ct2,:),'Color',Color,'LineStyle',LineStyle,...
         'Marker',Marker,'LineWidth',Style.LineWidth)
      set(Arrows(ct1,ct2,:),'FaceColor',Color,'EdgeColor',Color)
   end
end