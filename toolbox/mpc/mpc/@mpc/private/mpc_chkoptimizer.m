function newOptimizer=mpc_chkoptimizer(Optimizer);

%MPC_CHKOPTIMIZER Check if Optimizer structure is ok and define defaults

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date:    

default=mpc_defaults;

if isempty(Optimizer),
   Optimizer.MaxIter=default.optimizer.maxiter;
end

if ~isa(Optimizer,'struct'),
   error('mpc:mpc_chkoptimizer:struct','Model.Optimizer must be a structure with fields MaxIter,Trace,Solver,MinOutputECR.');
end

fields={'MaxIter','Trace','Solver','MinOutputECR'};

s=fieldnames(Optimizer);

% Check for wrong or ambiguous fields
for i=1:length(s),
   name=s{i};
   j=strmatch(lower(name),lower(fields)); 
   if isempty(j), % field inexistent
      error('mpc:mpc_chkoptimizer:field',sprintf('The field ''%s'' in Optimizer is invalid.',name));
   end
   if prod(size(j))>1,
      error('mpc:mpc_chkoptimizer:ambfield','Ambiguous fields in Optimizer.');
   end
   % Correct the name
   s{i}=fields{j};
end


for j=1:length(fields),
   aux=fields{j};
   i=find(ismember(lower(s),lower(aux))); % locate fields{j} within s
   if isempty(i),
      % Define missing field
      field=[];
      %eval(sprintf('Optimizer.%s=field;',aux));
      Optimizer.(aux)=field;
   else
      % In case of duplicate names because of different case, the last
      % element i(end) is the one supplied as latest (through SET)
      s=fieldnames(Optimizer); % retrieve original names
      aux=s{i(end)};
      %eval(sprintf('field=Optimizer.%s;',aux)); 
      %eval(sprintf('Optimizer=rmfield(Optimizer,''%s'');',aux));
      %eval(sprintf('Optimizer.%s=field;',fields{j})); 
      field=Optimizer.(aux);            % retrieve value
      Optimizer=rmfield(Optimizer,aux); % remove duplicated field
      Optimizer.(fields{j})=field;      % update field
  end
   
   switch lower(aux)
   case 'maxiter'
      errmsg='Optimizer.MaxIter must be a positive integer';
      errid='maxiter';
      errflag=1;
      if isempty(field),
         field=default.optimizer.maxiter;
         errflag=0;
      elseif isa(field,'double'),
         if prod(size(field))==1,
            if field>0 & isfinite(field),
               errflag=0;
               if round(field)~=field,
                  field=round(field);
                  warning('mpc:mpc_chkoptimizer:maxiter',sprintf('Optimizer.MaxIter rounded at %d',field));
               end
            end
         end
      end
      
   case 'trace'
      errmsg='Optimizer.Trace must be either ''on'' or ''off''';
      errid='trace';
      errflag=1;
      if isempty(field),
         field=default.optimizer.trace;
         errflag=0;
      elseif isa(field,'char'),
         if strcmp(lower(field),'on') |strcmp(lower(field),'off'),
            errflag=0;
         end
      end
      
   case 'solver'
      errmsg='Optimizer.Solver can only be ''ActiveSet''';
      errid='solver';
      errflag=1;
      if isempty(field),
         field=default.optimizer.solver;
         errflag=0;
      elseif isa(field,'char'),
         if strcmp(lower(field),'activeset'),
            errflag=0;
         end
      end
      
   case 'minoutputecr'
      errmsg='Optimizer.MinOutputECR must be a positive scalar';
      errid='minecr';
      errflag=1;
      if isempty(field),
         field=default.optimizer.minoutputecr;
         errflag=0;
      elseif isa(field,'double'),
         if prod(size(field))==1,
            if field>0 & isfinite(field),
               errflag=0;
               if field<default.optimizer.minoutputecr,
                  warning('mpc:mpc_chkoptimizer:minoutecr',sprintf('Optimizer.MinOutputECR is smaller than %7.5f',default.optim.minoutputecr));
               end
            end
         end
      end
   end
   
   if errflag,
      error(sprintf('mpc:mpc_chkoptimizer:%s',errid),errmsg);
   end
   %eval(['Optimizer.' aux '=field;']);
   Optimizer.(aux)=field;
end

newOptimizer=Optimizer;