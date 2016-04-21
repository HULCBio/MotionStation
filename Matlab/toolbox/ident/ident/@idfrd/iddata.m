function d = iddata(f,nexp,noinf);
%IDFRD/IDDATA Converts an IDFRD object to IDDATA
%
%   DATA = IDDATA(G)
%
%   G is an IDFRD object
%   DATA is an IDDATA, Frequency Domain, object.
%
%   DATA = IDDATA(G,'ME')
%   returns DATA as a multiexperiment data object where
%   each experiments correspond to each input in G.
%
%   By default frequencies are removed, where the response is 
%   infinite. To keep these, use DATA = IDDATA(G,'inf')
%   (or DATA = IDDATA(G,'me','inf'))
%
%   See also IDDATA/IDDATA and IDPROPS IDDATA

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/10 23:16:46 $

if nargin<3
    noinf = 1;
end
if nargin < 2
    me = 0;
end
if nargin == 3
    noinf = 0;
    me = 1;
elseif nargin == 2
    if lower(nexp(1))=='m'
        noinf = 1; me = 1;
    else
        noinf = 0; me = 0;
    end
end
% first just spectrumdata
if size(f,'nu')==0
    Y = f.SpectrumData;
    [ny,dum,Ncap] = size(Y);
    Yd=zeros(Ncap,ny);
    for ky=1:ny
        Yd(:,ky)=squeeze(Y(ky,ky,:));
    end
    d = iddata(Yd,[],f.Ts,'domain','freq','frequency',f.Frequency,...
        'OutputName',f.OutputName,'OutputUnit',f.OutputUnit,'Name',f.Name);
    return
end

resp = f.ResponseData;
[p,m,N] = size(resp);
if ~me
    if p*m~=1,
        Y = zeros(N*m,p);
        U = zeros(N*m,m);
        for k =1:m,
            if p~=1, % Problem with squeeze when p==1
                Y((k-1)*N+1:k*N,:) = squeeze(resp(:,k,:)).';
            else
                Y((k-1)*N+1:k*N,:) = squeeze(resp(:,k,:));    
            end
            U((k-1)*N+1:k*N,k) = ones(N,1);
        end
        freq = kron(ones(m,1),pvget(f, 'Frequency'));
    else
        freq = pvget(f, 'Frequency');
        Y = resp(:);
        U = ones(length(freq),1);
    end
else %multiexperiment
    for ku = 1:m
        % Y{ku} = zeros(N,p);
        U{ku} = zeros(N,m);
        
        if p~=1, % Problem with squeeze when p==1
            Y{ku} = squeeze(resp(:,ku,:)).';
        else
            Y{ku} = squeeze(resp(:,ku,:));    
        end
        U{ku}(:,ku) = ones(N,1);
        
        freq{ku} = pvget(f, 'Frequency');
        una = pvget(f,'InputName');
        exp{ku} = ['From input ',una{ku}];
    end
end
 
d = iddata(Y,U,'Domain','Frequency','Frequency',freq); 
if me
    d = pvset(d,'ExperimentName',exp);
end
was = warning;
warning off
d = pvset(d,'Tstart',get(f,'unit'));
warning(was)
Ts = pvget(f,'Ts');
if Ts==0, %CT-models 
    Ts = 0; % Data has an unspecified sampling time
    for k=1:m,
        is{k} = 'bl';
    end
    d = pvset(d,'InterSample',is');
end
d= pvset(d,'Ts',Ts,...
    'InputName',pvget(f,'InputName'),...
    'OutputName',pvget(f,'OutputName'),...
    'InputUnit',pvget(f,'InputUnit'),...
    'OutputUnit',pvget(f,'OutputUnit'),'Name',f.Name);
ut = pvget(d,'Utility');
ut.idfrd = 1;
d = uset(d,ut);
if noinf
    d = reminf(d);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = reminf(d)
% Removes entries thatg correspond to infinite y-values in IDDATA d
y=pvget(d,'OutputData');
u = pvget(d,'InputData');
fre = pvget(d,'SamplingInstants');
if any(any(isinf(cat(1,y{:}))))|any(any(isnan(cat(1,y{:}))))
for kexp = 1:length(y)
    ys = y{kexp}; us = u{kexp};fres=fre{kexp};
    if size(ys,2)==1
        infnr = find(isinf(ys)|isnan(ys));
    else
    infnr = find(any(isinf(ys)')|any(isnan(ys)'));
end
    ys(infnr,:)=[];
    us(infnr,:)=[];
    fres(infnr)=[];
    yn{kexp} = ys;
    un{kexp} = us;
    fren{kexp} = fres;
end
d = pvset(d,'SamplingInstants',fren,'OutputData',yn,'InputData',un);
warning('IDENT:Message','Frequencies with inifinite response have been removed.')
end