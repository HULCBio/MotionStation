function NN=idarxstr(xstring)
%IDARXSTR Creates a matrix of arxorders based on a string definition
%   of multi model structures
%   XSTRING: A string containing a multimodel definition i ARX terms
%            like '[1:2 1:3 4]'
%   NN: The corresponding matrix, where each row is an ARX order
%       definition. In the example above:
%       NN = [1 1 4;1 2 4; 1 3 4;2 1 4;2 2 4; 2 3 4]
%   This works for multi input data.

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:22:32 $

err=0;
par=find(xstring=='['|xstring==']');
xstring(par)=setstr(' '*ones(length(par),1));
x=idstrip(xstring,'off');
[nn,dum]=size(x);
index=ones(1,nn);
for kk=1:nn
    te=deblank(x(kk,:));
    le=length(te);
    if te(1)==':',
      x(kk-1,1:length(deblank(x(kk-1,:)))+le)=[deblank(x(kk-1,:)),te];
      index(kk)=0;
    end
end
x=x(find(index==1),:);[nn,dum]=size(x);
index=ones(1,nn);
for kk=1:nn
    te=deblank(x(kk,:));
    le=length(te);
    if te(le)==':'
      x(kk+1,1:le+length(deblank(x(kk+1,:))))=[te,deblank(x(kk+1,:))];
      index(kk)=0;
    end
end
x=x(find(index==1),:);
[nn,dum]=size(x);
eval('NN=eval(x(1,:))'';','err=1;')
if err, NN=[];return,end
for kk=2:nn
	try
  n=eval(x(kk,:));
catch
  err=1;
end
  if err,NN=[];return,end
  ln=length(n);
  NM=[];[rNN,dum]=size(NN);
  for ll=1:ln
   NM=[NM;[NN,n(ll)*ones(rNN,1)]];
  end
  NN=NM;
end

if err,NN=[];end