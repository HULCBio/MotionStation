function wpplotcf(t,colorMode,axe,nb_colors)
%WPPLOTCF Plot wavelet packets colored coefficients.
%
%   WPPLOTCF(T) OR
%   WPPLOTCF(T,COLORMODE) OR
%   WPPLOTCF(T,COLORMODE,AXE) OR
%   WPPLOTCF(T,COLORMODE,AXE,NB_COLORS)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:39:21 $

% Tag for image of Coefficients.
%--------------------------------
tag_img_cfs = 'Img_WPCfs';

DefNBColor = 128;
if nargin<2
    colorMode = 1; axe = gca; nb_colors = DefNBColor;
elseif nargin<3
    axe = gca; nb_colors = DefNBColor;
elseif nargin<4
    nb_colors = DefNBColor;
end

order = treeord(t);
dmax  = treedpth(t);
nodes = leaves(t);
sizes = fmdtree('tn_read',t,'sizes');
nbtn  = length(nodes);
[depths,posis] = ind2depo(order,nodes);
cfs   = read(t,'data');

switch order
    case 2 , flg_line = 6;
    case 4 , flg_line = 5;
end
if     dmax==flg_line   , lwidth = 0.5;
elseif dmax==flg_line-1 , lwidth = 1;
else                    , lwidth = 2;
end

