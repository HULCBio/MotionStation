function Value = pvget(sys,Property)
%PVGET  Get values of public IDDATA properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%       Author(s): P. Gahinet, 7-8-97
%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.7.4.1 $  $Date: 2004/04/10 23:16:16 $

if nargin==2,
    % Value of single property: VALUE = PVGET(SYS,PROPERTY)
    ssubs = struct('type','.','subs',Property);
    try
        Value = builtin('subsref',sys,ssubs);
        % Don't return: Samplinginstants may need modification
    catch
    end
    if strcmp(Property,'SamplingInstants')
        Ncap=get(sys,'N'); Tstr=sys.Tstart;Tss=sys.Ts;
        for kk=1:length(Ncap) 
            if isempty(Value{kk})
                if strcmp(lower(sys.Domain),'frequency') % It is not suitable
                    % to have default values even for a DFT grid. Here we assume
                    % an equal grid from zero up to and including the Nyquist
                    % frequency
                    Value{kk} = [0:Ncap(kk)]'/Tss{kk}*pi/Ncap(kk);
                else
                    tsta = Tstr{kk};
                    if isempty(tsta)
                        tsta = Tss{kk};
                    end
                    Value{kk}=[tsta+[0:Ncap(kk)-1]*Tss{kk}]'; 
                end
            end             
        end
    elseif strcmp(Property,'Tstart')
        Ncap=get(sys,'N');Tss=sys.Ts;
        for kk=1:length(Ncap) 
            if isempty(Value{kk}),Value{kk}=Tss{kk}; end
        end
        
    elseif strcmp(Property,'Argument') % The argument of the Frequency function
                                       % G(i\omega) or G(exp(i\omega T) or
                                       % G(exp(i\omega *2pi*T)
        if strcmp(sys.Domain,'Time')
            Value = [];
        else
            w = sys.SamplingInstants;
            for kexp = 1:length(w)
                if strcmp(sys.Tstart{kexp},'Hz')
                    fc = 2*pi;
                else
                    fc = 1;
                end
                if sys.Ts{kexp}
                    Value{kexp} = exp(sqrt(-1)*w{kexp}*fc*sys.Ts{kexp});
                else
                    Value{kexp} = sqrt(-1)*w{kexp};
                end
            end
        end
        elseif strcmp(Property,'Radfreqs') %  The frequencies in rad/sec
        if strcmp(sys.Domain,'Time')
            Value = [];
        else
            Value = sys.SamplingInstants;
            for kexp = 1:length(Value)
                if strcmp(sys.Tstart{kexp},'Hz')
                    Value{kexp} = 2*pi*Value{kexp};
                end
            end
        end
    end
else
    % Return all public property values
    % RE: Private properties always come last in IDDATA PropValues
    IDMPropNames  = pnames(sys);
    IDMPropValues = struct2cell(sys);
    Value = IDMPropValues(1:length(IDMPropNames));
end
