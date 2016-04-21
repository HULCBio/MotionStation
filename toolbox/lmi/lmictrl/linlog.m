%  linlog(a,b,c,d,frqs)
%
%  Plots the linlog  Nyquist contour of a SISO system
%                               -1
%          G(s) = D + C (sI - A)  B

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.8.2.3 $

function linlog(a,b,c,d,frqs)


if size(d)~=[1 1],
  error('LinLog Nyquist plot only for SISO systems');
end

[n,d]=ss2tf(a,b,c,d);

if nargin==5,
  [mag,phase,w]=bode(n,d,frqs');
else
  [mag,phase,w]=bode(n,d,logspace(-2,2,50)');
end


% make contour smooth

dp=abs(diff(phase));
iter=0;


while max(dp) > 5 & iter < 7,
  ind=find(dp > 5);
  for i=fliplr(ind'),
    addw=logspace(log10(w(i)),log10(w(i+1)),10);
    [addmag,addphase]=bode(n,d,addw);
    addphase=addphase+(phase(i)-addphase(1));
    w=[w(1:i);addw';w(i+1:length(w))];
    mag=[mag(1:i);addmag;mag(i+1:length(mag))];
    phase=[phase(1:i);addphase;phase(i+1:length(phase))];
  end
  dp=abs(diff(phase)); iter=iter+1;
end



ind=find(mag > 1);
mag(ind)=1+log10(mag(ind));
phase=pi/180*phase;
re=mag.*cos(phase);
im=mag.*sin(phase);



% plot contour

xmin=min(re); xmax=max(re);
if abs(xmin-round(xmin)) <.2, xmin=round(xmin)-.5; else xmin=floor(xmin); end
if abs(xmax-round(xmax)) <.2, xmax=round(xmax)+.5; else xmax=ceil(xmax); end
ymin=min(im); ymax=max(im);
if abs(ymin-round(ymin)) <.2, ymin=round(ymin)-.5; else ymin=floor(ymin); end
if abs(ymax-round(ymax)) <.2, ymax=round(ymax)+.5; else ymax=ceil(ymax); end
if abs(xmin)<1, xmin=sign(xmin); end
if abs(xmax)<1, xmax=sign(xmax); end
if abs(ymin)<1, ymin=sign(ymin); end
if abs(ymax)<1, ymax=sign(ymax); end


plot(re,im);
set(gca,'xlim',[xmin xmax],'ylim',[ymin ymax],...
        'xtick',[ceil(xmin):floor(xmax)],...
        'ytick',[ceil(ymin):floor(ymax)]);
grid
title('Lin-Log Nyquist plot');
xlabel('Real Axis');
ylabel('Imag Axis');
text(re(1)-.3,im(1)+.3,['f=' num2str(w(1))]);
lw=length(w);
text(re(lw)-.3,im(lw)-.3,['f=' num2str(w(lw))])


% reset tick marks

xticks=get(gca,'xticklabel'); cs=size(xticks,2);
for i=1:size(xticks,1);
  t=xticks(i,:); tval=str2num(t);
  if tval~=0,
     if tval<0,
        str=num2str(-tval-1);
        xticks(i,1:cs+2)=['-1e' str blanks(cs-1-length(str))];
     else
        str=num2str(tval-1);
        xticks(i,1:cs+2)=['1e' str blanks(cs-length(str))];
     end
  end
end
yticks=get(gca,'yticklabel'); cs=size(yticks,2);
for i=1:size(yticks,1);
  t=yticks(i,:); tval=str2num(t);
  if tval~=0,
     if tval<0,
        str=num2str(-tval-1);
        yticks(i,1:cs+2)=['-1e' str blanks(cs-1-length(str))];
     else
        str=num2str(tval-1);
        yticks(i,1:cs+2)=['1e' str blanks(cs-length(str))];
     end
  end
end
set(gca,'xticklabel',xticks,'yticklabel',yticks);
