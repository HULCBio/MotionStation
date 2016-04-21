function [bas,ib,il,iter,tab]=dantzgmp(a,bv,ibo,ilo);

% DANTZGMP Solve quadratic program.
% 	[bas,ib,il,iter,tab]=dantzgmp(tabi,basi,ibi,ili)
%
% Inputs:
%  tabi      : initial tableau
%  basi      : initial basis
%  ibi       : initial setting of ib
%  ili       : initial setting of il
%
% Outputs:
%  bas       : final basis vector
%  ib        : index vector for the variables -- see examples
%  il        : index vector for the lagrange multipliers -- see examples
%  iter      : iteration counter
%  tab       : final tableau

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $


tab=a;bas=bv;ib=ibo;il=ilo;
[m,n]=size(tab);

% check initial feasibility

if any(bas(ib(find(ib > 0))) < 0)
   error('Initial QP basis infeasible')
end

%
%  main loop for QP solution procedure.  Will give up after a maximum of
%  200 iterations.  This might have to be increased for really tough problems.
%

istand=0;
indxs=[1:m];
for iter=1:200
    if istand == 0
        igz=find(il>0);
        [basmin,i]=min(bas(il(igz)));
        if basmin >= 0
            return
        end
        i=igz(i) ;
        iad=i ;
        ichk=il(i) ;
        ichki=i+n ;
        ic=-ib(iad) ;
    else
        iad=istand;
        ic=-il(istand-n);
    end
    ibgz=find(ib > 0);
    if isempty(ibgz)
        irgez=[];
    else
        irtest=ib(ibgz);
        test=tab(irtest,ic);
        btest=bas(irtest);
        itnz=find(test ~= 0);
        if isempty(itnz)
			irgez=[];
		else
            rat=btest(itnz)./test(itnz);
            irgez=find( (rat > 0)  |  ((rat == 0) & (test(itnz) > 0)) );
		end
    end
    if isempty(irgez)
       ir=0;
       rmin=-1;
    else
       [rmin,i]=min(rat(irgez));
       i=ibgz(itnz(irgez(i)));
       ir=ib(i);
       iout=i;
    end
    if tab(ichk,ic) ~= 0
        rat=bas(ichk)/tab(ichk,ic);
        if rat >= 0 & (ir == 0 | rat <= rmin)
            ir=ichk;
            iout=ichki;
        end
    end
    if ir == 0
        iter=-iter;
        return
    end
    if iout <= n
        ib(iout)=-ic;
    else
        il(iout-n)=-ic;
    end,
    if iad > n
        il(iad-n)=ir;
    else
        ib(iad)=ir;
    end

%         Start of procedure that switches basis variables

    ipiv=1/tab(ir,ic);
    tab(ir,:)=tab(ir,:)*ipiv;
    temp=bas(ir)*ipiv;
    bas=bas-temp*tab(:,ic);
    bas(ir)=temp;
    tab(ir,ic)=0;
    tab=tab-tab(:,ic)*tab(ir,:);
    tab(:,ic)=-ipiv*tab(:,ic);
    tab(ir,ic)=ipiv;

%          end of switching procedure

%  See if we have a standard basis

    ibgz=find(ib > 0);
    if any(il(ibgz) > 0)
       istand=iout+n;
    else
       istand=0;
    end
end

% end of function DANTZGMP.M
