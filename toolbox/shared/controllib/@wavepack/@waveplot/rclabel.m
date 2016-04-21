function rclabel(this,varargin)
%RCLABEL  Maps ChannelName to axes' row labels.
 
%  Author(s): Bora Eryilmaz and P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:38 $

% Derive labels from I/O names
GridSize = this.AxesGrid.Size;
ChannelLabels = LocalGetLabels(GridSize(1),this.ChannelName);

% Pass labels to @axesgrid object
if ~isempty(ChannelLabels)
   this.AxesGrid.RowLabel = LocalFormat(ChannelLabels,GridSize(3));
end

%--------------------- Local Functions ----------------------------

function ChannelLabels = LocalGetLabels(RowSize,ChannelNames)
% Constructs row labels from channel names
% RE: Empty channel names translates into no labels.
if isempty(ChannelNames) | (RowSize==1 & isempty(ChannelNames{1}))
   ChannelLabels = {};
else
   ChannelLabels = ChannelNames;
   for ct=find(cellfun('isempty',ChannelNames))'
      ChannelLabels{ct} = sprintf('Ch(%d)',ct);
   end
end

function Names = LocalFormat(Names,RepFact)
% Derives axesgrid's row labels from channel labels
if RepFact>1,
   Names = repmat(Names',[RepFact 1]);
   Names = Names(:);
end
