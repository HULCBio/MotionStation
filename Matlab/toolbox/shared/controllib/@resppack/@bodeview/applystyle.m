function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies line styles to @bodeview.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:32 $
Curves = ghandles(this);
Curves = Curves(:,:,:,1);  % Don't color Nyquist lines
for ct1 = 1:size(Curves,1)
   for ct2 = 1:size(Curves,2)
      [Color,LineStyle,Marker] = getstyle(Style,RowIndex(ct1),ColumnIndex(ct2),RespIndex);
      set(Curves(ct1,ct2,:),'Color',Color,'LineStyle',LineStyle,...
         'Marker',Marker,'LineWidth',Style.LineWidth)
   end
end