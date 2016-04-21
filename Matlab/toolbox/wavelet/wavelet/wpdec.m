function varargout = wpdec(x,depth,wname,type_ent,parameter)
%WPDEC Wavelet packet decomposition 1-D.
%   T = WPDEC(X,N,'wname',E,P) returns a wptree object T
%   corresponding to a wavelet packet decomposition
%   of the vector X, at level N, with a
%   particular wavelet ('wname', see WFILTERS).
%   E is a string containing the type of entropy (see WENTROPY):
%   E = 'shannon', 'threshold', 'norm', 'log energy', 'sure', 'user'
%   P is an optional parameter:
%        'shannon' or 'log energy' : P is not used
%        'threshold' or 'sure'     : P is the threshold (0 <= P)
%        'norm' : P is a power (1 <= P)
%        'user' : P is a string containing the name
%                 of an user-defined function.
%
%   T = WPDEC(X,N,'wname') is equivalent to
%   T = WPDEC(X,N,'wname','shannon').
%
%   See also WAVEINFO, WENTROPY, WPDEC2, WPREC, WPREC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

%--------------%
% OLD VERSION  %
%--------------%
%   [T,D] = WPDEC(X,N,'wname',E,P) returns a tree structure T
%   and a data structure D (see MAKETREE), corresponding to a
%   wavelet packet decomposition of the vector X, at level N,
%   with a particular wavelet ('wname', see WFILTERS).
%   E is a string containing the type of entropy (see WENTROPY):
%   E = 'shannon', 'threshold', 'norm', 'log energy', 'sure, 'user'
%   P is an optional parameter:
%        'shannon' or 'log energy' : P is not used
%        'threshold' or 'sure'     : P is the threshold (0 <= P)
%        'norm' : P is a power (1 <= P < 2)
%        'user' : P is a string containing the name
%                 of an user-defined function.
%
%   [T,D] = WPDEC(X,N,'wname') is equivalent to
%   [T,D] = WPDEC(X,N,'wname','shannon').
%
%   See also MAKETREE, WAVEINFO, WDATAMGR, WENTROPY
%            WPDEC2, WTREEMGR.

% Check arguments.
nbIn = nargin;
if nbIn < 3 ,    error('Not enough input arguments.');
elseif nbIn==3 , parameter = 0.0; type_ent = 'shannon';
elseif nbIn==4 , parameter = 0.0;
end
if strcmp(lower(type_ent),'user')
    if ~ischar(parameter)
        error('*** Invalid function name for user entropy ***');
    end
end

% Tree Computation
if nargout==1    % NEW VERSION
    order = 2;
    varargout{1} = wptree(order,depth,x,wname,type_ent,parameter);

else	         % OLD VERSION
	verWTBX = wtbxmngr('version','nodisp');
	if ~isequal(verWTBX,'V1')
		WarnString = strvcat(...
					'Warning: The number of output arguments for the wpdec', ...
			        'function has changed and this calling syntax is obsolete.',  ...
					'Please type "help wtbxmngr" at the MATLAB prompt', ...
					'for more information.' ...
					);
		DlgName = 'Warning Dialog';
		wwarndlg(WarnString,DlgName,'bloc');
		varargout = cell(1,nargout); 
		return
	end
    [varargout{1},varargout{2}] = owpdec(x,depth,wname,type_ent,parameter);
end


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function [Ts,Ds] = owpdec(x,depth,wname,type_ent,parameter)
%WPDEC Wavelet packet decomposition 1-D.

[mi,ind] = min(size(x));
if (ind==1) & (mi<2)
    x_shape = 'r';
elseif (ind==2) & (mi<2)
    x_shape = 'c';
else
    error('Invalid argument value.');
end

% Initialization
%%%%%%%%%%%%%%%%
order       = 2;
[Ts,nbtn]   = maketree(order,depth,order/2);
sizes       = zeros(1,depth+1);
Ds          = x(:)';
ent         = zeros(1,(order*nbtn-1)/(order-1));
tmp         = NaN;
ent_opt     = tmp(ones(size(ent)));

lx          = length(x);
sizes(1)    = lx;
ent(1)      = wentropy(x,type_ent,parameter);

% Tree computation
%%%%%%%%%%%%%%%%%%
[Lo_D,Hi_D] = wfilters(wname,'d');
n = 2;
for k=0:depth-1
    beg = 1;
    for p=0:order^k-1
        x        = Ds(beg:beg+lx-1);
        [a,d]    = dwt(x,Lo_D,Hi_D);
        Ds       = [Ds(1:beg-1) a d Ds(beg+lx:end)];
        ent(n)   = wentropy(a,type_ent,parameter);
        ent(n+1) = wentropy(d,type_ent,parameter);
        beg      = beg+2*length(a);
        n        = n+order;
    end
    lx         = length(a);
    sizes(k+2) = lx;
end
Ts = wtreemgr('winfo',Ts,lx*ones(1,nbtn));

% Writing wavelet and entropy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ds = wdatamgr('write',Ds,sizes,x_shape,...
                ent,ent_opt,parameter,type_ent,wname,order);
%-----------------------------------------------------------------------------%
%=============================================================================%
