function h = firceqrip(N,fo,del,ARG1,ARG2,ARG3,ARG4,ARG5,ARG6,ARG7,ARG8)
%FIRCEQRIP  Constrained equiripple FIR filter design.
%   H = FIRCEQRIP(N,Fo,del) designs a length N+1 lowpass linear-phase FIR 
%   filter with cut-off frequency Fo. The 2-element vector 
%   del = [d1 d2] specifies the error in the pass-band and stop-band.
%   At the cut-off frequency Fo the frequency response magnitude is 0.5.
%   Fo should be between 0 and 1 (0 < Fo < 1).
%
%   This function produces the same equiripple lowpass filters as the 
%   FIRPM (Parks-McClellan) algorithm, however, the specifications are 
%   supplied differently. 
%
%   H = FIRCEQRIP(...,'slope',R) designs a filter with a nonequiripple stop-band.
%   R is the slope of the in DB (R > 0) [try R = 10].
%
%   H = FIRCEQRIP(...,'passedge') designs a filter where Fo is the passband edge.
%   H = FIRCEQRIP(...,'stopedge') designs a filter where Fo is the stopband edge.
%
%   H = FIRCEQRIP(...,'high') designs a highpass filter.
%
%   H = FIRCEQRIP(...,'min') designs a minimum-phase FIR filter.
%
%   H = FIRCEQRIP(...,'invsinc',C) designs a lowpass filter with a pass-band 
%   having the shape of an inverse-sinc function, 1/sinc(C*f).
%   If C is a two-element vector, C = [c p], then the shape of the
%   pass-band is 1/sinc(c*f)^p. [c < 1/wo].
%
%   Several trailing arguments can be used simultaneously.
%   The order of the optional trailing arguments is not important.
%
%   Note: The linear-phase lowpass [highpass] filters will be Type I or II 
%   [Type I or IV] depending on the parameter N specified by the user.
%
%   Note: If Fo is too small or too large, or if c or p is too large, then 
%   the supplied specifications will be unfeasible or the design algorithm
%   may fail.
%
%   % Examples
%   h = firceqrip(30,0.4,[0.05 0.03]); fvtool(h)
%   h = firceqrip(30,0.4,[0.05 0.03],'stopedge'); fvtool(h)
%   h = firceqrip(30,0.4,[0.05 0.03],'slope',20,'stopedge'); fvtool(h)
%   h = firceqrip(30,0.4,[0.05 0.03],'stopedge','min'); fvtool(h)
%   h = firceqrip(30,0.4,[0.05 0.03],'invsinc',[2 1.5]); fvtool(h)
%
%   See also FIRGR, FIRCLS, FIRLS, IIRLPNORM, IIRLPNORMC, IIRGRPDELAY,
%   IFIR, FIRNYQUIST, FIRHALFBAND.

%   Author(s): Ivan Selesnick
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2004/04/12 23:25:24 $


%    Reference:
%   I. W. Selesnick and C. S. Burrus, "Exchange Algorithms that 
%   Complement the Parks-McClellan Algorithm for Linear Phase FIR 
%   Filter Design", IEEE Trans. on Circuits and Systems, Part II, 
%   vol. 44, no. 2, pp. 137-143, Feburary 1997. 


%  Additional output paremeters
%  rs  : reference set upon convergence

% convert N to length
N = N+1;

% Default parameters:

TBT = 'mid';           % TBT: Transition band type ('mid','passedge','stopedge')
FT  = 'low';           % FT : Filter type ('low','high')
PT  = 'lin';           % PT : Phase type ('lin','min')
PlotFig = 0;           % PlotFig : display frequency response (0,1)
PlotDB = 0;            % PlotDB : use DB for plotting units (0,1)
TRACE = 0;             % TRACE : display progress of algorithm  (0,1)
ROP = 0;               % ROP: Roll-Off Parameter
IS = 0;                % IS: Inverse-Sinc option

C = 0;
pow = 1;

% Read optional input arguments

