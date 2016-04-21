function newSpecs=mpc_specs(Specs,n,type,p,MinOutputECR,names,index,InheritNameFromPlant)

%MPC_SPECS Check Specs
%
%   type='ManipulatedVariables' or 'OutputVariables' or 'DisturbanceVariables'
%
%   Given the array of structures Specs, convert data to matrix format

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:20 $
 

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

if nargin<8 | isempty(InheritNameFromPlant),
    InheritNameFromPlant=1; % Inheritance of names from DV/OV/MV has been disabled
end

default=mpc_defaults;
u=default.u;
y=default.y;
d=default.d;

if isempty(Specs),
    if n==0,
        newSpecs=Specs;
        return
    end
    for i=1:n,
        Specs(i).Name=''; % Create a cell array of length n
    end
end

if ~isa(Specs,'struct'),
    if n>1,
        error('mpc:mpc_specs:size',sprintf('%s must be a %d-by-1 struct array.',type,n));
    else
        error('mpc:mpc_specs:struct',sprintf('%s must be a structure.',type));
    end
end


len=length(Specs);
if len>n,
    error('mpc:mpc_specs:long',sprintf('Too many elements in %s (must be <= %d)',type,n));
end

if len<n,
    if verbose,
       if len==0,
            fprintf('-->No specs for %s specified, assuming default values\n',type);
        else
            fprintf('-->The number of elements in %s is smaller than %d. Assuming default values\n',type,n);
        end
    end
    for i=len+1:n,
        %Specs{i}=[];
        %Specs(i).Min=[];
        %eval(sprintf('Specs(i).%s=[];',s{1}));
        s=fieldnames(Specs(1));
        Specs(i).(s{1})=[];
    end
end


switch type
    case 'ManipulatedVariables'
        fields={'Min','Max','MinECR','MaxECR',...
                'RateMin','RateMax','RateMinECR','RateMaxECR','Target',...
                'Name',... %'Zero','Span',
                'Units'};
        deftype='u';
    case 'OutputVariables'
        fields={'Min','Max','MinECR','MaxECR','Name',...%'Zero','Span',
                'Units','Integrator'};
        deftype='y';
    case 'DisturbanceVariables'
        fields={'Name',...%'Zero','Span',
                'Units'};
        deftype='d';
end


