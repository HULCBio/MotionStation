function [z,Ne,ny,nu,T,Name,Ncaps,errflag] = idprep(data,meflag,namein)
%IDDATA/IDPREP  Prepares data for parametric identification
%
%   [Z,Ne,Ny,Nu,T,Name,Ncaps,errflag] = IDPREP(Data,MEflag,NameIN)
%
%

%	L. Ljung 00-05-10
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.2.4.1 $  $Date: 2004/04/10 23:15:56 $


errflag = [];
z=[];
Ncaps=[];
y=pvget(data,'OutputData');
u=pvget(data,'InputData');
Ne = length(y);
ny=size(y{1},2);
nu=size(u{1},2);
Ts = pvget(data,'Ts');
T = Ts{1};
Name=data.Name;

if isnan(data)
   errflag = sprintf(['The data set contains missing data (NaNs).',...
         '\nFirst run Data = MISDATA(Data) to estimate missing data.']);
   return
end

if isempty(Name), 
   Name = namein;
   data.Name=Name; 
   assignin('caller',inputname(1),data);
   
end

ints = data.InterSample;
if meflag & Ne>1
   errflag=['This routine does not accept multiple experiment' ...
         ' data.'];
   return
end
farg = pvget(data,'Argument');
%om = pvget(data,'SamplingInstants');
if meflag
   z=[y{1},u{1}];
   Ncaps = size(z,1);
else
   for ke=1:Ne
%        if Ts{ke}==0
%            efre  = i*om{ke};
%        else
%            efre = exp(i*om{ke}*Ts{ke});
%        end
      z{ke}=[y{ke},u{ke},farg{ke}]; % %%LL note now freq last!
      
      Ncaps = [Ncaps,size(z{ke},1)];
      if isempty(Ts{ke})|Ts{ke}~=T
         errflag=['This routine requires equally sampled data.'];
      end
      
      %%LL%% Same intersample
      %%LL%% Reduce periodic
      
      if any(any(isnan(z{ke}))')
         errflag=['This routine does not handle missing data' ...
               ' (NaN''s).'];
      end
   end
end


