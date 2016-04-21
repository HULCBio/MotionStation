function mask = refreshmask(this)
%REFRESHMASK  Builds visibility mask for REFRESH.
%
%  MASK = REFRESHMASK(RESPPLOT) constructs the visibility mask
%  used by REFRESH.  This mask is similar to the data visibility
%  mask (see DATAVIS) except that ungrouped channels are always 
%  considered visible (the effective visibility of their contents
%  being controlled by the ContentsVisible property of the 
%  corresponding axes). 
%
%  MASK is a boolean array of the same size as the axes grid 
%  (see GETAXES).  False entries flag channels that are both grouped
%  and hidden, and therefore require manual control of the 
%  visibility of their contents.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:39 $

mask = true(this.AxesGrid.Size);
if strcmp(this.Visible,'on') & strcmp(this.ChannelGrouping,'all')
   mask(strcmp(this.ChannelVisible,'off'),:) = false;
end
