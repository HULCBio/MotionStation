function xtrack(x, g, l, u, init)
%XTRACK display graph
%
%   xtrack(x, g, l, u)
%
%   Output display showing the components of g
%   and the components of x, relative to the bounds l,u
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/02/01 22:09:50 $

set(gcf,'doublebuffer','on');

if nargin < 5
   init = '';
end
if any(isnan(l)) | any(isnan(u))
   error('optim:xtrack:NaNBounds','NaN in lower or upper bounds.')
end

n = length(x);  
index = (1:n)'; 
onen = ones(n,1);

maxg = max(abs(g)); 
maxg = max(maxg,1); 
zeron = zeros(n,1);
midpoint = zeron;

arg1 = (u < inf) & (l > -inf);
arg2 = (u < inf) & ( l == -inf);
arg3 = (u == inf) & ( l > -inf);
arg4 = (u == inf) & (l == -inf);

newx = x;

% Shift and scale
dist = zeron;
dist(arg1) = min((x(arg1)-l(arg1)) ./ max(abs(l(arg1)),onen(arg1)), ...
   (u(arg1)-x(arg1)) ./ max(abs(u(arg1)),onen(arg1)));
dist(arg2) = (u(arg2)-x(arg2)) ./ max(abs(u(arg2)), onen(arg2));
dist(arg3) = (x(arg3)-l(arg3)) ./ max(abs(l(arg3)), onen(arg3)); 
argu = (u < inf) & (dist == (u-x) ./ max(abs(u),onen));
argl = (l > -inf) & (dist == (x-l) ./ max(abs(l),onen));
dist = min(dist, onen-.001*onen);
dist = max(dist, eps*onen);
xlog = min(-onen ./ log(dist),onen);
newx(argl) = -1*(onen(argl)- xlog(argl));
newx(argu) = 1*(onen(argu)-xlog(argu));
newx(arg4) = zeron(arg4);

% Compute active constraints
activel=(abs(x-l)< 1e-5*max(abs(l),onen));
activeu=(abs(u-x)< 1e-5*max(abs(u),onen));

% Scale g
newg = g/(maxg + 1);
w = max(abs(newg),eps*onen);
glog = -onen./log(w);
glog = min(glog,onen);
newg = sign(newg).*glog;
activeg = (abs(g) < 1e-6);

switch init
case ''       % default case
   % Update Plots
   % Upper plot
   subplot(2,1,1) ;
   activex = activel | activeu ;
   set(findobj(gca,'tag','blueline'),'XData',index(~activex),'YData',newx(~activex));
   set(findobj(gca,'tag','redline'),'XData',index(activex),'YData',newx(activex));
   
   % Lower Plot
   subplot(2,1,2);
   set(findobj(gca,'tag','blueline'),'XData',index(~activeg),'YData',newg(~activeg));
   set(findobj(gca,'tag','redline'),'XData',index(activeg),'YData',newg(activeg));
   
case 'init'
   % Calculate markersize
   units = get(gca,'units') ; set(gca,'units','points') ;
   pos = get(gca,'position'); 
   marksize = max(1,min(15,round(3*pos(3)/n)));
   set(gca,'units',units);
   
   % Upper Plot
   currsubplot = subplot(2,1,1) ;
   lin(1)=plot(index,newx, 'b.','markersize',marksize,'tag','blueline');
   
   hold on;
   lin(2)=plot([-1;index(activel);index(activeu)],[0;newx(activel);newx(activeu)],'r.','markersize',marksize,'tag','redline');
   set(currsubplot,'YTick',[-1 1]);
   if n < 10
      set(currsubplot,'XTick',1:n);
   end
   set(currsubplot,'YTickLabel',{'lower';'upper'});
   axis([1, n, -1, 1]) 
   title('Relative position of x(i) to upper and lower bounds (log-scale)');
   ylabel('x(i)')
   hold off;
   
   [leg,objh]=legend(lin,'Free Variables','Variables at bounds');
   set(findobj(objh,'type','line'),'MarkerSize',15);
   set(leg,'Position',[.5 .23 .19 .08]) ;
   uicontrol('Style','text', 'Units','normalized', ...
      'Position',[.5 .315 .19 .05], 'String', 'UPPER PLOT'); 
   
   % Lower Plot
   currsubplot = subplot(2,1,2);
   lin(1)=plot([0;index],[-1;newg],'b.','tag','blueline','markersize',marksize);
   hold on;
   lin(2)=plot([0;index(activeg)],[-1;newg(activeg)],'r.','tag','redline','markersize',marksize);
   set(currsubplot,'YTick',[-1 0 1]);
   if n < 10
      set(currsubplot,'XTick',1:n);
   end
   axis([1, n, -1, 1]) ;
   xlabel('i^{th} component')
   ylabel('gradient')
   title('Relative gradient scaled to the range -1 to 1')
   hold off;
   
   [leg,objh]=legend(lin,'abs(gradient) > tol','abs(gradient) <= tol');
   set(leg,'Position',[.5 .05 .19 .08]);
   set(findobj(objh,'type','line'),'MarkerSize',15);
   uicontrol('Style','text', ...
      'Units','normalized', ...
      'Position',[.5 .135 .19 .05], ...
      'String', 'LOWER PLOT')
   
   
otherwise
   error('optim:xtrack:InvalidInit', ...
         'Invalid string used for INIT argument to XTRACK.');
end
