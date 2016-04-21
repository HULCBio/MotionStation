function boo = checksize(this,dataobj)
%CHECKSIZE  Checks data size against waveform size.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:08 $
rcsize = getsize(dataobj);
boo = all(isnan(rcsize) | rcsize==[length(this.RowIndex),length(this.ColumnIndex)]);
