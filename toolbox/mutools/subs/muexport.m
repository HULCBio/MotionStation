%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

mu_exptot = xpii(gguivar('EXPORTVAR'),1);
if ~isempty(mu_exptot)
    for mu_expi = 1:mu_exptot
        mu_expression = [xpii(gguivar('EXPORTVAR'),2*mu_expi+1) ...
            '=gguivar('''  xpii(gguivar('EXPORTVAR'),2*mu_expi) ''');'];
        eval(mu_expression,'mu_ff=1;');
    end
    clear mu_expression mu_expi
end
clear mu_exptot