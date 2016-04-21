function newWeights=mpc_chkweights(Weights,p,nu,ny);

%MPC_CHKWEIGHTS Check Weights structure

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:15 $

swarn=warning;
warning backtrace off; % to avoid backtrace

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

default=mpc_defaults;

if isempty(Weights),
   % Define Weights as a structure
   def=default.weight.manipulatedvariables;
   Weights.ManipulatedVariables=def*ones(1,nu);
   if verbose,
      fprintf('-->No Weights.ManipulatedVariables specified, assuming default %7.5f\n',def);
   end
end

if ~isa(Weights,'struct'),
   error('mpc:mpc_chkweights:struct','Weights must be a structure of weights');
end

fields={'ManipulatedVariables','ManipulatedVariablesRate','OutputVariables','ECR'};

s=fieldnames(Weights); % get field names
for i=1:length(s),
   Name=s{i};
   name=lower(Name);
   % Handle multiple names
   if strcmp(name,'mv') | strcmp(name,'manipulated') | strcmp(name,'input'),
      name='manipulatedvariables';
   elseif strcmp(name,'ov') | strcmp(name,'controlled') | strcmp(name,'output'),
      name='outputvariables';
   elseif strcmp(name,'mvrate') | strcmp(name,'manipulatedrate') | strcmp(name,'inputrate'),
      name='manipulatedvariablesrate';
   end
   
   j=find(ismember(lower(fields),name)); % locate name within 'fields'
   if isempty(j), % field inexistent
      %error(sprintf('The field ''%s'' in %sSpecs{%d} is invalid',name,type,h));
      error('mpc:mpc_chkweights:field',sprintf('The field ''%s'' in Weights is invalid',Name));
   else
      aux=fields{j};
      %eval(['aux2=Weights.' Name ';']);
      aux2=Weights.(Name);
      if ~isa(aux2,'double'),
         error('mpc:mpc_chkweights:real',['Weights.' Name ' must be real valued.']);
      else
         % Check correctness of weight
         switch name
             case {'manipulatedvariables','manipulatedvariablesrate'}
                 aux2=mpc_prechkwght(['Weights.' Name],aux2,p,nu,name);
                 %eval(['newWeights.' aux '=aux2;']);
             case 'outputvariables'
                 aux2=mpc_prechkwght(['Weights.' Name],aux2,p,ny,name);
                 %eval(['newWeights.' aux '=aux2;']);
             case 'ecr'
                 aux2=mpc_prechkwght(['Weights.' Name],aux2,1,1,name);
                 %eval(['newWeights.' aux '=aux2;']);
         end
         newWeights.(aux)=aux2;
      end
   end
end   


% Define missing fields
for i=1:length(fields),
   aux=fields{i};
   if ~isfield(newWeights,aux),
      %eval(['newWeights.' aux '=[];']);
      newWeights.(aux)=[];
   end
   %eval(['aux2=newWeights.' aux ';']);
   aux2=newWeights.(aux);
   if isempty(aux2),
      %eval(['def=default.weight.' lower(aux) ';']);
      def=default.weight.(lower(aux));
      switch aux
      case {'ManipulatedVariables','ManipulatedVariablesRate'},
         %eval(['newWeights.' aux '=def*ones(1,nu);']);
         newWeights.(aux)=def*ones(1,nu);
         if verbose,
            fprintf('-->No Weights.%s specified, assuming default %7.5f\n',aux,def);
         end
      case 'OutputVariables',
         %eval(['newWeights.' aux '=def*ones(1,ny);']);
         newWeights.(aux)=def*ones(1,ny);
         if verbose,
            fprintf('-->No Weights.%s specified, assuming default %7.5f\n',aux,def);
         end
      case 'ECR',
         % Now all input and output weights have been defined, because 'ECR' is the last element in fields
         newWeights.ECR=def*max([newWeights.ManipulatedVariables(:);...
               newWeights.ManipulatedVariablesRate(:);...
               newWeights.OutputVariables(:)]); % Weight on slack variable for ECRs
      end
   end
end


function newwt=mpc_prechkwght(a,wt,p,n,name);

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:15 $   


newwt=wt;

if isempty(wt),
   if ~strcmp(name,'ecr'), 
      %eval(['newwt=default.weight.' name '*ones(1,n);']);
      newwt=default.weight.(name)*ones(1,n);
      return
   end
end

if any(wt(:)< 0)
   error('mpc:mpc_chkweights:neg',sprintf('One or more elements in %s are negative.',a)); 
end 
if any(~isfinite(wt(:)))
   error('mpc:mpc_chkweights:inf',sprintf('Infinite weights in %s not allowed.',a)); 
end 

[nrow,ncol]=size(wt);
if nrow>p         % Has the user specified a longer horizon than necessary?
   warning(sprintf('Too many rows in %s. Extra rows deleted.',a))
   newwt=wt(1:p,:);
end
if ncol~=n         % Has the user specified more weights than necessary?
   error('mpc:mpc_chkweights:size',sprintf('%s must have %d columns.',a,n));
end

%end mpc_prechkwght
