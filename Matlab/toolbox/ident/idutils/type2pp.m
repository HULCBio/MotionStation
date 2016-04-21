function [K,Tp1,Tp2,Tp3,Tz,Tw,Zeta,Td,Int,ulev] = type2pp(Type,par)
%TYPE2 Translates 'TYPE' of IDPROC model to parameter properties' status fields.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/10 23:20:32 $

if nargin<2
    par = NaN*ones;
end
if ~iscell(Type),Type={Type};end
nu = length(Type);
%K.value = zeros(1,nu);
K.status = cell(1,nu);
K.status(:) = {'zero'};
K.min = 0.001*ones(1,nu); % to protect from 0
K.max = inf*ones(1,nu);
Int = cell(1,nu);
Int(:) = {'off'};
[Tp1,Tp2,Tp3,Tz,Tw,Zeta,Td,ulev]=deal(K);
K.status(:) = {'estimate'};
K.min = -inf*ones(1,nu);
Tz.min = -inf*ones(1,nu);
ulev.min = -inf*ones(1,nu);
ulev.value = zeros(1,nu);
for ku = 1:nu;
    tp = Type{ku};
 %   K.value(ku) = par(1);
    if tp(end)=='U';
        Tw.status{ku} = 'estimate';
  %      Tw.value(ku) = par(1);
        Zeta.status{ku} = 'estimate';
   %     Zeta.value(ku) = par(1);
        if eval(tp(2))==3
            Tp3.status{ku} = 'estimate';
    %        Tp1.value(ku) = par(1),
        end
    else
        if eval(tp(2))>0
            Tp1.status{ku} = 'estimate';
     %                   Tp1.value(ku) = par(1);

        end
        if eval(tp(2))>1
            Tp2.status{ku} = 'estimate';
      %                  Tp2.value(ku) = par(1);

        end
        if eval(tp(2))>2
            Tp3.status{ku} = 'estimate';
       %                 Tp3.value(ku) = par(1);

        end
    end
    if any(tp=='I')
        Int{ku} = 'on';
        %ulev.status{ku} = 'estimate';
        %ulev.value(ku) = NaN;
    end
    if any(tp=='D')
        Td.status{ku} = 'estimate';
        %            Td.value(ku) = par(1);

        Td.min(ku) = 0;
       % Td.max(ku) = 30;
    end
     if any(tp=='Z')
        Tz.status{ku} = 'estimate';
         %           Tz.value(ku) = par(1);

    end
end