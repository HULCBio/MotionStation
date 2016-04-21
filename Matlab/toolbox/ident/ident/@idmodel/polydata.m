function [a,b,c,d,f,da,db,dc,dd,df] = polydata(sys)
%POLYDATA computes the polynomials associated with a given model.
%   [A,B,C,D,F]=POLYDATA(MODEL)
%
%   MODEL is the model  as an  IDMODEL object
%
%   A,B,C,D, and F are returned as the corresponding polynomials
%   in the general input-output model. A, C and D are then row
%   vectors, while B and F have as many rows as there are inputs.
%
%   [A,B,C,D,F,dA,dB,dC,dD,dF]=POLYDATA(MODEL)
%   also returns the standard deviations of the estimated polynomials.
%
%   See also IDPOLY

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/10 23:17:34 $

[ny,nu]=size(sys);
if ny>1
    error('Polydata only handles Single-Output models.')
end
if nargout>5
    dum = idpoly(sys);
    try
        assignin('caller',inputname(1),sys) %%LL% only if poly hs been set
    catch
    end
    
    [num,den,dnum,dden]=tfdata(sys);
    [numn,denn,dnumn,ddenn]=tfdata(sys(:,'noise'));
    
else
    [num,den]=tfdata(sys(:,'allx9'));
    [numn,denn]=tfdata(sys(:,'noise'));
    
end
if nu>0
    a=den{1,1};
    if isempty(a), a = 1; end
    b=num{1,1};
    for ku=2:nu
        [ut,nb]=size(b);
        b1=num{1,ku};nb1=length(b1);
        b=[[b,zeros(ut,nb1-nb)];[b1,zeros(1,nb-nb1)]];
    end
    c = [];
    if ~isempty(numn)
        c = numn{1,1}; 
    end
    d=1;
    f=ones(nu,1);
else
    a = denn{1,1};
    b = [];
    c = numn{1,1};
    d =1;
    f =[];
end
if nargout>5
    da = []; db = []; dc = [];
    if nu>0
        if ~isempty(dden)
            da=dden{1,1};
        end
        if ~isempty(dnum)
            db=dnum{1,1};
            
            for ku=2:nu
                [ut,nb]=size(db);
                b1=dnum{1,ku};nb1=length(b1);
                db=[[db,zeros(ut,nb1-nb)];[b1,zeros(1,nb-nb1)]];
            end
            
            dc = dnumn{1,1}; 
        end
        dd=0;
        df=zeros(nu,1);
    else
        if ~isempty(ddenn)
            da=ddenn{1,1};
        end
        db = []; dd=[];df=[];
        if ~isempty(dnumn)
            dc=dnumn{1,1};
        end
        
    end
end
