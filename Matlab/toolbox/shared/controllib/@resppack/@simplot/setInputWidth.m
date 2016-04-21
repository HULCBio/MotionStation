function setInputWidth(this,Nu)
%SETINPUTWIDTH  Specifies number of input channels for SIMPLOT.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:59 $

% RE: Only used for LSIM-type plots (multi-output response data)
if prod(this.AxesGrid.Size(2))>1
   error('Cannot show input data on plots with multiple columns of axes.')
end
Ny = this.AxesGrid.Size(1);
if strcmp(this.InputStyle,'paired')
   if Nu~=Ny
      error('The number of inputs and outputs must match when using "paired" option.')
   end
   Nnew = 1;
else
   Nnew = Nu;
end

% Adjust channel names
rInput = this.Input;
Nch = length(rInput.ChannelName);
rInput.ChannelName = [rInput.ChannelName(1:min(Nu,Nch)) ; repmat({''},Nu-Nch,1)];

% Adjust length of Data/View vectors
Nold = length(rInput.Data);
if Nold>Nnew
   % Delete extra data/view pairs
   rInput.Data = rInput.Data(1:Nnew);
   deleteview(rInput.View(Nnew+1:Nold))
   rInput.View = rInput.View(1:Nnew);
elseif Nold<Nnew
   % Add missing data/view pairs
   Axes = getaxes(this);
   [Data, View] = createinputview(this, Nnew-Nold);
   for ct=1:Nnew-Nold
      initialize(View(ct),Axes)
   end
   rInput.Data = [rInput.Data ; Data];
   rInput.View = [rInput.View ; View];
   % Update style
   applystyle(rInput)
   % Install tips
   addtip(rInput)
end
