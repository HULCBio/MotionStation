function setinput(this,t,u,varargin)
%SETINPUT  Defines driving input data for SIMPLOTs.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:00 $

% RE: Only used for LSIM-type plots (multi-output response data)
if prod(this.AxesGrid.Size(2))>1
   error('Cannot show input data on plots with multiple columns of axes.')
end
Ny = this.AxesGrid.Size(1);

% Error checking on t,u
t = t(:);
Ns = length(t);
uSize = size(u);
if ~isreal(u) | length(uSize)>2
   error('Input data must be a 2D matrix of real numbers.')
elseif ~any(uSize==Ns)
   error('Number of samples in time vector and amplitude data must agree.')
elseif uSize(1)~=Ns
   u = u.';
end
Nu = size(u,2);

% Adjust input width
setInputWidth(this,Nu);

% Write data
Axes = getaxes(this);
rInput = this.Input;
if strcmp(this.InputStyle,'tiled')
   for ct=1:Nu
      rInput.Data(ct).Time = t;
      rInput.Data(ct).Amplitude = u(:,ct);
      rInput.Data(ct).Focus = [t(1) t(end)];
   end
else
   rInput.Data.Time = t;
   rInput.Data.Amplitude = u;
   rInput.Data.Focus = [t(1) t(end)];
end
% Additional settings
if length(varargin)
   set(this.Input.Data,varargin{:});
end
   
% Redraw plot (ensures proper update of overall scene)
draw(this)
