function wpviewcf(Ts,Ds,colmode,nb_colors)
%WPVIEWCF Plot wavelet packets colored coefficients.
%   wpviewcf(T,D,CMODE) plots the colored coefficients
%   for the terminal nodes of the tree T.
%     T is the tree structure.
%     D is the data structure.
%     CMODE is an integer which represents the color mode with:
%   1: 'FRQ : Global + abs'
%   2: 'FRQ : By Level + abs'
%   3: 'FRQ : Global'
%   4: 'FRQ : By Level'
%   5: 'NAT : Global + abs'
%   6: 'NAT : By Level + abs'
%   7: 'NAT : Global'
%   8: 'NAT : By Level'
%
%   wpviewcf(T,D,CMODE,NB) uses NB colors.
%
%   Example:
%     x = sin(8*pi*[0:0.005:1]);
%     [t,d] = wpdec(x,4,'db1');
%     plottree(t);
%     wpviewcf(t,d,1);
%
%   See also MAKETREE, WPDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Sep-96.
%   Last Revision: 07-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.13.4.2 $

% Check arguments.
if errargn(mfilename,nargin,[2:4],nargout,[0]), error('*'), end
switch nargin
  case 2 , nb_colors = 128; colmode = 1;
  case 3 , nb_colors = 128;
end
flg_line = 5;

tab   = wtreemgr('table',Ts,0)';
nodes = tab(1,:)';
sizes = wdatamgr('rsizes',Ds);
nbtn  = size(tab,2);
order = wtreemgr('order',Ts);
[depths,posis]  = ind2depo(order,nodes);
dmax = size(tab,1)-1;
cfs  = wdatamgr('rallcfs',Ds);

if find(colmode==[1 2 3 4])
    ord = wpfrqord(nodes);
else
    ord = [1:length(nodes)];
end
if find(colmode==[1 2 5 6])
    abs_val = 1;
elseif find(colmode==[3 4 7 8])
    abs_val = 0;
end
if find(colmode==[1 3 5 7])
    cfs = wcodemat(cfs,nb_colors,'row',abs_val);
end

switch colmode
   case 1 , strtit = 'Frequency Order : Global + abs';
   case 2 , strtit = 'Frequency Order : By Level + abs';
   case 3 , strtit = 'Frequency Order : Global';
   case 4 , strtit = 'Frequency Order : By Level';
   case 5 , strtit = 'Natural Order : Global + abs';
   case 6 , strtit = 'Natural Order : By Level + abs';
   case 7 , strtit = 'Natural Order : Global'
   case 8 , strtit = 'Natural Order : By Level';
end

deb = [1];
fin = [];       
for k = 1:nbtn
    fin(k) = deb(k)+sizes(1+depths(k))-1;
    deb(k+1) = fin(k)+1;
end
nbrows   = (2.^(dmax-depths));
NBrowtot = sum(nbrows);
NBcoltot = sizes(1);
matcfs   = zeros(NBrowtot,NBcoltot);
ypos     = zeros(nbtn,1);

if nbtn>1
    for k = 1:nbtn
        ypos(ord(k)) = sum(nbrows(ord([1:k-1])));
    end
end     
ypos = NBrowtot+1-ypos-nbrows;
ymin = (ypos-1)/NBrowtot;
ymax = (ypos-1+nbrows)/NBrowtot;

ytics = (ymax+ymin)/2;
[ytics,K] = sort(ytics);
for k = 1:nbtn
    ylabs(k,:) = sprintf('%2.0f',nodes(k));
end
ylabs = ylabs(K,:);
ylim  = [0 1];
alfa  = 1/(2*NBrowtot);
ydata = [(1-alfa)*ylim(1)+alfa*ylim(2) (1-alfa)*ylim(2)+alfa*ylim(1)];
if NBrowtot==1
    ydata(1) = 1/2; ydata(2) = 1;
end
xlim = [1 NBcoltot];
fig  = figure;
colormap(cool(nb_colors));
axe  = axes;
set(axe,'Xlim',xlim,'Ylim',ylim,'Nextplot','replace');
imgcfs = image(...
               'Xdata',[1:NBcoltot],               ...
               'Ydata',ydata,                      ...
               'Cdata',matcfs,                     ...
               'Userdata',[depths posis ymin ymax] ...
                );
NBdraw  = 0;
for k = 1:nbtn
    d = depths(k);
    z = cfs(deb(k):fin(k));
    z = z(ones(1,2^d),:);
    z = wkeep1(z(:)',NBcoltot);
    if find(colmode==[2 4 6 8])      
        z = wcodemat(z,nb_colors,'row',abs_val);
    end
    r1 = ypos(k);
    r2 = ypos(k)+nbrows(k)-1;
    matcfs(r1:r2,:) = z(ones(1,nbrows(k)),:);
    if dmax<=flg_line & nbtn~=1
        line(...
             'Xdata',[0.5 NBcoltot+0.5], ...
             'Ydata',[ymin(k) ymin(k)],  ...
             'Linewidth',2              ...
             );
    end
    NBdraw = NBdraw+1;
    if NBdraw==10 | k==nbtn
        set(imgcfs,'Xdata',[1:NBcoltot],'Ydata',ydata,'Cdata',matcfs);
        NBdraw = 0;
    end
end
ftnsize = get(0,'FactoryTextFontSize');
set(axe, ...
    'Ydir','reverse',                 ...
    'Xlim',xlim,'Ylim',ylim,          ...
    'Ytick',ytics,'YtickLabel',ylabs, ...
    'fontsize',ftnsize,               ...
    'Layer','top',                    ...
    'Box','on');
title(strtit,'Fontsize',ftnsize+1,'FontWeight','bold');
