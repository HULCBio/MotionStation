function sys = type2stat(Mod,Type)
%TYPE2STAT Translates 'TYPE' of IDPROC model to parameter properties' status fields.

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:18:09 $

if ~iscell(Type),Type={Type};end
nu = length(Type); %%LL what if nu is lowered?
%%LL What if type is changed and 
%K.value = zeros(1,nu);
K = Mod.Kp;
Tp1 = Mod.Tp1;
Tp2 = Mod.Tp2;
Tp3 = Mod.Tp3;
Tw = Mod.Tw;
Zeta = Mod.Zeta;
Td = Mod.Td;
Tz = Mod.Tz;
Int = Mod.Integration;
for ku = 1:nu;
    tp = Type{ku};
    %   K.value(ku) = par(1);
    if tp(end)=='U';
        if strcmp(Tw.status{ku},'zero') % if it is ''fixed'' don't change
            Tw.status{ku} = 'estimate';
        end
        %      Tw.value(ku) = par(1);
        if strcmp(Zeta.status{ku},'zero')
            Zeta.status{ku} = 'estimate';
        end
        %     Zeta.value(ku) = par(1);
        Tp1.status{ku} = 'zero';
        Tp2.status{ku} = 'zero';
        if eval(tp(2))==3
            if strcmp(Tp3.status{ku},'zero');%%LL 3 eller 1??
                Tp3.status{ku} = 'estimate';
            end
        else
            Tp3.status{ku} = 'zero';
            %        Tp1.value(ku) = par(1),
        end
    else
        Tw.status{ku} = 'zero';
        Zeta.status{ku} = 'zero';
        if eval(tp(2))>0
            if strcmp(Tp1.status{ku},'zero');
            Tp1.status{ku} = 'estimate';
        end
    else
        Tp1.status{ku}='zero';%                   Tp1.value(ku) = par(1);
            
        end
        if eval(tp(2))>1
            if strcmp(Tp2.status{ku},'zero');
            Tp2.status{ku} = 'estimate';
        end
            %                  Tp2.value(ku) = par(1);
            
        else
            Tp2.status{ku}='zero';
        end
        if eval(tp(2))>2
            if strcmp(Tp3.status{ku},'zero')
            Tp3.status{ku} = 'estimate';
        end
            %                 Tp3.value(ku) = par(1);
        else
            Tp3.status{ku}='zero';
        end
    end
    if any(tp=='I')
        Int{ku} = 'on';
    else
        Int{ku} = 'off';
    end
    if any(tp=='D')
        if strcmp(Td.status{ku},'zero')
        Td.status{ku} = 'estimate';
    end
        %            Td.value(ku) = par(1);
    else
        Td.status{ku} = 'zero';
        
    end
    if any(tp=='Z')
        if strcmp(Tz.status{ku},'zero')
        Tz.status{ku} = 'estimate';
    end
        %           Tz.value(ku) = par(1);
    else
        Tz.status{ku}='zero';
    end
end
sys = Mod;
sys.Kp = K;
sys.Tp1 = Tp1;
sys.Tp2 = Tp2;
sys.Tp3 = Tp3;
sys.Tw = Tw;
sys.Zeta  =  Zeta;
sys.Tz = Tz;
sys.Td = Td;
sys.Integration = Int;