for h=1:n,
    
    clear Struct
    s=fieldnames(Specs(h)); % get field names
    
    % Check for wrong fields
    for i=1:length(s),
        name=s{i};
        j=find(ismember(lower(fields),lower(name))); 
        if isempty(j), % field inexistent
            error('mpc:mpc_specs:field',sprintf('The field ''%s'' in %s(%d) is invalid.',name,type,h));
        end
    end
    
    if isfield(Specs(h),'Name') & ~isempty(Specs(h).Name) &...
            (~strcmp(Specs(h).Name,names{index(h),:}) & ~InheritNameFromPlant),
        error('mpc:mpc_specs:dnames',sprintf('%s\n%s',...
            'Signal names must be specified in the Model.Plant.InputName and Model.Plant.OutputName',...
            'properties of the MPC object. Type "help setname" for details'));
    end
    if InheritNameFromPlant | ~isfield(Specs(h),'Name') | isempty(Specs(h).Name) | ...
        strcmp(Specs(h).Name,names{index(h),:}),
        % Inherit signal names from Plant I/O names. Names previously stored in
        % Specs will be lost.
        Specs(h).Name='';

        %eval(sprintf('%s.name=''%s'';',deftype,names{index(h),:}));
        switch deftype
            case 'u'
                u.name=names{index(h),:};
            case 'y'
                y.name=names{index(h),:};
            case 'd'
                d.name=names{index(h),:};
        end
    end

    % Assign all fields
    for j=1:length(fields),
        aux=fields{j};
        i=find(ismember(lower(s),lower(aux))); % locate fields{j} within s

        switch deftype
            case 'u'
                faux=u.(lower(aux));
            case 'y'
                faux=y.(lower(aux));
            case 'd'
                faux=d.(lower(aux));
        end
        
        if isempty(i),
            % Define missing field
            field=[];
            %eval(sprintf('Struct.%s=%s.%s;',aux,deftype,lower(aux)));
            Struct.(aux)=faux;
        else
            % In case of duplicate names because of different case, the last
            % element i(end) is the one supplied as latest (through SET)
            aux=s{i(end)};
            
            %eval(sprintf('field=Specs(h).%s;',aux));
            field=Specs(h).(aux);
            if isempty(field),
                %eval(sprintf('field=%s.%s;',deftype,lower(aux)));
                field=faux;
            end   
            
            errid=sprintf('mpc:mpc_specs:%s',lower(aux));
            switch lower(aux)
                case {'name','units'}
                    if ~isa(field,'char'),
                        error([errid 'string'],sprintf('%s(%d).%s must be a string.',type,h,aux));
                    end
                case 'target'
                    if isa(field,'char'),
                        if ~strcmp(field,u.target),
                            error([errid 'char'],sprintf('%s(%d).%s must be real valued or the string ''%s''.',type,h,aux,u.target));
                        end
                    else
                        if ~isa(field,'double'),
                            error([errid 'real'],sprintf('%s(%d).%s must be real valued or the string ''%s''.',type,h,aux,u.target));
                        end
                    end
                otherwise           
                    if ~isa(field,'double'),
                        error([errid 'real'],sprintf('%s(%d).%s must be real valued.',type,h,aux));
                    end
            end
            
            if ~isempty(field),      
                
                % Check nonnegativity of ECRs and check input Target
                switch deftype
                    case 'u'
                        if ismember(j,[3 4 7 8]),
                            if field<0,
                                error([errid 'neg'],sprintf('%s(%d).%s must be positive or zero.',type,h,aux));
                            elseif ~isfinite(field),
                                error([errid 'inf'],sprintf('%s(%d).%s must be finite.',type,h,aux));
                            end
                        end
                        
                        if j==9 & ~isfinite(field),
                            error([errid 'inf'],sprintf('%s(%d).%s must be finite.',type,h,aux));
                        end
                        
                    case 'y'
                        if ismember(j,[3 4]),
                            if field<=MinOutputECR,
                                warning('mpc:mpc_specs:ecrtoosmall',sprintf('%s(%d).%s is too small. Increased to Optimizer.MinOutputECR=%2.1e',type,h,aux,MinOutputECR));
                                field=MinOutputECR;
                            elseif ~isfinite(field),
                                error([errid 'inf'],sprintf('%s(%d).%s must be finite.',type,h,aux));
                            end
                        elseif (j==7),
                            if (field<0)| ~isfinite(field),
                                error([errid 'neg'],sprintf('%s(%d).%s must be nonnegative and finite.',type,h,aux));
                            end
                        end
                end
            end

            if isnumeric(field), % Don't do the following for char arrays
                field=field(:);
                if length(field)>p, % Longer than prediction horizon ?
                    warning('mpc:mpc_specs:truncate',sprintf('%s(%d).%s has more entries than prediction horizon %d. Truncated at %d.',type,h,aux,p,p))
                    field=field(1:p);
                end
            end

            %eval(sprintf('Struct.%s=field;',fields{j}));
            Struct.(fields{j})=field;
        end
    end
    
    % Check consistency of limits

    errid=sprintf('mpc:mpc_specs:%slimits',deftype);
    if deftype~='d',
        if Struct.Max<Struct.Min,
            error(errid,sprintf('%s(%d).Min is greater than %s(%d).Max.',type,h,type,h));
        end
    end
    if deftype=='u',
        if Struct.RateMax<Struct.RateMin,
            error(errid,sprintf('%s(%d).RateMin is greater than %s(%d).RateMax.',type,h,type,h));
        end
    end
    
    %if Struct.Span<Struct.Zero,
    %   error(sprintf('%s(%d).Span should be greater than %s(%d).Zero.',type,h,type,h));
    %end
    newSpecs(h)=Struct;
end
