function [z,Ne,ny,nu,T,Name,Ncaps,errflag,ynorm] = idprep(data,meflag,namein)
%IDDATA/IDPREP  Prepares data for parametric identification
%
%   [Z,Ne,Ny,Nu,T,Name,Ncaps,errflag] = IDPREP(Data,MEflag,NameIN)
%
%

%	L. Ljung 00-05-10
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.10.4.1 $  $Date: 2004/04/10 23:15:54 $


errflag = [];
z=[];
Ncaps=[];
ynorm = 0;
y=data.OutputData;
u=data.InputData;
Ne = length(y);
ny=size(y{1},2);
nu=size(u{1},2);
Ts = data.Ts;
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
if meflag
   z=[y{1},u{1}];
   Ncaps = size(z,1);
else
   for ke=1:Ne
       ynorm = norm(y{ke},'fro') + ynorm;
      z{ke}=[y{ke},u{ke}];
      Ncaps = [Ncaps,size(z{ke},1)];
      if isempty(Ts{ke})|Ts{ke}~=T
         errflag=['This routine requires equally sampled data in each experiment.'];
      end
      
      %%LL%% Same intersample
      %%LL%% Reduce periodic
      
      if any(any(isnan(z{ke}))')
         errflag=['This routine does not handle missing data' ...
               ' (NaN''s).'];
      end
   end
end
ynorm = ynorm/sqrt(sum(Ncaps));

