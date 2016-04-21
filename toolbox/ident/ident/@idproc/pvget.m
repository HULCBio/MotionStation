function Value = pvget(sys,Property)
%PVGET  Get values of public IDPROC properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.11.4.1 $  $Date: 2004/04/10 23:18:05 $

if nargin == 1 |(nargin ==2 &any(strcmp(Property,{'Kp','Tp1','Tp2','Tw','Zeta','Tp3',...
            'InputDelay','Td','Tz'})))
    par = pvget(sys.idgrey,'ParameterVector');
    typec = i2type(sys);%sys.Type;
    if ~iscell(typec),typec={typec};end
    [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz,dmpar] = procpar(sys);
end
 
% Value of single property: VALUE = PVGET(SYS,PROPERTY)
if nargin == 1
    prop = {'Kp','Tp1','Tp2','Td','Tz','Tw','Zeta','Tp3','DisturbanceModel','Integration',...
            'InputLevel'};
else
    prop = {Property};
end
for kp = 1:length(prop)
    Property = prop{kp};
    try
        switch Property % First the virtual properties
            case 'Type'
                Value = i2type(sys);
                
            case 'Kp'
                Value = sys.Kp;
                Value.value = Kp.';
                Kp = Value;
            case 'Tp1'
                Value = sys.Tp1;
                 ind = strcmp(Value.status,'zero');
                Tp1(ind)=0;
                Value.value = Tp1.';
                Tp1 = Value;
            case 'Tp2'
                Value = sys.Tp2;
                ind = strcmp(Value.status,'zero');
                Tp2(ind)=0;
                Value.value = Tp2.';
                Tp2 = Value;
            case 'Td'
                Value = sys.Td;
                nr = isnan(Td);
                est =strcmp(Value.status,'estimate')';% to avoid problems in inputdelay
                nr = find(nr & ~est);
                Td(nr) = zeros(1,length(nr));
                Value.value = Td.';
                Td = Value;
%                  case 'InputDelay'
%                 Value = sys.Td;
%                 nr = isnan(Td);
%                 est =strcmp(Value.status,'estimate')';% to avoid problems in inputdelay
%                 %Value = Value.value;
%                 nr = find(nr & ~est);
%                 Td(nr) = zeros(1,length(nr));
%                 Value = Td;
%                 %Value.value = Td.';
%                 %Td = Value;
            case 'Tz'
                Value = sys.Tz;
                 ind = strcmp(Value.status,'zero');
                Tz(ind)=0;
                Value.value = Tz.';
                Tz = Value;
            case 'Tw'
                Value = sys.Tw;
                 ind = strcmp(Value.status,'zero');
                Tw(ind)=0;
                Value.value = Tw.';
                Tw = Value;
            case 'Zeta'
                Value = sys.Zeta;
                 ind = strcmp(Value.status,'zero');
                zeta(ind)=0;
                Value.value = zeta.';
                Zeta = Value;
            case 'Tp3'
                Value = sys.Tp3;
                ind = strcmp(Value.status,'zero');
                Tp3(ind)=0;
                Value.value = Tp3.';
                Tp3 = Value;
            case 'InputLevel'
                Value = sys.InputLevel;
                ind = strcmp(Value.status,'zero');
                InputLevel(ind)=0;
                %Value.value = [];%InputLevel.'; From procpar
                InputLevel = Value;
            case 'DisturbanceModel'
                fa = pvget(sys.idgrey,'FileArgument');
                par = pvget(sys.idgrey,'ParameterVector');
                lambda = pvget(sys.idgrey,'NoiseVariance');
                Value = fa{3};
                if strcmp(Value,'Fixed')
                    pard = fa{4};
                    par = [par;pard(:)];
                    nr = length(pard)/2;
                end
                if strcmp(Value(1:2),'AR')|strcmp(Value,'Fixed')
                    if strcmp(Value(1:2),'AR')
                        nr = eval(Value(5));
                        cov = pvget(sys.idgrey,'CovarianceMatrix');
                    else
                        cov =[];
                    end
                    if nr == 1
                        model = idpoly([1 par(end-1)],[],[1 par(end)],'ts',0);
                        if length(cov)<2,cov=[];end
                        if ~isempty(cov)&~ischar(cov)
                            model = pvset(model,'CovarianceMatrix',cov(end-1:end,end-1:end));
                        end
                    else
                        model = idpoly([1 par(end-3:end-2)'],[],[1 par(end-1:end)'],'ts',0);
                        if length(cov)<4,cov=[];end
                        if ~isempty(cov)&~ischar(cov)
                            model = pvset(model,'CovarianceMatrix',cov(end-3:end,end-3:end));
                        end
                    end
                    model = pvset(model,'NoiseVariance',lambda);
                else % Value = None
                    model = idpoly(1,[],1,1,[],'Ts',0,'NoiseVariance',lambda);
                end
                if ~strcmp(Value,'Fixed')
                    model = pvset(model,'EstimationInfo',pvget(sys,'EstimationInfo'));
                end
                Value = {fa{3},model};
                dist = Value;
            case 'ParameterVector'
                Value = pvget(sys.idmodel,'ParameterVector');
            case 'FixedParameter' % This is a field in Algorithm, but has special treatment here
                Value = getfixpar(sys);
            otherwise  
                Value = builtin('subsref',sys,struct('type','.','subs',Property));
        end
    catch
        Value = pvget(sys.idgrey,Property);
    end
end

if nargin == 1
    % Return all public property values
    % RE: Private properties always come last in IDMPropValues
     grey = sys.idgrey;model=pvget(grey,'idmodel');
    [Validm]=pvget(model);
     Type = i2type(sys);%sys.Type;
    ini = pvget(sys.idgrey,'InitialState');
     Value = struct2cell(sys);
     tt = [];
    for kk = 1:length(Type)
        tt = [tt,Type{kk}];
        if kk~=length(Type)
            tt=[tt,','];
        end
    end
    int = sys.Integration;
    Value = [{tt};{Kp;Tp1;Tp2;Tp3;Tz;Tw;Zeta;Td;int;InputLevel;ini;dist};Validm];
end
