function [par,maxp,minp,pnr,dnr,bnr] = pbounds(sys)
%PBOUNDS Contructs the parameters and their bounds of a IDPROC model object.
%
%   [ParameterVector,MaxP,MinP,PNR,DNR,BNR] = PBOUNDS(MOD)
%
%   PNR are the numbers of the active parameters among all process par
%   DNR are the indices in ParVec which contain time delay parameters
%   BNR are the indices in ParVec with nontrivial  bounds


%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2004/04/10 23:17:12 $

dist = pvget(sys,'DisturbanceModel');

Typec = i2type(sys);

par = zeros(1,0);
pveci = [sys.Kp.min;sys.Tp1.min;sys.Tp2.min;sys.Tw.min;sys.Zeta.min;sys.Tp3.min;sys.Td.min;sys.Tz.min];
pveca = [sys.Kp.max;sys.Tp1.max;sys.Tp2.max;sys.Tw.max;sys.Zeta.max;sys.Tp3.max;sys.Td.max;sys.Tz.max];

[Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz,dmpar] = procpar(sys);%deal
procp = [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz]';
procp=procp(:);
dnr =[]; dnrnr = 1;
if ~isempty(Typec)
    
    if ~iscell(Typec),Typec={Typec};end
    for ku = 1:length(Typec)
        pl = length(par);
        Type =Typec{ku};
        type = Type;
        
        par(1+pl,1) = procp(1);
        
        pnr(1+pl,1) = 1+8*(ku-1);
        if  eval(Type(2))==0
            if any(Type=='D')
                par(2+pl,1) = procp(7);
                pnr(2+pl,1) = 7+8*(ku-1);
                dnr(dnrnr) = 2+pl;
                dnrnr = dnrnr+1;
            end
        elseif eval(Type(2))==1
            par(2+pl,1) = procp(2);
            pnr(2+pl,1) =2+8*(ku-1);
            if any(Type=='D')
                par(3+pl,1) = procp(7);
                pnr(3+pl,1) = 7+8*(ku-1);
                dnr(dnrnr) = 3+pl;
                dnrnr=dnrnr+1;
                if any(Type=='Z')
                    par(4+pl,1) = procp(8);
                    pnr(4+pl,1) = 8+8*(ku-1);
                end
            elseif any(Type=='Z')
                par(3+pl,1) = procp(8);
                pnr(3+pl,1) = 8+8*(ku-1);
            end
        elseif eval(Type(2))==2
            if any(Type=='U')
                par([2:3]+pl,1) = procp(4:5);
                pnr([2:3]+pl,1) = [4 5]'+8*(ku-1);
            else
                par([2:3]+pl,1) = procp(2:3);
                pnr([2:3]+pl,1) = [2 3]'+8*(ku-1);
            end
            if any(Type=='D')
                par(4+pl,1) = procp(7);
                pnr(4+pl,1) = 7+8*(ku-1);
                dnr(dnrnr) = 4+pl;
                dnrnr = dnrnr + 1;
                if any(Type=='Z')
                    par(5+pl,1) = procp(8);
                    pnr(5+pl,1) = 8+8*(ku-1);
                end
            elseif any(Type=='Z')
                par(4+pl,1) = procp(8);
                pnr(4+pl,1) = 8+8*(ku-1);
            end
        else % third order
            if any(Type=='U')
                par([2:3]+pl,1) = procp(4:5);
                pnr([2:3]+pl,1) = [4 5]'+8*(ku-1);
            else
                par([2:3]+pl,1) = procp(2:3);
                pnr([2:3]+pl,1) = [2 3]'+8*(ku-1);
            end
            par(4+pl,1) = procp(6);
            pnr(4+pl,1) = 6+8*(ku-1);
            if any(Type=='D')
                par(5+pl,1) = procp(7);
                pnr(5+pl,1) = 7+8*(ku-1);
                dnr(dnrnr) = 5+pl;
                dnrnr = dnrnr + 1;
                if any(Type=='Z')
                    par(6+pl,1) = procp(8);
                    pnr(6+pl,1) = 8+8*(ku-1);
                end
            elseif any(Type=='Z')
                par(5+pl,1) = procp(8);
                pnr(5+pl,1) = 8+8*(ku-1);
            end
        end
        if length(procp)>1
            procp = procp(9:end);
        end
    end
else % Type not specified
    disp('NU har jag kommit hit')
    type = 'P';
    if procp(3)~=0
        type(2)='2';
        par(2,1) = procp(2);
        par(3,1) = procp(3);
        nr=3;
    elseif procp(2)~=0
        par(2,1) = procp(2);
        type(2)='1';
        nr=2;
    else
        type(2)='0';
        nr = 1;
    end
    if procp(4)~=0
        type(3)='D';
        nrt = 3;
        nr=nr+1;
        par(nr,1) = procp(4);
    else
        nrt = 2;
    end
    if procp(5)~=0
        type(nrt+1)='Z';
        par(nr+1,1)=procp(5);
    end
end
if ~iscell(dist),dist ={dist};end
switch dist{1}
    case 'ARMA1'
        par = [par;0;0]; %%%v LLL Zeros
    case 'ARMA2'
        par = [par;zeros(4,1)];
end
type = Typec; % LL check
pveca=pveca(:);
maxp = pveca(pnr);
pveci = pveci(:);
minp = pveci(pnr);
bnr = find(minp>-inf|maxp<inf);
