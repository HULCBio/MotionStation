function zpplot(zepo,sd,mode,ax)
%ZPPLOT Plots zeros and poles. Obsolete function when used on non-IDMODEL
%   objects.
%
%   See HELP IDMODEL/ZPPLOT or HELP IDMODEL/PZMAP.
 
%   L. Ljung 10-1-86, revised 7-3-87,8-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/10/18 23:52:09 $

if nargin<1
   disp('Usage: ZPPLOT(ZEPO)')
   disp('       ZPPLOT(ZEPO,SD,MODE,AXIS)')
   return
end
% Some initial tests on the input arguments
if nargin<4, ax=[];end
if nargin<3, mode=[];end
if nargin<2,sd=0;end, if isempty(sd),sd=0;end,if sd<0, sd=0;end
if length(sd)>1 mode=sd; sd=0;end
if isempty(ax),axdef=1; else axdef=0;end
if isempty(mode),mode='sub';end
mode=mode(1:3);
if mode=='sub',sbflag=1;else sbflag=0;end
[nzp,nc]=size(zepo);
if nzp<2
  disp('There are no zeros and poles.')
  return
end

if fix(nc/2)~=nc/2
  error('ZEPO should have an even number of columns')
end

%
coltest=get(0,'BlackandWhite');
if coltest(1:2)=='of',
   cols=get(gca,'colororder');
   if sum(cols(1,:))>1.5  
      colors=['y','m','c','r','g','b','w']; % Dark background
      eccol='w';
   else
      colors=['b','g','r','c','m','k','y']; % Light background
      eccol='k';
   end
else
   colors=['w','w','w','w','w','w','w'];
   eccol='w';
end
zsc=zepo;
if any(any(zsc==inf));ztemp=zsc(:);
ztemp(find(ztemp==inf))=zeros(length(find(ztemp==inf)),1);zsc(:)=ztemp;end
om=2.1*pi*[1:100]/100;
w=exp(om*sqrt(-1));

inputs1=zepo(1,:);
if abs(sum(sign(inputs1)))~=nc
disp(['WARNING: ZEPO contains a mixture of discrete and continuous models.',...
'\nPress a key to continue, C-c to abort']),pause,end
T=sign(inputs1(1));inputs1=abs(inputs1);zepo(1,:)=inputs1;
mo=fix(inputs1/1000);mmo=max(mo);
kko=[]; % The output indices
for k=[0:mmo],if length(find(mo==k))>0,kko=[kko k];end,end

