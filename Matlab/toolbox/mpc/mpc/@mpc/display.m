function display(MPCobj)
%DISPLAY Displays an MPC object.

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $  $Date: 2004/04/10 23:35:02 $   


if isempty(MPCobj),
    disp('Empty MPC object');
    return
end

time=fix(MPCobj.History);
n=datenum(time(1),time(2),time(3),time(4),time(5),time(6));
disp(' ')
disp(['MPC object (created on ' datestr(n,0) '):'])
disp('---------------------------------------------')

p=get(MPCobj,'PredictionHorizon');
m=get(MPCobj,'ControlHorizon');
disp(sprintf('Sampling time:      %s',num2str(MPCobj.Ts)));
disp(sprintf('Prediction Horizon: %d',p));
disp(sprintf('Control Horizon:    %s\n',num2str(m)));

disp('Model:')
disp(MPCobj.Model)

data=MPCobj.MPCData;

fprintf('        Output disturbance model: ');
if data.OutDistFlag,
    fprintf('user specified (type "getoutdist(%s)" for details)\n',inputname(1));
else
    fprintf('default method (type "getoutdist(%s)" for details)\n',inputname(1));
end
if ~isempty(data.unindex),
    fprintf('        Input disturbance model:  ');
    if ~isempty(MPCobj.Model.Disturbance),
        fprintf('specified in %s.Model.Disturbance\n',inputname(1));
        fprintf('                                  (type "getindist(%s)" for more details)\n\n',inputname(1));
    else
        fprintf('default method (type "getindist(%s)" for details)\n\n',inputname(1));
    end
else
    fprintf('\n');
end
fprintf('Details on Plant model: ');
if hasdelay(MPCobj.Model.Plant),
    totdelay=totaldelay(MPCobj.Model.Plant);
    if prod(size(totdelay))==1,
        fprintf('(I/O delay = %g)',totdelay);
    else
        maxdelay=max(max(totdelay));
        fprintf('(max I/O delay = %g)',maxdelay);
    end
end
fprintf('\n');
if isa(MPCobj.Model.Plant,'ss'),
    string1=sprintf('%2d states',size(MPCobj.Model.Plant.A,1));
else
    string1=class(MPCobj.Model.Plant);
end
nym=length(data.myindex);
fprintf('                                    --------------\n');
fprintf('    %3d  manipulated variables   -->|%10s  |\n',data.nu,string1);
fprintf('                                    |            |-->%3d measured outputs\n',nym);
fprintf('    %3d  measured disturbances   -->|%3d inputs  |\n',length(data.mdindex),data.nutot);
fprintf('                                    |            |-->%3d unmeasured outputs\n',data.ny-nym);
fprintf('    %3d  unmeasured disturbances -->|%3d outputs |\n',length(data.unindex),data.ny);
fprintf('                                    --------------\n');   


