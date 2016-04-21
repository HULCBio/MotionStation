function wpviewcf(wpt,colmode,nb_colors)
%WPVIEWCF Plot wavelet packets colored coefficients.
%   WPVIEWCF(T,CMODE) plots the colored coefficients
%   for the terminal nodes of the tree T.
%   T is a wptree Object.
%   CMODE is an integer which represents the color mode with:
%       1: 'FRQ : Global + abs'
%       2: 'FRQ : By Level + abs'
%       3: 'FRQ : Global'
%       4: 'FRQ : By Level'
%       5: 'NAT : Global + abs'
%       6: 'NAT : By Level + abs'
%       7: 'NAT : Global'
%       8: 'NAT : By Level'
%
%   wpviewcf(T,CMODE,NB) uses NB colors.
%
%   Example:
%     x = sin(8*pi*[0:0.005:1]);
%     t = wpdec(x,4,'db1');
%     plot(t);
%     wpviewcf(t,1);
%
%   See also WPDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Sep-96.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/04/20 23:21:47 $

% Check arguments.
switch nargin
  case 1 , nb_colors = 128; colmode = 1;
  case 2 , nb_colors = 128;
end
flg_line = 5;

order = treeord(wpt);
dmax = treedpth(wpt);
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

nbDIGIT   = ceil(log10(max(nodes)));
formatNum = ['%' sprintf('%d',nbDIGIT) '.0f'];
ylabs = ' ';
ylabs = ylabs(ones(nbtn,nbDIGIT));

for k = 1:nbtn
    ylabs(k,:) = sprintf(formatNum,nodes(k));
end

ylim = [0 1];
alfa = 1/(2*NBrowtot);
ydata = [(1-alfa)*ylim(1)+alfa*ylim(2) (1-alfa)*ylim(2)+alfa*ylim(1)];
if NBrowtot==1
    ydata(1) = 1/2; ydata(2) = 1;
end
xlim = [1 NBcoltot];
fig  = figure;
colormap(cool(nb_colors));
axe  = axes('Parent',fig);
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
    if dmax<=flg_line && nbtn~=1
        line(...
             'Parent',axe,               ...
             'Xdata',[0.5 NBcoltot+0.5], ...
             'Ydata',[ymin(k) ymin(k)],  ...
             'Linewidth',2               ...
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
    'Ydir','reverse',                ...
    'Xlim',xlim,'Ylim',ylim,         ...
    'Ytick',ytics,'YtickLabel',ylabs,...
    'fontsize',ftnsize,              ...
    'Layer','top',                   ...
    'Box','on');
title(strtit,'Fontsize',ftnsize+1,'FontWeight','bold');
