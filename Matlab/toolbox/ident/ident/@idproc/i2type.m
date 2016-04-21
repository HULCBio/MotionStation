function Type = i2type(mod)
%I2TYPE extracts the 'Type' of an IDPROC object

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/10 23:17:08 $

Kp = mod.Kp;
Tp1 = mod.Tp1;
Tp2 = mod.Tp2;
Tp3 = mod.Tp3;
Tz = mod.Tz;
Tw = mod.Tw;
Td = mod.Td;
Zeta = mod.Zeta;
Int = mod.Integration;

nu = length(Kp.status);
for ku = 1:nu
    Typet = '';
    Typet(1)='P';
    % first underdamped
    if ~strcmp(Tw.status(ku),'zero')    % first underdamped
        ud = 1;
        if ~strcmp(Tp3.status(ku),'zero')
            Typet(2) = '3';
        else
            Typet(2) = '2';
        end
    else  % not underdamped
        ud = 0;
        if strcmp(Tp1.status(ku),'zero')
            Typet(2)='0';
        elseif strcmp(Tp2.status(ku),'zero')
            Typet(2) = '1';
        elseif strcmp(Tp3.status(ku),'zero')
            Typet(2) = '2';
        else
            Typet(2) = '3';
        end
    end
    nr = 2;
    if ~strcmp(Td.status(ku),'zero')
        Typet(3) = 'D';
        nr = 3;
    end
    if (~strcmp(Tz.status(ku),'zero'))&eval(Typet(2))>0
        Typet(nr+1) = 'Z';
        nr = nr + 1;
    end
    if ~strcmp(Int{ku},'off')
        Typet(nr+1) = 'I';
        nr = nr + 1;
    end
    if ud
        Typet(nr+1) = 'U';
    end
    Type{ku} = Typet;
end
    