function rclabel(this,varargin)
%RCLABEL  Maps InputName and OutputName to axes' row and column labels.
 
%  Author(s): Bora Eryilmaz and P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:40 $

% Derive labels from I/O names
GridSize = this.AxesGrid.Size;
[NoOutput,NoInput] = hasFixedSize(this);
[OutputLabels,InputLabels] = Local_IO_Labels(GridSize,...
   this.OutputName,this.InputName,NoOutput,NoInput);

% Pass labels to @axesgrid object
if ~isempty(InputLabels)
   this.AxesGrid.ColumnLabel = LocalFormat(InputLabels,GridSize(4));
end
if ~isempty(OutputLabels)
   this.AxesGrid.RowLabel = LocalFormat(OutputLabels,GridSize(3));
end

%--------------------- Local Functions ----------------------------

function [OutputLabels,InputLabels] = Local_IO_Labels(GridSize,OutputNames,InputNames,NoOutput,NoInput)
% Constructs I/O labels from I/O names
% RE: Empty I/O names translates into no labels.
if all(GridSize([1 2])==1) && ~(NoInput || NoOutput)
   % Special handling of SISO case with I/O names
   if isempty(OutputNames{1}) && isempty(InputNames{1})
      InputLabels = {''};
   else
      InputLabels = strcat({'From: '},LocalFillName(InputNames,'In'),...
         {'  To: '},LocalFillName(OutputNames,'Out'));
   end
   % RE: Set OutputLabels={} to prevent overwriting preset labels (cf. Bode mag/phase labels)
   OutputLabels = {};
else
   % General case (separate handling of input and output names)
   if NoInput
      InputLabels = {};
   elseif all(GridSize([2 4])==1) && isempty(InputNames{1})
      % RE: No input label for single-input plot with unspecified input name
      InputLabels = repmat({''},[GridSize(2) 1]);
   else
      InputLabels = strcat({'From: '},LocalFillName(InputNames,'In'));
   end
   if NoOutput
      OutputLabels = {};
   elseif all(GridSize([1 3])==1) & isempty(OutputNames{1})
      % RE: No output label for single-output plot with unspecified output name
      OutputLabels = repmat({''},[GridSize(1) 1]);
   else
      OutputLabels = strcat({'To: '},LocalFillName(OutputNames,'Out'));
   end
end
      

function Names = LocalFillName(Names,Symbol)
% Fills missing I/O names
for ct=1:length(Names)
   if isempty(Names{ct})
      Names{ct} = sprintf('%s(%d)',Symbol,ct);
   end
end


function Names = LocalFormat(Names,RepFact)
% Derives input or output labels from InputName and OutputName values
if RepFact>1,
   Names = repmat(Names',[RepFact 1]);
   Names = Names(:);
end   