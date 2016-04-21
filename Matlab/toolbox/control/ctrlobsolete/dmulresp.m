function [iu,nargs,y,y2]=dmulresp(fun,a,b,c,d,Ts,t,nargo,bodeflag);
%DMULRESP Discrete multivariable response.
%
%   [IU,NARGS,Y,Y2] = DMULRESP('fun',A,B,C,D,Ts,T,NARGO,BODEFLAG)

%   Andy Grace  7-9-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:33:59 $

[r,m]=size(d);
if r*m>1    % MIMO system
   iu=0;
   if nargo==0
    clf
    hold off
    if r*m==2, sp=210; else sp=220; end
    if r*m>4|bodeflag==1, disp('Strike any key after each screen'), end
    scnt=0;
    for i=1:m
        if bodeflag==0,
          for j=1:r
            if scnt==4, pause, clf, scnt=0; end
            scnt=scnt+1; subplot(sp+scnt)
            if ~isempty(c), cj = c(j,:); end
            if ~isempty(d), dj = d(j,:); end
            eval([fun,'(a,b,cj,dj,Ts,i,t)']);
            title(sprintf('Input %d Output %d',i,j));
          end
        else 
          if scnt==4, pause, clf, scnt=0; end
          scnt = scnt+4;
          eval([fun,'(a,b,c,d,Ts,i,t)']);
          title(sprintf('Input %d',i))
        end
    end
    subplot(111)
  else
    y=[]; y2=[];
    for i=1:m
% Force compile to recognize these variables:
        phase =[];  mag = [];
        if bodeflag==0
            eval(['y=[y,',fun,'(a,b,c,d,Ts,i,t)];'])
        else
            eval(['[mag,phase]=',fun,'(a,b,c,d,Ts,i,t);'])
            y=[y,mag]; y2=[y2,phase];
        end

    end
  end
else        % SISO systems
  iu=1; nargs=5;
end


    
