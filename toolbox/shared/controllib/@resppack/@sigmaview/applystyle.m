function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies line styles to @sigmaview.

%  Author(s): Kamesh Subbarao, 10-15-2001
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:24 $
[Color,LineStyle,Marker] = getstyle(Style,1,1,RespIndex);
set(this.Curves,'Color',Color,'LineStyle',LineStyle,'Marker',Marker)