if nargin > 3
    if ischar(ARG1) == 0
        ROP = ARG1;
    elseif strcmpi(ARG1,'passedge')
        TBT = 'passedge';
    elseif strcmpi(ARG1,'stopedge')
        TBT = 'stopedge';
    elseif strcmpi(ARG1,'high')
        FT = 'high';
    elseif strcmpi(ARG1,'slope')
        ROP = 10;
    elseif strcmpi(ARG1,'invsinc')
        IS = 1;
    elseif strcmpi(ARG1,'min')
        PT = 'min';
    elseif strcmpi(ARG1,'plot')
        PlotFig = 1;
    elseif strcmpi(ARG1,'plotDB')
        PlotFig = 1;
        PlotDB = 1;
    elseif strcmpi(ARG1,'trace')
        TRACE = 1;
    else
        error(['Unkown option: ',ARG1])
    end
end

if nargin > 4
    if ischar(ARG2) == 0
        if strcmpi(ARG1,'invsinc')
            C = ARG2(1);
            if length(ARG2) > 1
                pow = ARG2(2);
            end
        elseif strcmpi(ARG1,'slope')
            ROP = ARG2;
        end
    elseif strcmpi(ARG2,'passedge')
        TBT = 'passedge';
    elseif strcmpi(ARG2,'stopedge')
        TBT = 'stopedge';
    elseif strcmpi(ARG2,'high')
        FT = 'high';
    elseif strcmpi(ARG2,'slope')
        ROP = 10;
    elseif strcmpi(ARG2,'invsinc')
        IS = 1;
    elseif strcmpi(ARG2,'min')
        PT = 'min';
    elseif strcmpi(ARG2,'plot')
        PlotFig = 1;
    elseif strcmpi(ARG2,'plotDB')
        PlotFig = 1;
        PlotDB = 1;
    elseif strcmpi(ARG2,'trace')
        TRACE = 1;
    else
        error(['Unkown option: ',ARG2])
    end
end

if nargin > 5
    if ischar(ARG3) == 0
        if strcmpi(ARG2,'invsinc')
            C = ARG3(1);
            if length(ARG3) > 1
                pow = ARG3(2);
            end
        elseif strcmpi(ARG2,'slope')
            ROP = ARG3;
        end
    elseif strcmpi(ARG3,'passedge')
        TBT = 'passedge';
    elseif strcmpi(ARG3,'stopedge')
        TBT = 'stopedge';
    elseif strcmpi(ARG3,'high')
        FT = 'high';
    elseif strcmpi(ARG3,'slope')
        ROP = 10;
    elseif strcmpi(ARG3,'invsinc')
        IS = 1;
    elseif strcmpi(ARG3,'min')
        PT = 'min';
    elseif strcmpi(ARG3,'plot')
        PlotFig = 1;
    elseif strcmpi(ARG3,'plotDB')
        PlotFig = 1;
        PlotDB = 1;
    elseif strcmpi(ARG3,'trace')
        TRACE = 1;
    else
        error(['Unkown option: ',ARG3])
    end
end

if nargin > 6
    if ischar(ARG4) == 0
        if strcmpi(ARG3,'invsinc')
            C = ARG4(1);
            if length(ARG4) > 1
                pow = ARG4(2);
            end
        elseif strcmpi(ARG3,'slope')
            ROP = ARG4;
        end
    elseif strcmpi(ARG4,'passedge')
        TBT = 'passedge';
    elseif strcmpi(ARG4,'stopedge')
        TBT = 'stopedge';
    elseif strcmpi(ARG4,'high')
        FT = 'high';
    elseif strcmpi(ARG4,'slope')
        ROP = 10;
    elseif strcmpi(ARG4,'invsinc')
        IS = 1;
    elseif strcmpi(ARG4,'min')
        PT = 'min';
    elseif strcmpi(ARG4,'plot')
        PlotFig = 1;
    elseif strcmpi(ARG4,'plotDB')
        PlotFig = 1;
        PlotDB = 1;
    elseif strcmpi(ARG4,'trace')
        TRACE = 1;
    else
        error(['Unkown option: ',ARG4])
    end
