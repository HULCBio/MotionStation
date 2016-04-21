function applystyle(this,Style,RowIndex,ColumnIndex,RespIndex)
%APPLYSTYLE  Applies style to root locus plot.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:02 $
[Color,LineStyle,Marker] = getstyle(Style,1,1,RespIndex);
set(this.Locus,'Color',Color,'LineStyle',LineStyle,'Marker',Marker)
set([this.SystemZero,this.SystemPole],'Color',Color)
