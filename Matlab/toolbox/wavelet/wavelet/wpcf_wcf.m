function wpcf_wcf(x,lev,wav,colmode,nb_colors,flg_line)
%WPCF_WCF Wavelet tree and wavelet packet tree coefficients.
%
%  Compute wavelet tree and wavelet packet tree
%  and plot the colored coefficients.
%
%  WPCF_WCF(X,N,W,COLMODE,NB_COLORS,FLG_LINE)
%    X is a vector.
%    N is the level of decomposition.
%    W is the name of wavelet
%    COLMODE is an integer which represents the color mode with:
%       1: 'FRQ : Global + abs'
%       2: 'FRQ : By Level + abs'
%       3: 'FRQ : Global'
%       4: 'FRQ : By Level'
%       5: 'NAT : Global + abs'
%       6: 'NAT : By Level + abs'
%       7: 'NAT : Global'
%       8: 'NAT : By Level'
%    NB_COLORS is the number of colors used.
%    FLG_LINE flag for separative lines
%
%  WPCF_WCF(X,N,W) is equivalent to WPCF_WCF(X,N,W,1,128,1)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Sep-98.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:43:15 $

switch nargin
  case 3 ,  flg_line = 1; nb_colors = 128; colmode = 1;
  case 4 ,  flg_line = 1; nb_colors = 128;
  case 5 ,  flg_line = 1;
end

t1 = wpdec(x,lev,wav);
t2 = wpdec(x,1,wav);
for k = 1:lev-1
   t2 = wpsplt(t2,[k,0]);
end

fig = figure;
axe = zeros(4,1);
axe(1) = subplot(2,2,1);
axe(2) = subplot(2,2,2);
axe(3) = subplot(2,2,3);
axe(4) = subplot(2,2,4);

lx  = length(x);
txt = ['Analyzed signal: length = ' int2str(lx)];
xlab = ['Colored Coefficients for Terminal Nodes'];
axes(axe(1)); plot(x,'r'); title(txt)
axes(axe(2)); plot(x,'r'); title(txt)
axes(axe(3)); wpviewcf(t2,colmode,nb_colors,flg_line); xlabel(xlab)
axes(axe(4)); wpviewcf(t1,colmode,nb_colors,flg_line); xlabel(xlab)
set(axe,'Xlim',[1 lx]);


function wpviewcf(wpt,colmode,nb_colors,flg_line)
%WPVIEWCF Plot wavelet packets colored coefficients.

axe = gca;
switch nargin
  case 1 , flg_line = 1; nb_colors = 128; colmode = 1;
  case 2 , flg_line = 1; nb_colors = 128;
  case 3 , flg_line = 1;
end
flg_line = 5*flg_line;
order = treeord(wpt);
depth = treedpth(wpt);
nodes = leaves(wpt);
sizes = fmdtree('tn_read',wpt,'sizes');
nbtn  = length(nodes);
[depths,posis] = ind2depo(order,nodes);
cfs   = read(wpt,'data');

if find(colmode==[1 2 3 4])
    ord = wpfrqord(nodes);
else
    ord = [1:nbtn];
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
   case 7 , strtit = 'Natural Order : Global';
   case 8 , strtit = 'Natural Order : By Level';
end

sizes = max(sizes,[],2);
deb = [1];
fin = [];
for k = 1:nbtn
    fin(k)   = deb(k)+sizes(k)-1;
    deb(k+1) = fin(k)+1;
end
nbrows   = (2.^(dmax-depths));
NBrowtot = sum(nbrows);
NBcoltot = max(read(wpt,'sizes',0));
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
ylim = [0 1];
alfa = 1/(2*NBrowtot);
ydata = [(1-alfa)*ylim(1)+alfa*ylim(2) (1-alfa)*ylim(2)+alfa*ylim(1)];
if NBrowtot==1
    ydata(1) = 1/2; ydata(2) = 1;
end
xlim = [1 NBcoltot];
colormap(cool(nb_colors));

set(axe,'Xlim',xlim,'Ylim',ylim,'Nextplot','replace');
imgcfs = image(...
               'Parent',axe,                       ...
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
             'Parent',axe,               ...
             'Xdata',[0.5 NBcoltot+0.5], ...
             'Ydata',[ymin(k) ymin(k)],  ...
             'Linewidth',2               ...
              )
    end
    NBdraw = NBdraw+1;
    if NBdraw==10 | k==nbtn
        set(imgcfs,'Xdata',[1:NBcoltot],'Ydata',ydata,'Cdata',matcfs);
        NBdraw = 0;
    end
end
ftnsize = get(0,'FactoryTextFontSize');
set(axe, ...
    'Ydir','reverse',                ...
    'Xlim',xlim,'Ylim',ylim,         ...
    'Ytick',ytics,'YtickLabel',ylabs,...
    'fontsize',ftnsize,              ...
    'Layer','top',                   ...
    'Box','on');
title(strtit,'Fontsize',ftnsize+1,'FontWeight','bold');