for ko=kko+1
  inputs=inputs1-(ko-1)*1000;

  kki=[]; mi=max(inputs(find(inputs<20)));% The input indices
  mino=max(inputs(find(inputs>500 & inputs<520)));
  if isempty(mino) kiind=[1:mi];else kiind=[1:mi 501:mino];end
  for ki=kiind
      if length(find(inputs==ki))>0,kki=[kki ki];end
  end

  %newplot;
  space=[];
  sbcount = 0;
  if mode=='sub' & norm(kki-kki(1)*ones(1,length(kki)))>0,
      sbcount=1;
  end
  if mode=='sam',
     mm=max(max(abs(zsc(2:nzp,find((inputs)/60<1)))));
     m=ceil(mm);
     if T<0,
         mar=max(max(real(zsc(2:nzp,find((inputs)/60<1)))));
         mir=min(min(real(zsc(2:nzp,find((inputs)/60<1)))));
     end
  end
  for ki=kki
    inpc=find((inputs==ki) | (inputs==ki+20));
    insd=find((inputs==ki+60) | (inputs==ki+80));
    if sum(mode~='sam')>0,
       mm=max(max(abs([zsc(2:nzp,inpc)]))); m=ceil(mm);
       if T<0,
             mar=max(max(real([zsc(2:nzp,inpc)]))); 
             mir=min(min(real([zsc(2:nzp,inpc)]))); 
       end
    end


    if ~axdef m=ax; end
    if length(m)==1, m1=m;m(1)=-m1;m(2)=m1;m(3)=-m1;m(4)=m1;end
    if sbflag & sbcount>0,subplot(220+sbcount),end
    plot([m(1);m(2)],[m(3);m(4)],'.','Visible','off')
    axis(m)
    axis('square'),
    
    hold on
    if sum(mode~='sam')>0
       if ki<500 ,title(['OUTPUT # ',int2str(ko),'  INPUT # ',int2str(ki)])
       else title(['OUTPUT # ',int2str(ko),'  NOISE INPUT # ',int2str(rem(ki,500))])
       end
    else 
       text(0.3,1.03,...
          ['OUTPUT # ',int2str(ko),' INPUT # ',space,int2str(ki)],...
          'units','norm');
    space=[space,'  '];
    end

    if T>0,plot(w,eccol),end %The unit circle
    colcount=0.6;
    for k=inpc
        colcount=colcount+0.5;  if abs(colcount-8.1)<0.1,colcount=1.1;end
        colind=floor(colcount);
           %rem(count/2,7)+1;colind=fix(colind);count=count+1;
        if k+1>nc,sdpl=0;info=zepo(1,k)-1000*(ko-1);
        if info>500,info=info-500;end
        else info=zepo(1,k:k+1)-1000*(ko-1);if info(1,1)>500,info=info-500;end
        sdpl=((info(1,2)==info(1,1)+60)&sd>0);
        end
        if sdpl
           zp=zepo(2:nzp,k:k+1);
        else zp=zepo(2:nzp,k);
        end
        iz=find(abs(zp(:,1))<1/eps);
        if T>0,iz=find((abs(zp(:,1))>0)&(abs(zp(:,1))<1/eps));end
        if length(iz)>0
          if fix(info(1,1)/20)==0,
             mark1='o';mark2='-.';mark3='-';
          else 
             mark1='x';mark2=':';mark3='-';
          end
          mark1=[mark1,colors(colind)];
          mark2=[mark2,colors(colind)];
          mark3=[mark3,colors(colind)];
          plot(real(zp(iz,1)),imag(zp(iz,1)),mark1)
          if sdpl,zpsdpl(zp,sd,w,iz',mark2,mark3),end
        end
        if fix(info(1,1)/20)>0 & k~=inpc(length(inpc)), pause,end
    end
    if sbflag,sbcount=sbcount+1;
    if sbcount>4,sbcount=1;end,end
    if sum(mode~='sam')>0 ,hold off,end
    if ki~=kki(length(kki)),pause,end
end
if ko~=kko(length(kko))+1,pause,hold off,end
end

hold off

set(gcf,'NextPlot','replace');



%----


function zpsdpl(zepo,sd,w,iz,mark1,mark2)
%ZPSDPL Plots standard deviations in zero-pole plots.
%
%   zpsdpl(zepo,sd,w,iz,mark1,mark2)
%
%   This is a help function to zpplot.

for k=iz
    if imag(zepo(k,1))==0
    rp=real(zepo(k,1)+sd*zepo(k,2)*[-1 1]);
    [mr,nr] = size(rp);
    plot(rp,zeros(mr,nr),mark1)
    else if imag(zepo(k,1))>0
         r1=real(zepo(k,2));r2=imag(zepo(k,2));r3=zepo(k+1,2);
         p1=r1*r1;p2=r2*r2;p3=r3*r1*r2;
         SM=[p1 p3;p3 p2]; [V,D]=eig(SM); z1=real(w)*sd*sqrt(D(1,1));
         z2=imag(w)*sd*sqrt(D(2,2)); X=V*[z1;z2];
         X=[X(1,:)+real(zepo(k,1));X(2,:)+imag(zepo(k,1))];
         plot(X(1,:),X(2,:),mark2,X(1,:),-X(2,:),mark2)
         end
    end
end
