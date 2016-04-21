function fixp = getfixpar(mod)
%GETFIXPAR Extracts those parameters in MOD that have status = 'fix';

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/10 23:17:06 $


%% Here we should apply pnames instead.
pna = pvget(mod,'PName');
Kp = mod.Kp;
nu = length(Kp.status);
fixp ={};pnr = 0;
for ku = 1:nu
    if nu >1
        add = ['(',int2str(ku),')'];
    else
        add = [];
    end
    if ~strcmp(Kp.status{ku},'zero')
        pnr = pnr + 1;
    end
    if strcmp(Kp.status{ku},'fixed')
        fixp = [fixp;pna(pnr)];%[fixp;{['Kp',add]}];
    end
    Tp1 = mod.Tp1;
    if ~strcmp(Tp1.status{ku},'zero')
        pnr = pnr + 1;
    end
    if strcmp(Tp1.status{ku},'fixed')
        fixp = [fixp;pna(pnr)];%[fixp;{['Tp1',add]}];
    end
    Tp2 = mod.Tp2;
    if ~strcmp(Tp2.status{ku},'zero')
        pnr = pnr + 1;
    end
    if strcmp(Tp2.status{ku},'fixed')
        fixp = [fixp;pna(pnr)];%[fixp;{['Tp2',add]}];
    end
    Tp3 = mod.Tp3;
    if ~strcmp(Tp3.status{ku},'zero')
        pnr = pnr + 1;
    end
    if strcmp(Tp3.status{ku},'fixed')
        fixp = [fixp;pna(pnr)];%[fixp;{['Tp3',add]}];
    end
    
    Tw = mod.Tw;
    if ~strcmp(Tw.status{ku},'zero')
        pnr = pnr + 1;
    end
    if strcmp(Tw.status{ku},'fixed')
        fixp = [fixp;pna(pnr)];%[fixp;{['Tw',add]}];
    end
    Zeta = mod.Zeta;
    if ~strcmp(Zeta.status{ku},'zero')
        pnr = pnr + 1;
    end
    if strcmp(Zeta.status{ku},'fixed')
        fixp = [fixp;pna(pnr)];%[fixp;{['Zeta',add]}];
    end
  
    Td = mod.Td;
    if ~strcmp(Td.status{ku},'zero')
        pnr = pnr + 1;
    end
    if strcmp(Td.status{ku},'fixed')
        fixp = [fixp;pna(pnr)];%[fixp;{['Td',add]}];
    end
      Tz = mod.Tz;
    if ~strcmp(Tz.status{ku},'zero')
        pnr = pnr + 1;
    end
    if strcmp(Tz.status{ku},'fixed')
        fixp = [fixp;pna(pnr)];%[fixp;{['Tz',add]}];
    end
end