end

if nargin > 7
    if ischar(ARG5) == 0
        if strcmpi(ARG4,'invsinc')
            C = ARG5(1);
            if length(ARG5) > 1
                pow = ARG5(2);
            end
        elseif strcmpi(ARG4,'slope')
            ROP = ARG5;
        end
    elseif strcmpi(ARG5,'passedge')
        TBT = 'passedge';
    elseif strcmpi(ARG5,'stopedge')
        TBT = 'stopedge';
    elseif strcmpi(ARG5,'high')
        FT = 'high';
    elseif strcmpi(ARG5,'slope')
        ROP = 10;
    elseif strcmpi(ARG5,'invsinc')
        IS = 1;
    elseif strcmpi(ARG5,'min')
        PT = 'min';
    elseif strcmpi(ARG5,'plot')
        PlotFig = 1;
    elseif strcmpi(ARG5,'plotDB')
        PlotFig = 1;
        PlotDB = 1;
    elseif strcmpi(ARG5,'trace')
        TRACE = 1;
    else
        error(['Unkown option: ',ARG5])
    end
end

if nargin > 8
    if ischar(ARG6) == 0
        if strcmpi(ARG5,'invsinc')
            C = ARG6(1);
            if length(ARG6) > 1
                pow = ARG6(2);
            end
        elseif strcmpi(ARG5,'slope')
            ROP = ARG6;
        end
    elseif strcmpi(ARG6,'passedge')
        TBT = 'passedge';
    elseif strcmpi(ARG6,'stopedge')
        TBT = 'stopedge';
    elseif strcmpi(ARG6,'high')
        FT = 'high';
    elseif strcmpi(ARG6,'slope')
        ROP = 10;
    elseif strcmpi(ARG6,'invsinc')
        IS = 1;
    elseif strcmpi(ARG6,'min')
        PT = 'min';
    elseif strcmpi(ARG6,'plot')
        PlotFig = 1;
    elseif strcmpi(ARG6,'plotDB')
        PlotFig = 1;
        PlotDB = 1;
    elseif strcmpi(ARG6,'trace')
        TRACE = 1;
    else
        error(['Unkown option: ',ARG6])
    end
end

if nargin > 9
    if ischar(ARG7) == 0
        if strcmpi(ARG6,'invsinc')
            C = ARG7(1);
            if length(ARG7) > 1
                pow = ARG7(2);
            end
        elseif strcmpi(ARG6,'slope')
            ROP = ARG7;
        end
    elseif strcmpi(ARG7,'passedge')
        TBT = 'passedge';
    elseif strcmpi(ARG7,'stopedge')
        TBT = 'stopedge';
    elseif strcmpi(ARG7,'high')
        FT = 'high';
    elseif strcmpi(ARG7,'slope')
        ROP = 10;
    elseif strcmpi(ARG7,'invsinc')
        IS = 1;
    elseif strcmpi(ARG7,'min')
        PT = 'min';
    elseif strcmpi(ARG7,'plot')
        PlotFig = 1;
    elseif strcmpi(ARG7,'plotDB')
        PlotFig = 1;
        PlotDB = 1;
    elseif strcmpi(ARG7,'trace')
        TRACE = 1;
    else
        error(['Unkown option: ',ARG7])
    end
end

if nargin > 10
    if ischar(ARG8) == 0
        if strcmpi(ARG7,'invsinc')
            C = ARG8(1);
            if length(ARG8) > 1
                pow = ARG8(2);
            end
        elseif strcmpi(ARG7,'slope')
            ROP = ARG8;
        end
    elseif strcmpi(ARG8,'passedge')
        TBT = 'passedge';
    elseif strcmpi(ARG8,'stopedge')
        TBT = 'stopedge';
    elseif strcmpi(ARG8,'high')
        FT = 'high';
    elseif strcmpi(ARG8,'slope')
        ROP = 10;
    elseif strcmpi(ARG8,'invsinc')
        IS = 1;
    elseif strcmpi(ARG8,'min')
        PT = 'min';
    elseif strcmpi(ARG8,'plot')
        PlotFig = 1;
    elseif strcmpi(ARG8,'plotDB')
        PlotFig = 1;
        PlotDB = 1;
    elseif strcmpi(ARG8,'trace')
        TRACE = 1;
    else
        error(['Unkown option: ',ARG8])
    end
