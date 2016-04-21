function importdata(LoopData,P,H,F,C)
%IMPORTDATA  Imports plant and compensator model data.
%
%   The plant P, sensor H, prefilter F, and compensator C are 
%   specified as structures with fields Name (model name) and
%   Model (model data). To skip a particular component, set its
%   value to [].
% 
%   Note: This function assumes that the data 

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.24 $  $Date: 2002/04/10 04:54:12 $

% Check that data is valid (may throw an error)
[P,H,F,C] = checkdata(LoopData,P,H,F,C);

% Notify peers of first import
if isempty(LoopData.Plant.Model)
    LoopData.send('FirstImport')
end

% Import data (error free)
LocalImportFixedModel(LoopData.Plant,P);
LocalImportFixedModel(LoopData.Sensor,H);
LocalImportTunedModel(LoopData.Filter,F);
LocalImportTunedModel(LoopData.Compensator,C);
   
% Update loop sample time
LoopData.Ts = get(C.Model,'Ts');

%----------------- Local functions -----------------


%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalImportFixedModel %
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalImportFixedModel(ModelData,ImportData)
% Formats model data for plant and sensor

if isempty(ImportData)
    return
end

ModelData.Name = ImportData.Name;
ModelData.Model = ImportData.Model;

[z,p,k] = zpkdata(ImportData.Model,'v');
ModelData.Zero = z;
ModelData.Pole = p;
ModelData.Gain = k;
ModelData.StateSpace = [];

%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalImportTunedModel %
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalImportTunedModel(CompData,ImportComp)
% Formats compensator data (feedforward or feedback)

% RE: Two compensator representations are used
%                                 prod(s-zi)
%  1) C(s) = sign_r * K_r * s^m * ----------  when FORMAT = 'ZeroPoleGain'
%                                 prod(s-pj)
%
%                                 prod(1-s/zi)
%  2) C(s) = sign_b * K_b * s^m * ------------  when FORMAT = 'TimeConstant'
%                                 prod(1-s/pj)
%
%                                         prod(1-(z-1)/(zi-1))
%     (or C(z) = sign_b * K_b * (z-1)^m * --------------------
%                                         prod(1-(z-1)/(pi-1))
%
%  The fields GainSign and GainMag store sign_* and K_*

% ZPK data
[z,p,k,Ts] = zpkdata(ImportComp.Model,'v');

% Detect notch components
[z,p,zn,pn] = LocalFindNotch(z,p,Ts);

% Real poles and zeros
pr = p(~imag(p),:);
zr = z(~imag(z),:);

% Complex poles and zeros
pc = p(imag(p)>0,:);
zc = z(imag(z)>0,:);

% Adjust length of PZ group list (reuse existing groups)
Nc = length(CompData.PZGroup);
Nf = length(pr)+length(zr)+length(pc)+length(zc)+size(zn,2);
% Delete extra groups
if Nc>Nf,
    delete(CompData.PZGroup(Nf+1:Nc));
    CompData.PZGroup = CompData.PZGroup(1:Nf,:);
end
% Add new groups
for ct=1:Nf-Nc,
    CompData.PZGroup = [CompData.PZGroup ; sisodata.pzgroup];
end

% Update PZ groups
N = 0;
for ct=1:length(zr)
    set(CompData.PZGroup(N+ct),'Type','Real','Zero',zr(ct),'Pole',zeros(0,1));
end
N = N + length(zr);
for ct=1:length(pr)
    set(CompData.PZGroup(N+ct),'Type','Real','Zero',zeros(0,1),'Pole',pr(ct));
end
N = N + length(pr);
for ct=1:length(zc)
    set(CompData.PZGroup(N+ct),'Type','Complex',...
        'Zero',[zc(ct);conj(zc(ct))],'Pole',zeros(0,1));
end
N = N + length(zc);
for ct=1:length(pc)
    set(CompData.PZGroup(N+ct),'Type','Complex',...
        'Zero',zeros(0,1),'Pole',[pc(ct);conj(pc(ct))]);
end
N = N + length(pc);
for ct=1:size(zn,2)
    set(CompData.PZGroup(N+ct),'Type','Notch',...
        'Zero',zn(:,ct),'Pole',pn(:,ct));
end

% Compensator data
CompData.Name = ImportComp.Name;
CompData.Ts = Ts;
k = k/formatfactor(CompData);
CompData.Gain = struct('Sign',sign(k)+(~k),'Magnitude',abs(k));


%%%%%%%%%%%%%%%%%%
% LocalFindNotch %
%%%%%%%%%%%%%%%%%%
function [z,p,zn,pn] = LocalFindNotch(z,p,Ts)
% Detects notch filters in imported compensator
NearTol = sqrt(eps);
nz = length(z);
np = length(p);

% Get natural freq. and damping
[wz,zetaz] = damp(z,Ts);
[wp,zetap] = damp(p,Ts);

% Sort Wn
zeta = [zetaz;zetap];
idx = [1:nz,nz+1:nz+np]';
[wn,is] = sort([wz;wp]);
idx = idx(is,:);
zeta = zeta(is,:);

% Find isolated groups of four roots with same wn
nr = nz+np;
delta = [(abs(wn(2:nr,:)-wn(1:nr-1,:))<NearTol*wn(1:nr-1,:));0];
isNotchSeed = ...
    [delta(1:nr-3,:) & delta(2:nr-2,:) & delta(3:nr-1,:) & ~delta(4:nr,:) ; zeros(3,1)];

% Such groups with two poles and two zeros qualify as notches
isZero = (idx<=nz);
isPole = (idx>nz);
isPZPair = (filter([1 1 1 1],[1 0 0 0],isZero)==2 & ...
    filter([1 1 1 1],[1 0 0 0],isPole)==2);
isNotchSeed = isNotchSeed & [isPZPair(4:nr,:);zeros(3,1)];

% Check compatibility of damping (|zetaz|<|zetap|)
for k=find(isNotchSeed)',
    zetaz = zeta(k-1+find(isZero(k:k+3)));
    zetap = zeta(k-1+find(isPole(k:k+3)));
    isNotchSeed(k) = (abs(zetaz(1))<=abs(zetap(1)));
end

% Extract notches
idxn = find(isNotchSeed);
zn = zeros(2,length(idxn));
pn = zeros(2,length(idxn));
for ct=1:length(idxn),
    % Position of notch poles and zeros in Z and P
    k = idxn(ct);
    idxz = idx(k-1+find(isZero(k:k+3)));
    idxp = idx(k-1+find(isPole(k:k+3)))-nz;
    % Extract notch
    zk = z(idxz(1));
    pk = p(idxp(1));
    zn(:,ct) = real(zk) + [1i;-1i] * abs(imag(zk));
    pn(:,ct) = real(pk) + [1i;-1i] * abs(imag(pk));
end

% Delete notch roots from Z and P
isNotch = zeros(nr,1);
isNotch([idxn;idxn+1;idxn+2;idxn+3],:) = 1;
z(idx(isZero & isNotch),:) = [];
p(idx(isPole & isNotch)-nz,:) = [];
    
