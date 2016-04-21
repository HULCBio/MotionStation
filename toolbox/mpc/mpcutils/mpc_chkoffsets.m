function newOffsets=mpc_chkoffsets(model,Offsets);

%MPC_CHKOFFSETS Check if Offset structure is ok

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/04/10 23:39:11 $   

[ny,nutot]=size(model);
if isa(model,'ss'),
   [nx,nutot]=size(model.B);
end

%[nx,nutot]=size(model.B);
%[ny,nx]=size(model.C);

x=[];
dx=[];
u=[];
y=[];

if ~isempty(Offsets),
   if ~isa(Offsets,'struct'),
      error('mpc:mpc_chkoffsets:struct','Model.Nominal must be a structure with fields X,Y,U,DX');
   end
   
   s=fieldnames(Offsets);
   
   for i=1:length(s),
      switch lower(s{i})
      case 'x'
          if ~isa(model,'ss'),
              %eval(['aux=Offsets.' s{i} ';']);
              aux=Offsets.(s{i});
              if ~isempty(aux),
                  error('mpc:mpc_chkoffsets:SSstate',sprintf('You specified a state offset for a %s model',class(model)));
              end
          else
              x=off_check(Offsets,s{i},nx);
          end
      case 'dx'
          if ~isa(model,'ss'),
              %eval(['aux=Offsets.' s{i} ';']);
              aux=Offsets.(s{i});
              if ~isempty(aux),
                  error('mpc:mpc_chkoffsets:SSstateDX',sprintf('You specified a state-update offset for a %s model',class(model)));
              end
          else
              dx=off_check(Offsets,s{i},nx);
          end
      case 'u'
          u=off_check(Offsets,s{i},nutot);
      case 'y'
         y=off_check(Offsets,s{i},ny);
      otherwise
         error('mpc:mpc_chkoffsets:field',[s{i} ' is not a valid field in Model.Nominal.']);
      end
   end
end

if isa(model,'ss'),
   if isempty(x),
      x=zeros(nx,1);
   end
   if isempty(dx),
      dx=zeros(nx,1);
   end
end

if isempty(u),
   u=zeros(nutot,1);
end
if isempty(y),
   y=zeros(ny,1);
end

newOffsets=struct('X',x,'DX',dx,'U',u,'Y',y);

% end mpc_chkoffsets

function a=off_check(Offsets,field,na)

%eval(['a=Offsets.' field ';']);
a=Offsets.(field);
err=0;
if norm(a)==0, % This handles both empty 'a' and a=zeros(nb,1) with nb~=na 
   a=zeros(na,1);
elseif isa(a,'double')
   [r,c]=size(a);
   if r*c~=na,
      err=1;
   end
else
   err=1;
end
if err,
   error('mpc:mpc_chkoffsets:size',sprintf('Model.Nominal.%s must be a %d-by-1 array',upper(field),na))
end
a=a(:);
if any(isnan(a)),
   error('mpc:mpc_chkoffsets:nan',sprintf('NaN entries found in Model.Nominal.%s',upper(field)))
end
if any(isinf(a)),
   error('mpc:mpc_chkoffsets:inf',sprintf('Infinite entries found in Model.Nominal.%s',upper(field)))
end