switch order
    case 2
        switch colorMode
            case {1,2,3,4} , ord = wpfrqord(nodes);
            case {5,6,7,8} , ord = [1:length(nodes)];
        end
        switch colorMode
            case {1,2,5,6} , abs_val = 1;
            case {3,4,7,8} , abs_val = 0;
        end
        switch colorMode
            case {1,3,5,7} , cfs = wcodemat(cfs,nb_colors,'row',abs_val);
        end
        sizes = max(sizes,[],2);
        deb = [1];
        fin = [];       
        for k = 1:nbtn
            fin(k)   = deb(k)+sizes(k)-1;
            deb(k+1) = fin(k)+1;
        end
        nbrows = (2.^(dmax-depths));
        NBrowtot = sum(nbrows);
        NBcoltot = max(read(t,'sizes',0));
        matcfs  = zeros(NBrowtot,NBcoltot);
        ypos    = zeros(nbtn,1);
        if nbtn>1
            for k = 1:nbtn
                ypos(ord(k)) = sum(nbrows(ord([1:k-1])));
            end
        end     
        ypos = NBrowtot+1-ypos-nbrows;
        ymin = (ypos-1)/NBrowtot;
        ymax = (ypos-1+nbrows)/NBrowtot;
        ylim = [0 1];
        alfa = 1/(2*NBrowtot);
        ydata = [(1-alfa)*ylim(1)+alfa*ylim(2) (1-alfa)*ylim(2)+alfa*ylim(1)];
        if NBrowtot==1
            ydata(1) = 1/2; ydata(2) = 1;
        end
        axes(axe);
        tag_axe = get(axe,'Tag');
        xlim = get(axe,'Xlim');
        set(axe,'Xlim',xlim,'Ylim',ylim,'Nextplot','replace');
        imgcfs = image(...
                       'Parent',axe,                       ...
                       'Xdata',[1:NBcoltot],               ...
                       'Ydata',ydata,                      ...
                       'Cdata',matcfs,                     ...
                       'Tag',tag_img_cfs,                  ...
                       'Userdata',[depths posis ymin ymax] ...
                       );
        NBdraw  = 0;
        for k = 1:nbtn
                d = depths(k);
                z = cfs(deb(k):fin(k));
                z = z(ones(1,2^d),:);
                z = wkeep1(z(:)',NBcoltot);
                if find(colorMode==[2 4 6 8])      
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
                         'Linewidth',lwidth          ...
                         );
                end
                NBdraw = NBdraw+1;
                if NBdraw==10 | k==nbtn
                    set(imgcfs,'Xdata',[1:NBcoltot], ...
                            'Ydata',ydata,'Cdata',matcfs);
                    NBdraw = 0;
                end
        end
        set(axe,'Ydir','reverse',...
                'layer','top',              ...
                'Xlim',xlim,'Ylim',ylim,    ...
                'Ytick',[],'YtickLabel',[], ...
                'Box','on','Tag',tag_axe);

    case 4

        % Image Coding Value.
        %-------------------
        codemat_v = wimgcode('get',get(axe,'Parent'));

        Xbase = 1;      Ybase = 1;
        hight = (Ybase./(2.^depths))';
        axes(axe);
        tag_axe = get(axe,'Tag');
        set(axe,'Xlim',[0 Xbase],'Ylim',[0 Ybase],'Nextplot','add');

        % Trunc images.
        %--------------
        size0 = read(t,'sizes',0);
        tmp   = size0(ones(dmax+1,1),:);
        for k = 2:dmax+1
            tmp(k,:) = floor((tmp(k-1,:)+1)/2);
        end
        newsiz = tmp(depths+1,:);

        deb = [1];
        fin = [];
        for k = 1:nbtn
            fin(k) = deb(k)+prod(sizes(k,:))-1;
            deb(k+1) = fin(k)+1;
        end
        large = (Xbase./(2.^depths))';
        xpos  = zeros(1,nbtn);
        ypos  = zeros(1,nbtn);

        tab   = zeros(nbtn,dmax+1);
        tab(:,1) = nodes;
        for j = 1:dmax
            tab(:,j+1) = floor((tab(:,j)-1)/order);
        end
        pos  = rem(tab,order)';
        vdiv = 1./(2.^[1:dmax]);
        for k = 1:nbtn
            d = depths(k);
            dx = 0; dy = 0;
            for j = 1:d
                l = d-j+1;
                if pos(l,k)==1
                        dy = dy + vdiv(j);
                elseif pos(l,k)==2
                        dx = dx + vdiv(j);
                        dy = dy + vdiv(j);
                elseif pos(l,k)==3;

                elseif pos(l,k)==0
                        dx = dx + vdiv(j);
                end
            end
            xpos(k) = Xbase*dx;
            ypos(k) = Ybase*dy;
        end

        wimg = newsiz(:,2)';
        himg = newsiz(:,1)';
        xmin = xpos+(0.5*large)./wimg;
        if sizes(:,2)>1
            xmax = xpos+((wimg-0.5).*large)./wimg;
        else
            xmax = xpos+large;
        end
        ymin = ypos+(0.5*hight)./himg;
        if sizes(:,1)>1
            ymax = ypos+((himg-0.5).*hight)./himg;
        else
            ymax = ypos+hight;
        end
        NBdraw = 1;
        if nbtn==1 , flg_code = 0; else flg_code = 1; end
        for k = 1:nbtn
            tmp    = zeros(sizes(k,:));
            tmp(:) = cfs(deb(k):fin(k));
            img = image([xmin(k) xmax(k)],[ymin(k) ymax(k)], ...
                    flipud(wimgcode('cod',flg_code,tmp,nb_colors,codemat_v,[depths(k) size0])),...
                    'Tag',tag_img_cfs,...
                    'Userdata',[depths(k) posis(k) xpos(k) xmax(k) ypos(k) ymax(k)],...
                    'Parent',axe);

            xx1 = xpos(k);
            xx2 = xx1+hight(k);
            yy1 = ypos(k);
            yy2 = yy1+hight(k);
            if dmax<=flg_line
                    lin = line(...
                            'Parent',axe,                   ...
                            'Xdata',[xx1 xx2 xx2 xx1 xx1],  ...
                            'Ydata',[yy1 yy1 yy2 yy2 yy1],  ...
                            'Linewidth',lwidth              ...
                            );
            end
            if NBdraw==4
                % drawnow;
                NBdraw = 1;
            else
                NBdraw = NBdraw+1;
            end
        end
        line(...
             'Parent',axe,        ...
             'Xdata',[0 1 1 0 0], ...
             'Ydata',[0 0 1 1 0], ...
             'Linewidth',2        ...
             );
        set(axe,'Tag',tag_axe);

        drawnow
end