mdindex=data.mdindex;
unindex=data.unindex;
myindex=data.myindex;
uyindex=setdiff([1:data.ny]',myindex(:));

if ~isempty(mdindex) | ~isempty(unindex) | ~isempty(uyindex),
    fprintf('\nIndices:\n');
    fprintf('  (input vector)    Manipulated variables: [');
    fprintf('%d ',data.mvindex);
    fprintf(']\n');
    if ~isempty(mdindex),
        fprintf('                    Measured disturbances: [');
        fprintf('%d ',mdindex);
        fprintf(']\n');
    end
    if ~isempty(unindex),
        fprintf('                  Unmeasured disturbances: [');
        fprintf('%d ',unindex);
        fprintf(']\n');
    end
    fprintf('  (output vector)        Measured outputs: [');
    fprintf('%d ',myindex);
    fprintf(']\n');
    if ~isempty(uyindex),
        fprintf('                       Unmeasured outputs: [');
        fprintf('%d ',uyindex);
        fprintf(']\n');
    end
    fprintf('\n');
end

aux='Weights:';
if data.WeightsDefault,
    disp([aux ' (default)']);
else
    disp(aux)
end
disp(MPCobj.Weights)

nu=data.nu;
uoff=zeros(nu,1);
try
    [umin,umax,Vumin,Vumax,dumin,dumax,Vdumin,Vdumax,utarget]=...
        mpc_constraints(MPCobj.ManipulatedVariables,p,nu,'u',uoff);
catch
    rethrow(lasterror);
end

ny=data.ny;
yoff=zeros(ny,1);
try
    [ymin,ymax,Vymin,Vymax]=mpc_constraints(MPCobj.OutputVariables,...
        p,ny,'y',yoff);
catch
    rethrow(lasterror);
end

constrained=any(isfinite(umin(:))) | any(isfinite(umax(:))) | ...
    any(isfinite(dumin(:))) | any(isfinite(dumax(:))) | ...
    any(isfinite(ymin(:))) | any(isfinite(ymax(:)));

if ~constrained,
   disp('Unconstrained');
else
   disp('Constraints:')
   
   mvindex=data.mvindex;
   urows=0;
   durows=0;
   unames={};
   dunames={};
   for h=1:nu,
      aux1=size(MPCobj.ManipulatedVariables(h).Max,1);
      aux2=size(MPCobj.ManipulatedVariables(h).Min,1);
      if aux1>urows | aux2>urows,
         urows=max(aux1,aux2);
      end
      aux1=size(MPCobj.ManipulatedVariables(h).RateMax,1);
      aux2=size(MPCobj.ManipulatedVariables(h).RateMin,1);
      if aux1>durows | aux2>durows,
         durows=max(aux1,aux2);
      end
      aux=MPCobj.ManipulatedVariables(h).Name;
      if isempty(aux),
         aux=sprintf('Input #%d',mvindex(h));
      end
      aux2=MPCobj.ManipulatedVariables(h).Units;
      if ~isempty(aux2),
         aux2=[' (' aux2 ')'];
      end
      unames{h}=[aux aux2];
      dunames{h}=[aux '/rate' aux2];
   end
   yrows=0;
   ynames={};
   for h=1:ny,
      aux1=size(MPCobj.OutputVariables(h).Max,1);
      aux2=size(MPCobj.OutputVariables(h).Min,1);
      if aux1>yrows | aux2>yrows,
         yrows=max(aux1,aux2);
      end
      aux=MPCobj.OutputVariables(h).Name;
      if isempty(aux),
         aux=sprintf('Output #%d',h);
      end
      aux2=MPCobj.OutputVariables(h).Units;
      if ~isempty(aux2),
         aux2=[' (' aux2 ')'];
      end
      ynames{h}=[aux aux2];
   end
   
   
   [ulims,uspace]=smartdisp(unames,umax(1:urows,:),umin(1:urows,:));
   [dulims,duspace]=smartdisp(dunames,dumax(1:durows,:),dumin(1:durows,:));
   [ylims,yspace]=smartdisp(ynames,ymax(1:yrows,:),ymin(1:yrows,:));
   
   
   nn=max([length(ulims),length(dulims),length(ylims)]);
   for i=1:nn,
      if i<=length(ulims),
         aux=ulims{i};
         strng=sprintf(uspace,aux);
         if all(aux==' ') | all(aux=='.') | i>length(dulims),
            strng=[strng ' '];
         else
            strng=[strng ','];
         end
      else
         strng=[sprintf(uspace,'') ' ']; 
      end
      
      if i<=length(dulims),
         aux=dulims{i};
         strng=[strng sprintf(duspace,aux)];
         if all(aux==' ') | all(aux=='.') | i>length(ylims),
            strng=[strng ' '];
         else
            strng=[strng ','];
         end
      else
         strng=[strng sprintf(duspace,'') ' ']; 
      end
      if i<=length(ylims),
         strng=[strng sprintf(yspace,ylims{i})];
      else
         strng=[strng sprintf(yspace,'')];
      end
      disp(strng)   
   end        
end

notes=MPCobj.Notes;
if ~isempty(notes),
   disp(sprintf('\nNotes:\n'));
   notes=notes(:);
   for i=1:length(notes),
      disp(notes{i});
   end
end

% verbose=warning('query','mpc:verbosity');
% verbose=verbose.state;
% if strcmp(verbose,'on'),
%     disp(sprintf('\nType "mpcverbosity off" to suppress output on screen during MPC object manipulation'));
% end


%dispprop(MPCobj.Model.Plant,1)


% end DISPLAY.M

function [alims,aspace]=smartdisp(names,amax,amin)
% Displays constraints on the prediction horizon

rmax=4; % Max number of inputs considered for display
cmax=5; % Max number of time-steps considered for display

alims={};
na=size(amin,2);

nrama=size(amax,1);  %<--Not needed, MPC and SET already cut limits >P
nrami=size(amin,1);

%nrama=min(size(amax,1),P);  %<--Not needed, MPC and SET already cut limits >P
%nrami=min(size(amin,1),P);
%
%amax=amax(1:nrama,:);
%amin=amin(1:nrami,:);

nra=max(nrami,nrama);
amax=[amax;kron(ones(nra-nrama),amax(nrama,:))]; % Extension
amin=[amin;kron(ones(nra-nrami),amin(nrami,:))];

if na==1,
   a=names{1};
   if nra==1,
      if isfinite(amin) | isfinite(amax),
         alims{1}=[sprintf('%0.5g <= ',amin) a sprintf(' <= %0.5g',amax)];
      else
         alims{1}=[a ' is unconstrained'];
      end
      
   else
      h=1;
      for j=1:min(nra,cmax-1),
         alims{h}=[sprintf('%0.5g <= ',amin(h)) a sprintf('(t+%d) <= %0.5g',h,amax(h))];
         h=h+1;
      end
      if j<=nra-2,
         alims{h}='...............';
         h=h+1;
      end   
      if nra>cmax-1
         alims{h}=[sprintf('%0.5g <= ',amin(nra)) a sprintf('(t+%d) <= %0.5g',nra,amax(nra))];
      end
   end
   %disp(' ')
else
   h=1;
   for k=1:na,
      a=names{k};
      if ~isfinite(amin(:,k)) & ~isfinite(amax(:,k)),
         alims{h}=[a ' is unconstrained'];
         h=h+1;
      else
         if nra==1,
            if (k<=rmax-1) | (k==na),
               alims{h}=[sprintf('%0.5g <= ',amin(1,k)) a sprintf(' <= %0.5g',amax(1,k))];
            elseif (na>rmax) & (i==na-1)
               alims{h}='...............';
            end
            h=h+1;
         elseif (k<=rmax) | (k==na),
            for j=1:min(nra,cmax-1),
               alims{h}=[sprintf('%0.5g <= ',amin(j,k)) a sprintf('(t+%d) <= %0.5g',j,amax(j,k))];
               h=h+1;
            end
            if j<=nra-2,
               alims{h}='...............';
               h=h+1;
            end   
            if nra>cmax-1
               alims{h}=[sprintf('%0.5g <= ',amin(nra,k)) a sprintf('(t+%d) <= %0.5g',nra,amax(nra,k))];
               h=h+1;
            end
         elseif (i==na-1) & (na>rmax),
            alims{h}=':::::::::::::::';
            h=h+1;
         end
      end
      %alims{h}=[' '];
      %h=h+1;
   end
end

aux2=0;
for j=1:length(alims),
   aux=length(alims{j});
   if aux2<aux,
      aux2=aux;
   end
end
aspace=['%' num2str(aux2+1) 's'];
