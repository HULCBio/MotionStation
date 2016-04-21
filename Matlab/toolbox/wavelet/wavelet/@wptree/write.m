function t = write(t,varargin)
%WRITE Write values in WPTREE object fields.
%   T = write(T,'cfs',NODE,COEFS) writes coefficients for the
%   terminal node NODE.
%
%   T = write(T,'cfs',N1,CFS1,'cfs',N2,CFS2, ...) writes coefficients
%   for the terminal nodes N1, N2, ...
%
%   Caution:
%     The cofficients values has to have the suitable sizes.
%     Use S = READ(T,'sizes',NODE) or S = READ(T,'sizes',[N1;N2; ... ])
%     to get those sizes.
%
%   Examples:
%     % Create a wavelet packets tree.
%     x = rand(1,512);
%     t = wpdec(x,3,'db3');
%     t = wpjoin(t,[4;5]);
%     plot(t);
%
%     % Write values.
%     sNod = read(t,'sizes',[4,5]);
%     cfs4  = zeros(sNod(1,:));
%     cfs5  = zeros(sNod(2,:));
%     t = write(t,'cfs',4,cfs4,'cfs',5,cfs5);
%
%   See also DISP, GET, READ, SET.

%   INTERNAL OPTIONS :
%----------------------
%   The valid choices for PropName are:
%     'ent', 'ento', 'sizes':
%        Without PropParam or with PropParam = Vector of nodes indices.
%
%     'cfs':  with PropParam = One node indices.
%       ,
%     'allcfs', 'entName', 'entPar', 'wavName': without PropParam.
%     
%     'wfilters':
%        without PropParam or with PropParam = 'd', 'r', 'l', 'h'.
%
%     'data' :
%        without PropParam or
%        with PropParam = One terminal node indices or
%             PropParam = Vector terminal node indices.
%        In the last case, the PropValue is a cell array.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:39:29 $

nbin = length(varargin);
k = 1;
while k<=nbin
    argNAME = lower(varargin{k});
    switch argNAME
        case {'ent','ento'}
            if isequal(argNAME,'ent') , col = 4; else , col = 5; end
            kplus = 0;
            if k<nbin-1
                 arg = varargin{k+2};
                 if ischar(arg) && ~strcmp(arg,'all')
                     arg = 'all';
                 else
                     kplus = 1;
                 end
            else
                 arg = 'all';
            end
            t = fmdtree('an_write',t,varargin{k+1},arg,col);
            k = k + kplus;

        case 'cfs'
            if k>=nbin-1
                errargt(mfilename,'invalid number of arguments ... ','msg');
                error('*');
            end
            t = write(t,'data',varargin{k+1:k+2});
            k = k+1;

        case 'allcfs'  , t = write(t,'data',varargin{k+1});
        case 'entname' , t.entInfo.entName = varargin{k+1};
        case 'entpar'  , t.entInfo.entPar  = varargin{k+1};
        case 'wavname'
            t.wavInfo.wavName = varargin{k+1};
            [t.wavInfo.Lo_D,t.wavInfo.Hi_D, ...
             t.wavInfo.Lo_R,t.wavInfo.Hi_R] = wfilters(varargin{k+1});

        case 'data',
            if k<nbin-1 && isnumeric(varargin{k+2})
                t.dtree = write(t.dtree,'data',varargin{k+1:k+2});
                k = k+1;
            else
                t.dtree = write(t.dtree,'data',varargin{k+1});
            end

        otherwise
            error('Unknow argNAME ...');
    end
    k = k+2;
end