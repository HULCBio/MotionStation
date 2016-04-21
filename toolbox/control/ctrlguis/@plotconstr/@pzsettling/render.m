function render(Constr,varargin)
%RENDER sets the vertices, X and Y data properties of the patch and markers.

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:08:37 $

PlotAxes = Constr.Parent;
HostFig = double(PlotAxes.Parent);
Xlim = get(PlotAxes,'Xlim');   Xextent = Xlim(2)-Xlim(1);
Ylim = get(PlotAxes,'Ylim');   Yextent = Ylim(2)-Ylim(1);

if ~Constr.Activated
   % Preset for Activated->1: initialize graphics
   % Construct the constraint patch
   Patch = patch( ...
      'Parent', PlotAxes, ...
      'XlimInclude','off',...
      'YlimInclude','off',...        
      'EdgeColor','none', ...
      'CDataMapping','Direct', ...
      'FaceColor','interp', ...
      'HelpTopicKey','settlingtimeconstraint',...
      'UIContextMenu', Constr.addmenu(HostFig),...
      'ButtonDownFcn',Constr.ButtonDownFcn);
   
   % Transparent line to delimit extent for limit picker
   Edge = line('Parent', PlotAxes, 'LineStyle','none', ...
      'Color','k', 'HitTest','off');
   
   % Construct the constraint patch end markers
   Props = struct(...
      'Parent', PlotAxes,...
      'XlimInclude','off',...
      'YlimInclude','off',...        
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

% Constraint exp(Re(p)*st)<0.02
if Constr.Ts,
   % Discrete time: for z=rho*exp(i*theta), Re(p)=log(rho)/Ts<alpha -> rho_crit = exp(Ts*alpha)
   rho = Constr.geometry;
   theta = -pi:pi/40:pi;
   drho = Constr.Thickness * min(Xextent,Yextent);
   % Construct new X, Y and Z data for the patch
   nP = length(theta);
   X = cos(theta);   Y = sin(theta);
   PatchXData = [rho*X , (rho+drho)*fliplr(X)];
   PatchYData = [rho*Y , (rho+drho)*fliplr(Y)];
   
   % Plot left and right constraint selection markers in new position
   set(Constr.HG.Edge,'XData',[-rho,rho,0,0],'YData',[0,0,-rho,rho],...
      'ZData',Constr.Zlevel(ones(1,4)))
   if max(abs(Xlim))>Yextent/2,
      set(Constr.HG.Markers(1),'XData',-rho,'YData',0,'ZData',Constr.Zlevel);
      set(Constr.HG.Markers(2),'XData',rho,'YData',0,'ZData',Constr.Zlevel);
   else
      set(Constr.HG.Markers(1),'XData',0,'YData',-rho,'ZData',Constr.Zlevel);
      set(Constr.HG.Markers(2),'XData',0,'YData',rho,'ZData',Constr.Zlevel);
   end
else
   % Continuous time: vertical line x = alpha
   alpha = Constr.geometry;
   dX = Constr.Thickness * Xextent;
   % Construct new X, Y and Z data for the patch
   nP = 2;
   PatchXData = [alpha alpha alpha+dX alpha+dX];
   PatchYData = [Ylim  fliplr(Ylim)];
   
   % Plot left and right constraint selection markers in new position
   set(Constr.HG.Edge,'XData',alpha,'YData',0,'ZData',Constr.Zlevel)
   set(Constr.HG.Markers(1),'XData',alpha,'YData',Ylim(1),'ZData',Constr.Zlevel)
   set(Constr.HG.Markers(2),'XData',alpha,'YData',Ylim(2),'ZData',Constr.Zlevel)
end

% Set patch parameters
Vertices = [PatchXData(:) PatchYData(:) Constr.Zlevel(ones(2*nP,1),:)];
Faces = [1:nP-1 ; 2:nP ; 2*nP-1:-1:nP+1 ; 2*nP:-1:nP+2]';
ColorData = [40*ones(nP,1);64*ones(nP,1)];
set(Constr.HG.Patch,'Faces',Faces,'FaceVertexCData',ColorData,'Vertices',Vertices)