end



% disp(TBT)
% disp(FT)
% disp(PT)
% disp(IS)
% disp(pow)
% disp(C)

% convert ROP units
if ROP < 0
    error('roll should be positive.');
end
if ROP > 0
    ROP = log(10)/20*ROP;
end

% convert highpass specifications to lowpass specifications if needed
if strcmpi(FT,'low')
elseif strcmpi(FT,'high')
    fo = 1 - fo;
    del = del([2 1]);
end

if strcmpi(PT,'min')
    % (Minimum phase)
    N = 2*N-1;           % design the autocorrelation of h.
end

if rem(N,2) == 1
    Type = 1;
    n = (N+1)/2;
else
    Type = 2;
    n = N/2;
end

% ------------------ initialize some constants --------------------------
L = 2^ceil(log2(15*n));            % grid size
SN = 1e-8;                         % Small Number (stopping criterion)
f  = (0:L)/L;                      % frequency axis
tw = exp(pi*(N-1)/2*j*f');         % (for plotting)
n1 = max([1,round((n-1)*fo)]);     % est number of ref. pts. in pass band
n2 = n-n1-1;                       % est number of ref. pts. in stop band
if Type == 1
    rs = [fo*(0:n1-1)/n1, fo, fo+(1-fo)*(1:n2)/n2]';
else
    rs = [fo*(0:n1-1)/n1, fo, fo+(n2)/(n2+1)*(1-fo)*(1:n2)/n2]';
end


if strcmpi(PT,'lin')
    % (Linear phase)
    up = [1 0]+del;       % upper bounds
    lo = [1 0]-del;       % lower bounds
    if IS == 0
        upper = up(1)*(f < fo) + up(2)*(f > fo).*exp(-ROP*(f-fo));
        lower = lo(1)*(f < fo) + lo(2)*(f > fo).*exp(-ROP*(f-fo));
    else
        % for inv-sinc option:
        % passband: f/sin(a*f)
        P = (f<fo).*isinc(C*f).^pow;
        upper = P+del(1)*(f < fo) + up(2)*(f > fo).*exp(-ROP*(f-fo));
        lower = P-del(1)*(f < fo) + lo(2)*(f > fo).*exp(-ROP*(f-fo));
    end
    % for axis size when plotting:
    uc = max(upper)-1;
    uc = ceil(uc*5)/5 + 1;
else
    % (Minimum phase)
    up = [1 0]+del;
    lo = [1-del(1) 0];
    if IS == 0
        upper = (1+del(1))*(f < fo) + del(2)*(f > fo).*exp(-ROP*(f-fo));
        lower = (1-del(1))*(f < fo);
    else
        % for inv-sinc option:
        % passband: invsin(f)
        P = (f<fo).*isinc(C*f).^pow;
        upper = P + del(1)*(f < fo) + del(2)*(f > fo).*exp(-ROP*(f-fo));
        lower = P - del(1)*(f < fo);
    end
    % for axis size when plotting:
    uc = max(upper)^2-1;
    uc = ceil(uc*5)/5 + 1;
    up = up.^2;
    lo = lo.^2;
    upper = upper.^2;
    lower = lower.^2;
    % del = (up - lo)/2;
    ROP = ROP*2;         % mofify ROP for autocorrelation.
    pow = 2*pow;
end

upper = upper';
lower = lower';


% Ho : prescribed value of |H(fo)| 
if strcmpi(TBT,'mid')
    if strcmpi(PT,'lin')
        Ho = 0.5;      % (linear-phase)
    else
        Ho = (0.5)^2;  % (minimum-phase)
    end 
elseif strcmpi(TBT,'passedge')
    if IS == 0
        Ho = lo(1);
    else
        Ho = isinc(C*fo)^pow - del(1);
        %      if strcmpi(PT,'lin')
        %         % linear-phase
        %         Ho = isinc(C*fo)^pow-del(1);
        %      else
        %         % minimum-phase
        %         Ho = (isinc(C*fo)^pow)-del(1);
        %      end
    end
elseif strcmpi(TBT,'stopedge')
    Ho = up(2);
else
    error('Problem (1)');
end



% begin looping
Err = 1;
itnum = 0;
WARN = 0;
MAXITER = 20;
while Err > SN
    
    % --------------- calculate interpolation values ---------------------
    Yp = up(1)*(1-(-1).^(1:n1))/2 + lo(1)*((-1).^(1:n1)+1)/2;
    Yp = Yp(n1:-1:1);
    if IS > 0
        % for inv-sinc option:
        if strcmpi(PT,'lin')
            Yp = Yp - 1 + (isinc(C*rs(1:n1))').^pow;
        else
            Yp = (1+del(1))*(1-(-1).^(1:n1))/2 + (1-del(1))*((-1).^(1:n1)+1)/2;
            Yp = Yp(n1:-1:1);
            Yp = Yp - 1 + (isinc(C*rs(1:n1))').^(pow/2);
            Yp = Yp.^2;
        end
    end
    Ys = lo(2)*(1-(-1).^(1:n2))/2 + up(2)*((-1).^(1:n2)+1)/2;
    Ys = Ys .* exp(-ROP*(rs(n1+2:end)-fo))';     % stopband roll-off
    Y  = [Yp, Ho, Ys];
    
    % --------------- calculate cosine coefficient -----------------------
    if Type == 1
        a = cos(pi*rs*(0:n-1))\Y';
    else
        a = cos(pi*rs*((0:n-1)+0.5))\Y';
    end
    
    % --------------- calculate impulse response   -----------------------
    if Type == 1
        h = [a(n:-1:2)/2; a(1); a(2:n)/2];           
    else
        h = [a(n:-1:1); a]/2;
    end
    
    % --------------- calculate real frequency response ------------------
    H = fft(h,2*L);         % zero pad and fft
    H = H(1:L+1);           % select [0,1]
    H = real(tw.*H);        % real frequency response
    
    % --------------- determine new reference set -------------------------
    % ri = sort([locmax(H); locmax(-H)]);   
    ri_up = locmax(H-upper);
    k = find(f(ri_up)>=fo);
    ri_up(k(1)) = [];              % remove frequency corresponding to discontin.
    ri_lo = locmax(lower-H);
    % [tmp,k] = min(abs((ri_lo-1)/L - fo));
    k = find(f(ri_lo)<=fo);
    ri_lo(k(end)) = [];            % remove frequency corresponding to discontin.
    ri = sort([ri_up; ri_lo]);
    if ri(end) == ri(end-1)
        ri(end) = [];
    end
    if ri(1) == ri(2)
        ri(1) = [];
    end
    lr = length(ri);
    if Type == 2
        ri = ri(1:lr-1);                             % REMOVE f=1
        lr = lr - 1;
    end
    while lr > n-1 %  new reference set too big
        if ((ri(lr)-1)/L < fo) && (Type == 2)
            % no reference points to the right of fo!
            x1 = 0; x2 = 1;
            % WARN = 1;
        else
            n1 = sum(ri/L<fo);
            n2 = sum(ri/L>fo);
            if rem(n1,2) == 0
                % n1 is even - consider ri(1) to be a local minimum
                x1 = lo(1) - H(ri(1));
            else
                % n1 is odd - consider ri(1) to be a local maximum
                x1 = H(ri(1)) - up(1);
            end
            if rem(n2,2) == 0
                % n2 is even - consider ri(lr) to be a local maximum
                x2 = H(ri(lr)) - up(2)*exp(-ROP*(f(ri(lr))-fo));
            else
                % n2 is odd - consider ri(lr) to be a local minimum
                x2 = lo(2)*exp(-ROP*(f(ri(lr))-fo)) - H(ri(lr));
            end
        end
        if x1 < x2
            ri(1) = [];
        else
            ri(lr) = [];
        end
        lr = lr - 1;
    end
    
    old_rs = rs;
    rs = (ri-1)/L;
    rsp = rs(rs<fo,1);              % passband ref. set freq.
    rss = rs(rs>fo,1);              % stopband ref. set freq.
    n1 = length(rsp);               % number of passband ref. set freq. 
    n2 = length(rss);               % number of stopband ref. set freq.
    
    % refine frequencies
    if IS == 0
        rsp = frefine(a,rsp,Type);
    else
        % inv-sinc option
        % do not refine...
    end
    if ROP == 0
        rss = frefine(a,rss,Type);
    else
        if strcmpi(PT,'min')
            rss(1:2:end) = frefine(a,rss(1:2:end),Type);
        end
        if 0
            C_up = up(2)*exp(ROP*fo)*ones(1,n2);
            C_lo = lo(2)*exp(ROP*fo)*ones(1,n2);
            C = C_lo;
            C(2:2:end) = C_up(2:2:end);
            if ri(end) == (L+1)
                % if f=1 is a reference point, then do not refine it.
                if length(rss) > 1
                    rss(1:end-1) = frefine_roll(a,rss(1:end-1),Type,C(1:end-1)',ROP);
                end
            else
                rss = frefine_roll(a,rss,Type,C',ROP);
            end
        end
    end
    
    rs = [rsp; fo; rss];            % new reference set
    
    % display figure if Trace is TRUE
    if TRACE == 1
        % plot(f,H,old_rs,Y,'o',(ri-1)/L,H(ri),'rx')
        % plot(f,H,old_rs,Y,'o');
        % plot(f,H,old_rs,Y,'o',f,upper,'--',f,lower,'--');
        plot(f,H,old_rs,Y,'o',f,upper,'--',f,lower,'--',(ri-1)/L,H(ri),'rx');
        axis([0 1 -.2 uc])
        drawnow
    end
    
    % ------------ calculate frequency response over reference set --------
    if Type == 1
        Hp = cos(pi*rsp*(0:n-1)) * a;
        Hs = cos(pi*rss*(0:n-1)) * a;
    else
        Hp = cos(pi*rsp*((0:n-1)+0.5)) * a;
        Hs = cos(pi*rss*((0:n-1)+0.5)) * a;
    end
    
    % --------------- calculate maximum constraint violation -------------
    if IS > 0
        % for inv-sinc option:
        if strcmpi(PT,'lin')
            Ep_up = max( Hp(end:-2:1) - (isinc(C*rsp(end:-2:1)).^pow) - del(1));
            Ep_lo = max(-Hp(end-1:-2:1) + (isinc(C*rsp(end-1:-2:1)).^pow - del(1)));
        else
            Ep_up = max(sqrt( Hp(end:-2:1)) - sqrt(isinc(C*rsp(end:-2:1)).^pow)) - del(1);
            Ep_lo = max(-sqrt(Hp(end:-2:1)) + sqrt(isinc(C*rsp(end:-2:1)).^pow)) - del(1);
        end
    else
        Ep_up = max(Hp)-up(1);
        Ep_lo = lo(1)-min(Hp);
    end
    Es_up = max( Hs(2:2:end) - up(2)*exp(-ROP*(rss(2:2:end)-fo)));
    Es_lo = max(-Hs(1:2:end) + lo(2)*exp(-ROP*(rss(1:2:end)-fo)));
    Err = max([Ep_up Ep_lo Es_up Es_lo]);
    if TRACE == 1
        fprintf(1,'    Err = %20.15f\n',Err);
    end
    itnum = itnum + 1;
    if itnum > MAXITER
        disp('Warning: Maximum number of iterations exceeded.');
        break
    end
end

if 0
    if Err < 0
        WARN = 1;
    elseif H(1) < lo(1)-0.3*del(1);
        WARN = 1;
    elseif H(1) > up(1)+0.3*del(1);
        WARN = 1;
    elseif H(L+1) < lo(2)-0.3*del(2);
        WARN = 1;
    elseif H(L+1) > up(2)+0.3*del(2);
        WARN = 1;
    elseif max(H) > max(up)+0.3*max(del);
        WARN = 1;
    elseif min(H) < min(lo)-0.3*max(del);
        WARN = 1;
    end
end

if WARN == 1
    disp('Warning: Impossible specifications.')
    disp('fo may be too close to either 0 or 1')
    disp('or roll may be too large.')
    h = [];
    return
end

h = h';

% convert lowpass back to highpass if needed
if strcmpi(FT,'high')
    fo = 1 - fo;
    up = up([2 1]);
%    lo = lo([2 1]); % variable not used
    h = h .* (-1).^(1:N);
    if Type == 1
        if max(h)+min(h) < 0
            h = -h;
        end
    end
end

if strcmpi(PT,'min')
    % perform spectral factorization if needed
    h = firminphase(h);   
    up = sqrt(up);
    %   lo = sqrt(lo); % variable not used
    % set ROP back to original value
    ROP = ROP/2;
    upper = sqrt(upper);
    lower = sqrt(lower);
    uc = max(upper)-1;
    uc = ceil(uc*5)/5 + 1;
end

% --------------- calculate real frequency response ------------------
H = fft(h',2*L);        % zero pad and fft
H = H(1:L+1);           % select [0,pi]
H = abs(H);             % frequency response magnitude


if PlotFig == 1
    ls = 'r--';  % Linestyle
    if strcmpi(FT,'high')
        fop = f(f>fo);
        fos = f(f<fo);
    else
        fop = f(f<fo);
        fos = f(f>fo);
    end
    if strcmpi(FT,'low')
        if PlotDB == 1
            c = 20*log10(up(2)*exp(-ROP*(1-fo)));
            c = -ceil(-c/10)*10-10;
            u2 = 20*log10(uc);
            u2 = 5*ceil(u2/5);
            plot(f,20*log10(abs(H)+eps), ...
                fop,20*log10(upper(f<fo)),ls, ...
                fop,20*log10(lower(f<fo)),ls, ...
                fo*[1 1],[c 20*log10(max(upper))],ls, ...
                [fo 1],20*log10(up(2)*exp(-ROP*([fo 1]-fo))),ls)
            axis([0 1 c u2])
            ylabel('|H(f)| dB')
        else
            plot(f,abs(H), ...
                fop,upper(f<fo),ls,...
                fop,lower(f<fo),ls,...
                fo*[1 1],[0 max(upper)],ls, ...
                fos,up(2)*exp(-ROP*(fos-fo)),ls)
            axis([0 1 0 uc])
            ylabel('|H(f)|')
        end
    end
    if strcmpi(FT,'high')
        if PlotDB == 1
            c = 20*log10(up(1)*exp(-ROP*(fo)));
            c = -ceil(-c/10)*10-10;
            u2 = 20*log10(uc);
            u2 = 5*ceil(u2/5);
            plot(f,20*log10(abs(H)+10*eps), ...
                fos,20*log10(up(1)*exp(-ROP*(fo-fos))),ls, ...
                fo*[1 1],[c 20*log10(max(upper))],ls, ...
                1-f(f<(1-fo)),20*log10(upper(f<(1-fo))),ls,...
                1-f(f<(1-fo)),20*log10(lower(f<(1-fo))),ls)
            axis([0 1 c u2])
            ylabel('|H(f)| dB')
        else
            plot(f,abs(H), ...
                fos,up(1)*exp(-ROP*(fo-fos)),ls, ...
                fo*[1 1],[0 max(upper)],ls, ...
                1-f(f<(1-fo)),upper(f<(1-fo)),ls,...
                1-f(f<(1-fo)),lower(f<(1-fo)),ls)
            axis([0 1 0 uc])
            ylabel('|H(f)|')
        end
    end
    xlabel('f')
    drawnow
end



% -------------------------------------------------------------------
%
%       SUBROUTINES
%
% -------------------------------------------------------------------


function rs = frefine(a,rs,TYPE)
% f = frefine(a,rs,TYPE);
% refine local minima and maxima of H using Newton's method
% H  : H = a(1)+a(2)*cos(w)+...+a(n+1)*cos(n*w)  [TYPE I]
% H  : H = a(1)*cos(0.5*w)+a(2)*cos(1.5w)+...+a(n+1)*cos((n-0.5)*w) [TYPE II]
% [w = pi*f]
% rs : initial values for the extrema of H in terms of f.

% Ivan Selesnick

a = a(:);
w = pi*rs(:);
m = length(a)-1;
if TYPE == 1
    v = 0:m;
else
    v = (0:m)+0.5;
end
for k = 1:7
    H = cos(w*v) * a;
    H1 = -sin(w*v) * (v'.*a);
    H2 = -cos(w*v) * ((v.^2)'.*a);
    w = w - H1./H2;
end
rs(:) = w;
rs = rs/pi;

% -------------------------------------------------------------------
function rs = frefine_roll(a,rs,TYPE,C,ROP)
% f = frefine_roll(a,rs,TYPE,C,ROP);
% refine local minima and maxima of H using Newton's method
% H  : H = a(1)+a(2)*cos(w)+...+a(n+1)*cos(n*w)  [TYPE I]
% H  : H = a(1)*cos(0.5*w)+a(2)*cos(1.5w)+...+a(n+1)*cos((n-0.5)*w) [TYPE II]
% [w = pi*f]
% rs : initial values for the extrema of H in terms of f.

% Ivan Selesnick

a = a(:);
w = pi*rs(:);
m = length(a)-1;
if TYPE == 1
    v = 0:m;
else
    v = (0:m)+0.5;
end
for k = 1:7
    H = cos(w*v) * a - C.*exp(-ROP*rs);
    H1 = -sin(w*v) * (v'.*a) + ROP*C.*exp(-ROP*rs);
    H2 = -cos(w*v) * ((v.^2)'.*a) - ROP^2*C.*exp(-ROP*rs);
    w = w - H1./H2;
end
rs(:) = w;
rs = rs/pi;

% --------------------------------------------------------------


%function f = firfbe(a,fi,Abe,TYPE) % function not used
% f = fir_fbe(a,fi,Abe,TYPE);
% find band edges of an FIR filter using Newton's method
% using initial estimates
%
% A   : a(1)+a(2)*cos(w)+...+a(n+1)*cos(n*w) [TYPE I]
% A   : a(1)*cos(0.5*pi)+a(2)*cos(1.5*w)+...+a(n+1)*cos((n-0.5)*w) [TYPE II]
% [w = pi*f]
% fi  : initial values for the band edges
% Abe : value of H at the band edges
%

% Ivan Selesnick

%a = a(:);
%m = length(a)-1;
%w = pi*fi(:);
%Abe = Abe(:);
%if TYPE == 1
%    v = 0:m;
%else
%    v = (0:m)+0.5;
%end
%for k = 1:15
%    A = cos(w*v) * a - Abe;
%    A1 = -sin(w*v) * (v'.*a);
%    w = w - A./A1;
%end
%f = w/pi;

% --------------------------------------------------------------


function k = locmax(x)
% k = locmax(x)
% finds location of local maxima
%
s = size(x);
x = x(:).';
N = length(x);
b1 = x(1:N-1)<=x(2:N);
b2 = x(1:N-1)>x(2:N);
k = find(b1(1:N-2) & b2(2:N-1))+1;
if x(1) > x(2)
    k = [k, 1];
end
if x(N) > x(N-1)
    k = [k, N];
end
k = sort(k);
if s(2) == 1
    k = k';
end


% --------------------------------------------------------------


function y = isinc(x)
% Inverse-sinc function

x = x*pi;
y = ones(size(x));
i = find(x & sin(x));
y(i) = (x(i))./sin(x(i));
