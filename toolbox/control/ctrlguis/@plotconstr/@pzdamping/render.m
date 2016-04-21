function render(Constr,varargin)
%RENDER sets the vertices, X and Y data properties of the patch and markers.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:10:44 $

PlotAxes = Constr.Parent;
HostFig = double(PlotAxes.Parent);
Xlim = get(PlotAxes,'Xlim');   
Ylim = get(PlotAxes,'Ylim');

if ~Constr.Activated
   % Initialize when constraint is not activated yet (preset for Activated=1)
   % Construct the constraint patch
   Props = struct(...
      'Parent', PlotAxes, ...
      'XlimInclude','off',...
      'YlimInclude','off',...        
      'EdgeColor','none', ...
      'CDataMapping','Direct', ...
      'FaceColor','interp', ...
      'HelpTopicKey','dampingratioconstraint',...
      'UIContextMenu', Constr.addmenu(HostFig),...
      'ButtonDownFcn',{Constr.ButtonDownFcn});
   Patch = [patch(Props);patch(Props)];
   
   % Transparent line to delimit extent for limit picker
   % REVISIT: consider making edge visible when Z layering works properly
   Edge = line('Parent', PlotAxes, 'Color', [0 0 0], ...
      'LineStyle','none', 'HitTest','off');
   
   % Construct the constraint end markers
   Props = struct(...
      'Parent', PlotAxes,...
      'LineStyle','none', ...
      'Marker','s', ...
      'MarkerSize',4, ... 
      'MarkerFaceColor','k', ...
      'MarkerEdgeColor','k', ...
      'HitTest','off',...
      'Visible',Constr.Selected);
   Markers = [line(Props);line(Props)];
   
   % Store handles
   Constr.HG = struct('Patch',Patch,'Edge',Edge,'Markers',Markers);
end

% Draw
if Constr.Ts,
   % Discrete time: isodamping lines are 
   %      rho   = exp(-Zeta*t)
   %      theta = +/-sqrt(1-Zeta^2)*t
   % with theta in t in [0,pi/sqrt(1-Zeta^2)]
   zeta0 = Constr.Damping; 
   tmax = pi/sqrt(1-min(.99,zeta0)^2);
   t = tmax * (0:1/64:1);
   Z0 = exp((-zeta0 + 1i * sqrt(1-zeta0^2))*t);
   % Perturb zeta0 to derive the outer edge
   zeta1 = zeta0 - Constr.Thickness * (1+zeta0*(1-zeta0));
   Z1 = exp((-zeta1 + 1i * sqrt(1-zeta1^2))*t);
   
   % Construct X, Y data for the patch
   nP = length(t);
   PatchXData = [real(Z0) , fliplr(real(Z1))];
   PatchYData = [imag(Z0) , fliplr(imag(Z1))];
   
   % Plot left and right constraint selection markers in new position
   Xm = -exp(-zeta0*tmax);
   Ze = [Z0 fliplr(conj(Z0))];
   set(Constr.HG.Edge,'XData',real(Ze),'YData',imag(Ze),...
      'Zdata',Constr.Zlevel(ones(size(Ze))));
   set(Constr.HG.Markers(1),'XData',Xm,'YData',0,'Zdata',Constr.Zlevel);
   set(Constr.HG.Markers(2),'XData',1,'YData',0,'Zdata',Constr.Zlevel);
else
   % Continuous time: ray  x = -Zeta*t, y = sqrt(1-Zeta^2)*t
   rho = 2*(max(1,abs(Xlim(1)))+max(1,abs(Ylim(1))));
   c = Constr.Damping;   s = sqrt(1-c^2);
   X = -rho*c;   Y = rho*s;
   
   % Construct X, Y data for the patch
   nP = 2;
   DAR = get(PlotAxes,'DataAspectRatio');
   dX = Constr.Thickness * (Xlim(2)-Xlim(1)) * sqrt(s^2+(c*DAR(2)/DAR(1))^2)/max(0.1,s);
   PatchXData = [0 X X+dX dX];
   PatchYData = [0 Y Y 0];
   
   % Plot left and right constraint selection markers in new position
   rm = -max(Xlim(1),Ylim(1))/2;
   set(Constr.HG.Edge,'XData',0,'YData',0,'Zdata',Constr.Zlevel);
   set(Constr.HG.Markers(1),'XData',-rm*c,'YData',rm*s,'Zdata',Constr.Zlevel);
   set(Constr.HG.Markers(2),'XData',-rm*c,'YData',-rm*s,'Zdata',Constr.Zlevel);
end

% Set patch parameters
PatchZdata = Constr.Zlevel(ones(2*nP,1),:);
Faces = [1:nP-1 ; 2:nP ; 2*nP-1:-1:nP+1 ; 2*nP:-1:nP+2]';
ColorData = [40*ones(nP,1);64*ones(nP,1)];
set(Constr.HG.Patch(1),'Faces',Faces,'FaceVertexCData',ColorData,...
   'Vertices',[PatchXData(:) PatchYData(:) PatchZdata]);
set(Constr.HG.Patch(2),'Faces',Faces,'FaceVertexCData',ColorData,...
   'Vertices',[PatchXData(:) -PatchYData(:) PatchZdata]);

