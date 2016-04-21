function applystyle(this,Style,RowIndex,ColIndex,RespIndex)
%APPLYSTYLE  Applies style of parent response.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:35 $
Color = getstyle(Style,1,1,RespIndex);
set([this.MagPoints(ishandle(this.MagPoints)) ; ...
      this.PhasePoints(ishandle(this.PhasePoints))],...
   'Color',Color,'MarkerEdgeColor',Color,'MarkerFaceColor',Color)