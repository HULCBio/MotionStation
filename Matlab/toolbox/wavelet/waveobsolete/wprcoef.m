function x = wprcoef(Ts,Ds,node)
%WPRCOEF Reconstruct wavelet packet coefficients.
%   X = WPRCOEF(T,D,N) computes reconstructed coefficients
%   of the node N. T is the tree structure and D
%   the data structure (see MAKETREE).
%
%   X = WPRCOEF(T,D) is equivalent to X = WPRCOEF(T,D,0).
%
%   See also WPDEC, WPDEC2, WPREC, WPREC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.13.4.2 $

% Check arguments.
if errargn(mfilename,nargin,[2 3],nargout,[0:1]), error('*'); end
if nargin==2, node = 0; end
if find(isnode(Ts,node)==0)
    errargt(mfilename,'invalid node value','msg'); error('*');
end

% Get DWT_Mode
dwtATTR = dwtmode('get');


order = treeord(Ts);
asc   = nodeasc(Ts,node,'depo');
asc   = rem(asc(:,2),order);
nb_up = size(asc,1)-1;

x      = wpcoef(Ts,Ds,node);
filter = wdatamgr('read_wave',Ds);
[Lo_R,Hi_R] = wfilters(filter,'r');
sizes  = wdatamgr('rsizes',Ds);

lf = length(Lo_R);
f  = zeros(nb_up,lf);
switch order
    case 2
        dwtEXTM  = dwtATTR.extMode;
        dwtSHIFT = dwtATTR.shift1D;
        K      = find(asc==0);
        f(K,:) = Lo_R(ones(size(K)),:);
        K      = find(asc==1);
        f(K,:) = Hi_R(ones(size(K)),:);
        for k=1:nb_up
            s = sizes(nb_up-k+1);
            x = upsconv1(x,f(k,:),s,dwtEXTM,dwtSHIFT);
        end

    case 4
        g = f;
        K = find(asc==0);
        f(K,:) = Lo_R(ones(size(K)),:);
        g(K,:) = Lo_R(ones(size(K)),:);
        K = find(asc==1);
        f(K,:) = Hi_R(ones(size(K)),:);
        g(K,:) = Lo_R(ones(size(K)),:);
        K = find(asc==2);
        f(K,:) = Lo_R(ones(size(K)),:);
        g(K,:) = Hi_R(ones(size(K)),:);
        K = find(asc==3);
        f(K,:) = Hi_R(ones(size(K)),:);
        g(K,:) = Hi_R(ones(size(K)),:);
        for k=1:nb_up
            s = sizes(:,nb_up-k+1)';
            x = upsconv2(x,{f(k,:),g(k,:)},s,dwtATTR);
        end
end