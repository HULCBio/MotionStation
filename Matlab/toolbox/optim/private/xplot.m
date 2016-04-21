function [figps] = xplot(it,vval,vfnrm,vpos,vdeg,vpcg)
%XPLOT 4 performance graphs
%
%	figps = xplot(it,vval,vfnrm,vpos,vdeg,vpcg)
%
%	PLOT 4 OUTPUT GRAPHS ON 2-BY-2 DISPLAY   

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/02/07 19:13:48 $

% This is to avoid closing the figps window by accident
figtr = findobj('type','figure',...
   'Name','Progress Information') ; 
if ~isempty(figtr) 
   closebtn = findobj(figtr,'name','Close optimization windows') ;
   set(closebtn,'enable','off') ;
end ;

if it <= 0, 
   return; 
end

figps = findobj('type','figure',...
   'Name','Algorithm Performance Statistics') ;
if isempty(figps)
   screensize = get(0,'ScreenSize') ;
   ypos = floor((screensize(4) - 550)/2) ;
   figps = figure('Name', 'Algorithm Performance Statistics', ...
      'Position',[1 ypos 560 550]);
end ;
figure(figps) ;
itv = (1:it)';
subplot(2,2,1), 
%plot(itv,log10(vfnrm),'-',itv,log10(vfnrm),'go')
semilogy(itv,vfnrm,'-',itv,vfnrm,'go')
%title('First-order Optimality (log 10)')
title('Optimality progress per iteration');
xlabel('iteration')
ylabel('first-order optimality')
%

len = length(vpcg); itv = 1:1:len; itv = itv';
currsubplot=subplot(2,2,2);
plot(itv,vpcg,'-',itv,vpcg,'go');
if it < 6
   set(currsubplot,'Ytick',0:it);
end
title('PCG iterations per iteration');
xlabel('iteration')

itv = (1:length(vpos))';
if length(vpos) > 1
   vpos(1,1) = vpos(2,1);
end
vpos(vpos ==0)= -ones(length(vpos(vpos==0)),1);
currsubplot=subplot(2,2,3); 
plot(itv(vpos==1),vpos(vpos==1),'xr');
axis([0 it -2 2]);

hold on
currsubplot = subplot(2,2,3);
plot(itv(vpos==-1),vpos(vpos==-1),'ob');
set(currsubplot,'YTick',[-1 1]);
set(currsubplot,'YTickLabel',{'negative';'positive'});
title('Curvature of current direction');
xlabel('iteration');
hold off
%
if isempty(vdeg)
   vdeg = ones(it,1);
end
len = length(vdeg); 
itv = 1:1:len; 
itv = itv';
one = ones(len,1);
subplot(2,2,4)
%plot(itv,log10(vdeg),'-',itv,log10(vdeg),'go');
semilogy(itv,vdeg,'-',itv,vdeg,'go');
title('Constraint degeneracy')
xlabel('iteration')

if ~isempty(figtr) 
   set(closebtn,'Enable','on') ; 
end


