function [str,val]=idmspop(nu,ny,val,dom,ts)
%IDMSPOP Returns the model structure popup string.
%   The string depends on the number of inputs and outputs

%   L. Ljung 9-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/10 23:19:27 $
if nargin<5
    ts=1;
end
if nargin<4
    dom = 't';
end
if nargin<3
    val = 1;
end
switch dom
    case 't'
        if nu>0
            if ny==1
                str=['ARX: [na nb nk]|ARMAX: [na nb nc nk]|',...
                        'OE: [nb nf nk]|BJ: [nb nc nd nf nk]|',...
                        'State Space: n [nk]|By Initial Model'];
            else
                str=['ARX: [na nb nk]|(ARMAX)|',...
                        '(OE)|(BJ)|',...
                        'State Space: n [nk]|By Initial Model'];
                if any(val==[2 3 4]);val = 5;end
            end
            
        else
            if ny==1
                str=['AR: [na]|ARMA: [na nc]|',...
                        '(OE)|(BJ)|',...
                        'State Space: (n)|By Initial Model'];
                if any(val==[3 4]),val=2;end
            else
                str=['AR: [na]|(ARMA)|',...
                        '(OE)|(BJ)|',...
                        'State Space: (n)|By Initial Model'];
                if any(val==[2 3 4]), val = 5;end
            end
        end
    case 'f'
        if ny>1
            if ts==0
                str = ['(ARX)|(ARMAX)|(OE)|(BJ)|State Space: n [nk]|By Initial Model'];
                if any(val==[1:4]),val=5;end
            else
                if nu==0
                str = ['ARX: [na nb nk]|(ARMAX)|(OE)|(BJ)|(State Space: n [nk])|By Initial Model'];
            if val>1,val=1;end    
            else
                str = ['ARX: [na nb nk]|(ARMAX)|(OE)|(BJ)|State Space: n [nk]|By Initial Model'];
                
            if any(val==[2 3 4]),val = 5;end
        end
            end
        else
            if nu==0
                 str = ['ARX: [na nb nk]|(ARMAX)|(OE)|(BJ)',...
                        '|(State Space)|By Initial Model'];
                if val>1,val=1;end
            else
            if ts>0
                str = ['ARX: [na nb nk]|(ARMAX)|OE: [nb nf nk]|(BJ)',...
                        '|State Space: n [nk]|By Initial Model'];
            else
                
                str = ['ARX: [na nb]|(ARMAX)|OE: [nb nf]|(BJ)',...
                        '|State Space: n [nk]|By Initial Model'];
            end
            if any(val==[2 4]),val = 3;end
        end
        end
end