function render(Constr,varargin)
%RENDER sets the vertices, X and Y data properties of the patch and markers.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:10:14 $

PlotAxes = Constr.Parent;
HostFig = double(PlotAxes.Parent);
Xlim = get(PlotAxes,'Xlim');   
Ylim = get(PlotAxes,'Ylim');
Extent = min(Xlim(2)-Xlim(1),Ylim(2)-Ylim(1));
csgn = sign(.5-strcmp(Constr.Type,'lower'));

if ~Constr.Activated
   % Initialize when constraint is not activated yet (preset for Activated=1)
   % Construct the constraint patch
   Patch = patch( ...
      'Parent', PlotAxes, ...
      'XlimInclude','off',...
      'YlimInclude','off',...        
      'EdgeColor','none', ...
      'CDataMapping','Direct', ...
      'FaceColor','interp', ...
      'HelpTopicKey','naturalfrequencyconstraint',...
      'UIContextMenu', Constr.addmenu(HostFig),...
      'ButtonDownFcn',Constr.ButtonDownFcn);
   
   % Transparent line to delimit extent for limit picker
   % REVISIT: consider making edge visible when Z layering works properly
   Edge = line('Parent', PlotAxes, 'Color', [0 0 0], ...
      'LineStyle','none', 'HitTest','off');
   
   % Construct the constraint patch end markers
   Markers = line(...
      'Parent', PlotAxes,...
      'LineStyle','none', ...
      'Marker','s', ...
      'MarkerSize',4, ... 
      'MarkerFaceColor','k', ...
      'MarkerEdgeColor','k', ...
      'HitTest','off',...
      'Visible',Constr.Selected);
   
   % Store handles
   Constr.HG = struct('Patch',Patch,'Edge',Edge,'Markers',Markers);
end

% Constraint rendering
if Constr.Ts,
   % Discrete time: the z-domain curve for w0 is parameterized as
   %    exp(-w0*Ts*exp(j*phi))  with |phi|<=phi0 
   % and
   %    phi0 = pi/2 if pi/w0/Ts>1, asin(pi/w0/Ts) otherwise
   w0 = Constr.Ts * Constr.Frequency;
   if w0<pi
      phi0 = pi/2;
   else
      phi0 = asin(pi/w0);
   end
   phi = phi0 * (-1:1/64:1);
   nP = length(phi);
   Z0 = exp(-w0 * exp(1i*phi));
   % Perturb w0 to derive the outer edge
   w1 = w0 + max(csgn*Constr.Thickness*Extent,-.99*w0);  
   Z1 = exp(-w1 * exp(1i*phi));
   
   % Construct X, Y data for the patch
   PatchXData = [real(Z0) , fliplr(real(Z1))];
   PatchYData = [imag(Z0) , fliplr(imag(Z1))];
   
   % Plot left and right constraint selection markers in new position
   r0 = exp(-w0);
   set(Constr.HG.Edge,'XData',real(Z0),...
      'YData',imag(Z0),'ZData',Constr.Zlevel(ones(size(Z0))))
   set(Constr.HG.Markers,'XData',r0,'YData',0,'ZData',Constr.Zlevel)
else
   % Continuous time: half circle of radius Constr.Frequency
   theta = pi*(0.5:1/64:1.5);
   w0 = Constr.Frequency;
   w1 = w0 + max(csgn*Constr.Thickness*Extent,-.99*w0);
   
   % Construct X, Y data for the patch
   nP = length(theta);
   X = cos(theta);   Y = sin(theta);
   PatchXData = [w0*X , w1*fliplr(X)];
   PatchYData = [w0*Y , w1*fliplr(Y)];
   
   % Plot left and right constraint selection markers in new position
   set([Constr.HG.Markers,Constr.HG.Edge],...
      'XData',-w0,'YData',0,'ZData',Constr.Zlevel)
end

% Set patch parameters
Vertices = [PatchXData(:) PatchYData(:) Constr.Zlevel(ones(2*nP,1),:)];
Faces = [1:nP-1 ; 2:nP ; 2*nP-1:-1:nP+1 ; 2*nP:-1:nP+2]';
ColorData = [40*ones(nP,1);64*ones(nP,1)];
set(Constr.HG.Patch,'Faces',Faces,'FaceVertexCData',ColorData,'Vertices',Vertices);

