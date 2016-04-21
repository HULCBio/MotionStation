function i3=pdesubix(i1,i2)
%PDESUBIX Find indices in index vector
%
%       I3=PDESUBIX(I1,I2) Returns I3 such that I1(I3)==I2.
%
%       It is assumed that I1 and I2 are both increasing or decreasing,
%       and that all elements of I2 are present in I1.

%       A. Nordmark 94-04-26
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:21 $


i3=[];
j=1;
i=1;
n=length(i1);
m=length(i2);
while j<=m,
  if i1(i)==i2(j),
    i3=[i3 i];
    j=j+1;
  end
  i=i+1;
end

