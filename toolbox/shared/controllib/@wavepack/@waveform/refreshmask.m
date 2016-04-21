function Mask = refreshmask(this)
%REFRESHMASK  Builds visibility mask for REFRESH.
%
%  Same as WAVEPLOT/REFRESHMASK, but also takes RowIndex and 
%  ColumnIndex into account.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:18 $
Mask = refreshmask(this.Parent);
Mask = Mask(this.RowIndex,this.ColumnIndex,:,:);