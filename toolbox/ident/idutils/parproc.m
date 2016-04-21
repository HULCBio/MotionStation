function [par,type,pnr,dnr] = parproc(procp,Typec,dist)
%PARPROC Contructs the parameters of a IDPROC model object.
%
%   [ParameterVector,Typeout] = PARPROC(Parameters,Typein,DisturbanceModel)
%
%   Parameters contains [Kp,Tp1,Tp2,Td,Tz]  for the IDPROC object
%   and Typein is the Type property of this object. Typeout is
%   equal to Typein if the latter is specified, otherwise Typeout
%   is determined from the nonzero values of Parameters.
%   ParameterVector is the ParamterVector property of the IDPROC
%   object.
%
%   See also IDPROC/PROCPAR which is the inverse of PARPROC.  

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2004/04/10 23:18:43 $

if nargin<3
    dist = 'None';
end
if nargin<2
    Typec = [];
end
par = zeros(1,0);
procp = procp(:); %Detta hae fluttats ner
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
                dnr(dnrnr,:) = [2+pl,ku];
                dnrnr = dnrnr+1;
            end
        elseif eval(Type(2))==1
            par(2+pl,1) = procp(2);
            pnr(2+pl,1) =2+8*(ku-1);
            if any(Type=='D')
                par(3+pl,1) = procp(7);
                pnr(3+pl,1) = 7+8*(ku-1);
                dnr(dnrnr,:) = [3+pl,ku];
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
                dnr(dnrnr,:) = [4+pl,ku];
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
                dnr(dnrnr,:) = [5+pl,ku];
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

switch dist
    case 'ARMA1'
        par = [par;0;0]; %%%v LLL Zeros
    case 'ARMA2'
        par = [par;zeros(4,1)];
end
type = Typec; % LL check this
