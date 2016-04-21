%function [delta,lowerbnd,upperbnd] = wcperf(Mg,blk,pertsizew,npts)
%
%   Calculates worst-case performance for an upper-loop
%       Linear Fractional Transformation.
%       
%   Inputs: MG        - input matrix, CONSTANT/VARYING
%           BLK       - block structure
%           PERTSIZEW - size of the perturbation
%	    NPTS      - number of perturbation points (default is 1)
%
%  Outputs: DELTA     - worst-case perturbation
%           LOWERBND  - lower bound on the perturbation(s) 
%           UPPERBND  - upper bound on the perturbation(s) 
%
%   See also:  MU, DYPERT

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [delta,lowerbnd,upperbnd] = wcperf(sysg,blk,pertsizew,npts,opt)

    diagnose = 0;

    if nargin == 0 | nargin == 1 | nargin == 2
        disp('usage: [delta,lowerbound,upperbound] = wcperf(sysg,blk,pertsize)')
        return
    elseif nargin == 3
        npts = 1;
        opt = 'd';
    elseif nargin == 4 | nargin == 5
        if isempty(npts)
            npts = 5;
        else
            if floor(npts(1))==ceil(npts(1)) & npts(1)>0
                npts = npts(1);
            else
                error('Npts should be a positive integer');
                return
            end
        end
    end
    if nargin == 5
        if ~isstr(opt)
            error('Options should be a string');
            return
        end
    elseif nargin == 4
        opt = 'd';  % default
    end

    startalpha = [.3 1 1/.3];
    perctol = 0.01;
    itermax = npts + 10;

    [nblk,dum] = size(blk);
    if dum~=2
        error('Invalid Block structure');
        return
    end
    [mtype,mrows,mcols,mnum] = minfo(sysg);
    repblks = find(blk(:,2)==0);
    ablk = abs(blk);
    if length(repblks)>0
        ablk(repblks,2) = ablk(repblks,1);
    end
    rdimblk = sum(ablk(:,1));
    cdimblk = sum(ablk(:,2));
    if rdimblk<mcols & cdimblk<mrows
        blk = [blk;[mcols-rdimblk mrows-cdimblk]];
        nblk = nblk + 1;
        ablk = abs(blk);
    elseif rdimblk~=mcols | cdimblk~=mrows
        error('Dimension error in Uncertainty Structure')
        return
    end
    cperf = ablk(nblk,1);
    rperf = blk(nblk,2);
    if rperf == 0
        disp('Performance block is Repeated Scalar...');
	return
        %rperf = cperf;      % get dimension correct
    end

    nominal = pkvnorm(sel(sysg,mrows-rperf+1:mrows,mcols-cperf+1:mcols));
    if any(blk(1:nblk-1,1)>0)
        [bnds,dvec,sens,pvec] = mu(sel(sysg,1:mrows-rperf,1:mcols-cperf),...
            blk(1:nblk-1,:),'csw');
        mubnd = pkvnorm(sel(bnds,1,2));
        if mubnd==0
            disp('        Guaranteed: No Perturbation Destabilizes');
            xdestab = inf;
            topbnd = 2*pertsizew;
        else
            xdestab = 1/pkvnorm(sel(bnds,1,2)); 
            topbnd = xdestab;
        end
    else
        [bnds,dvec,sens,pvec] = mu(sel(sysg,1:mrows-rperf,1:mcols-cperf),...
            blk(1:nblk-1,:),'csw');
        xdestabi = pkvnorm(sel(bnds,1,2)); 
        if xdestabi==0
            disp('Warning: Uncertainty Structure is All Real');
            [bnds,dvec,sens,pvec] = mu(sel(sysg,1:mrows-rperf,1:mcols-cperf),...
                abs(blk(1:nblk-1,:)),'csw');
            cmubnd = pkvnorm(sel(bnds,1,2)); 
            if cmubnd==0
                disp('        Guaranteed: No Perturbation Destabilizes');
                xdestab = inf;
                topbnd = 2*pertsizew;
            else
                disp('        Unable to find destabilizing Delta');
                xdestab = inf;
                topbnd = 1/cmubnd;
            end
        else
            xdestab = 1/xdestabi;
            topbnd = xdestab;
        end
    end

    deltafound = 0;
    if pertsizew>=xdestab
        disp('Perturbation Size is destabilizing')
        deltadestab = dypert(pvec,blk(1:nblk-1,:),bnds,[1:nblk-1]);
        pertsizew = xdestab;
        deltafound = 1;
    end

    xl = 0;
    yl = nominal;
    xu = 0;
    yu = nominal;


    [out,delta] = onealpha(sysg,blk,startalpha,pertsizew,perctol);
    xl = [xl;out(:,1)];
    yl = [yl;out(:,2)];
    xu = [xu;out(:,3)];
    yu = [yu;out(:,4)]; 
    [xls,index] = sort(xl);
    yls = yl(index); 
    if isempty(delta)
        dist = inf;
    else
        ndelta = hinfnorm(delta);
        ndelta = ndelta(1);
        bestdelta = delta;
        dist = abs(ndelta-pertsizew);
    end
    cnt = 0;
    gap = max(diff(xls));
    gap = max([gap topbnd-max(xls)]);

 while cnt<itermax & (gap>topbnd/npts | deltafound==0) & nargin >= 3
    newalpha = [];
    if length(xl)==2
        p = polyfit(xl,yl,1);
    elseif length(xl)==3
        p = polyfit(xl,yl,1);
    elseif length(xl)==4
        p = polyfit(xl,yl,2);
    else
        p = polyfit(xl,yl,min([5 length(xl)-3]));
    end
    if diagnose==1
        xx = linspace(0,1.2*topbnd,100);
        plot(xl,yl,'+',xx,polyval(p,xx));
        drawnow
    end
    f1=0;f2=0;
    if gap>topbnd/npts
        f1 = 1;
        loc = find(gap==diff(xls));
        if isempty(loc)
            pertsize = 1.2*max(xls);
            pdt = polyval(p,pertsize);
            alpha = 1/pertsize/pdt;
            newalpha = [newalpha alpha];
        else
            pertsize = (xls(loc)+xls(loc+1))/2;
            pdt = polyval(p,pertsize);
            fb = yls(loc);
            ft=fb+(yls(loc+1)-yls(loc))/(xls(loc+1)-xls(loc))*(pertsize-xls(loc));
            if pdt<fb | pdt>ft
                pdt = 0.5*(ft+fb);
            end
            alpha = 1/pertsize/pdt;
            newalpha = [newalpha alpha];
        end
    end
    if deltafound==0
        xli = max(find(xls<pertsizew));
        xleft = xls(xli);
        xri = min(find(xls>pertsizew));
        xright = xls(xri);
        pdt = polyval(p,pertsizew);
        fb = yls(xli);
        ft=fb+(yls(xri)-yls(xli))/(xls(xri)-xls(xli))*(pertsizew-xls(xli));
        if ~(isempty(fb) | isempty(ft))
          if pdt<fb | pdt>ft
            pdt = 0.5*(ft+fb);
          end
        end
        f2 = 1;
        newalpha = [newalpha 1/pertsizew/pdt];
    end
    [newalpha f1 f2];
    [out,delta] = onealpha(sysg,blk,newalpha,pertsizew,perctol);
    if ~isempty(delta)
        deltafound = 1;
        ndelta = hinfnorm(delta);
        ndelta = ndelta(1);
        if abs(ndelta-pertsizew)<dist
            bestdelta = delta;
            dist = abs(ndelta-pertsizew);
        end
    end
    xl = [xl;out(:,1)];
    yl = [yl;out(:,2)]; 
    xu = [xu;out(:,3)];
    yu = [yu;out(:,4)]; 
    cnt = cnt+1;
    [xls,index] = sort(xl);
    gap = max(diff(xls));
    gap = max([gap topbnd-max(xls)]);
    yls = yl(index);
end
delta = bestdelta;
if nargout > 1
    [xls,index] = sort(xl);
    lowerbnd = vpck(yl(index),xls);
    [xus,index] = sort(xu);
    upperbnd = vpck(yu(index),xus);
end
