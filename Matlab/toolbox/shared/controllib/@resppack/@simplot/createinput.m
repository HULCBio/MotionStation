function createInput(this)
% Creates @siminput object for storing input data

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:51 $
rInput = resppack.siminput;

rInput.Parent = this;
rInput.RowIndex = 1:length(this.OutputName);
rInput.ColumnIndex = 1;
rInput.Visible = 'off';
rInput.Name = 'Driving inputs';
rInput.ChannelName = {''};  % tracks input names

% Create one data/view pair (single input)
[rInput.Data, rInput.View] = createinputview(this, 1);
initialize(rInput.View,getaxes(this))

% Add listeners
addlisteners(rInput)

% Line styles
LineStyles = {'-';'--';':';'-.'};
Style = wavepack.wavestyle;
Style.Colors = {[.6 .6 .6]};  % gray
Style.LineStyles = reshape(LineStyles,[1 1 4]);
Style.Markers = {'none'};
rInput.Style = Style;

% Install tips
addtip(rInput)

this.Input = rInput;


