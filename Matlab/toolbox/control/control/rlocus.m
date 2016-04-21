function [rout,kout] = rlocus(a,b,c,d,k)
%RLOCUS  Evans root locus.
%
%   RLOCUS(SYS) computes and plots the root locus of the single-input,
%   single-output LTI model SYS.  The root locus plot is used to 
%   analyze the negative feedback loop
%
%                     +-----+
%         ---->O----->| SYS |----+---->
%             -|      +-----+    |
%              |                 |
%              |       +---+     |
%              +-------| K |<----+
%                      +---+
%
%   and shows the trajectories of the closed-loop poles when the feedback 
%   gain K varies from 0 to Inf.  RLOCUS automatically generates a set of 
%   positive gain values that produce a smooth plot.  
%
%   RLOCUS(SYS,K) uses a user-specified vector K of gain values.
%
%   RLOCUS(SYS1,SYS2,...) draws the root loci of multiple LTI models  
%   SYS1, SYS2,... on a single plot.  You can specify a color, line style, 
%   and marker for each model, as in  
%      rlocus(sys1,'r',sys2,'y:',sys3,'gx').
%
%   [R,K] = RLOCUS(SYS) or R = RLOCUS(SYS,K) returns the matrix R of
%   complex root locations for the gains K.  R has LENGTH(K) columns
%   and its j-th column lists the closed-loop roots for the gain K(j).  
%
%   See also SISOTOOL, POLE, ISSISO, LTIMODELS.

% Old help
%RLOCUS Evans root locus.
%   RLOCUS(NUM,DEN) calculates and plots the locus of the roots of:
%                              
%               H(s) = DEN(s) + k*NUM(s) =  0
%
%   for a set of gains K which are adaptively calculated to produce a 
%   smooth plot. Alternatively the vector K can be specified with an 
%   optional right-hand argument RLOCUS(NUM,DEN,K). Vectors NUM and 
%   DEN must contain the numerator and denominator coefficients in 
%   descending powers of s or z. When invoked with left hand arguments
%       R = RLOCUS(NUM,DEN,K)  or  [R,K] = RLOCUS(NUM,DEN)
%   returns the matrix R with LENGTH(K) rows and LENGTH(DEN)-1
%   columns containing the complex root locations.  Each row of the 
%   matrix corresponds to a gain from vector K.  If a second left hand
%   argument is included, the gains are returned in K.
% 
%   RLOCUS(A,B,C,D), R = RLOCUS(A,B,C,D,K), or [R,K] = RLOCUS(A,B,C,D)
%   finds the root-locus from the equivalent SISO state-space system
%   (A,B,C,D).
%                    dx/dt = Ax + Bu    u = -k*y
%                        y = Cx + Du
%
%   See also: PZMAP and RLOCTOOL.

%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 7-8-89, 6-21-92 
%   Revised A.Potvin 6-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 06:25:27 $

ni = nargin;
no = nargout;

if ni==0,
    if no~=0,  error('Missing input argument(s).'),  end
    eval('exresp(''rlocus'');')
    return
end
error(nargchk(2,5,ni));

if ni<4,
    % Transfer function
    if ni==3, 
        k = c;
    else
        k = [];
    end
    
    [num,den] = tfchk(a,b);
    p = size(num,1);
    if p>1,
        disp('Must call rlocus with a SISO system.  e.g. rlocus(num(i,:),den)')
        return
    end
    sys = tf(num,den);
    
else
    % State space
    [msg,a,b,c,d] = abcdchk(a,b,c,d); error(msg);
    
    if ni==4,
        k = [];
    end
    [p,m] = size(d);
    if p*m>1,
        disp('Must call rlocus with a SISO system.  e.g. rlocus(a,b(:,i),c(j,:),d(i,j))')
        return
    end
    sys = ss(a,b,c,d);
    
end


if no,
    [rout,kout] = rlocus(sys,k);
    % Make output consistent with old syntax
    rout = rout.';    % length(k) x length(Poles)
else
    % Infer domain from grid so that  
    %      zgrid('new'),rlocus(num,den)  
    % continues to work
    gridlines = findall(gca,'Type','line','Tag','CSTgridLines');
    for ct=1:length(gridlines)
        % Determine if it is an S grid or Z grid
        xdata = get(gridlines(ct),'Xdata');
        if any(xdata>0.1)
            sys.Ts = -1;  % Z grid --> make system discrete
            break
        end
    end
    % Plot locus
    rlocus(sys,k)
end
