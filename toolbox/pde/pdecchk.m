function [nc,crows]=pdecchk(c)
%PDECCHK Checks PDE equation's c coefficient string matrix.
%       [NC,CROWS]=PDECCHK(C) takes the coefficient string matrix C
%       and returns the correct c expression as a string matrix
%       CROWS with 1, 2, 3, or 4 rows (scalar); or with 1, 2, 3, 4, 6,
%       8, 10, or 16 rows (system). The number of rows is returned in NC.

%       Magnus Ringh 12-28-94, MR 10-03-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:24 $

if ~ischar(c)
  error('PDE:pdecchk:InputNotStringMtrx', 'c must be a string matrix.');
end
if size(c,1)==1,
  scalar=1;
elseif size(c,1)==4,
  scalar=0;
else
  error('PDE:pdecchk:NumRowsC', 'c must have one or four rows.');
end

err=0;
if scalar,
  crows=pdebsplit(c);
  nc=size(crows,1);
else
  % First parse the rows in c:
  c1=pdebsplit(c(1,:));
  c2=pdebsplit(c(2,:));
  c3=pdebsplit(c(3,:));
  c4=pdebsplit(c(4,:));

  nc1=size(c1,1);
  nc2=size(c2,1);
  nc3=size(c3,1);
  nc4=size(c4,1);

  nc=max([nc1 nc2 nc3 nc4]);
  if nc==1,
    cval2=eval(c2,'NaN');
    cval3=eval(c3,'NaN');
    if cval2==0 & cval3==0,
      if strcmp(c1,c4)
        % they're all the same
        % case: 1
        crows=c1;
        nc=1;
        return;
      else
        % case: N, need to expand to 3*N=6
        crows=str2mat(c1,'0',c1,c4,'0',c4);
        nc=6;
        return;
      end
    else
      tmp=str2mat(c1,'0','0',c1,c2,'0','0',c2);
      crows=str2mat(tmp,c3,'0','0',c3,c4,'0','0',c4);
      nc=16;
      return;
    end
  elseif nc==2,
    if nc2==1,
      cval2=eval(c2,'NaN');
    else
      cval2=eval(c2(1,:),'NaN');
      if cval2==0,
        cval2=eval(c2(2,:),'NaN');
      end
    end
    if nc3==1,
      cval3=eval(c3,'NaN');
    else
      cval3=eval(c3(1,:),'NaN');
      if cval3==0,
        cval3=eval(c3(2,:),'NaN');
      end
    end
    if nc1==1,
      c1=[c1; c1];
    end
    if nc4==1,
      c4=[c4; c4];
    end
    if cval2==0 & cval3==0,
      if strcmp(c1,c4)
        % case 2
        crows=c1;
        nc=2;
        return;
      else
        % case 2*N, need to expand to 3*N=6
        crows=str2mat(c1(1,:),'0',c1(2,:),c4(1,:),...
            '0',c4(2,:));
        nc=6;
        return;
      end
    else
      if nc2==1,
        c2=[c2; c2];
      end
      if nc3==1,
        c3=[c3; c3];
      end
      tmp=str2mat(c1(1,:),'0','0',c1(2,:),c2(1,:),...
          '0','0',c2(2,:));
      crows=str2mat(tmp,c3(1,:),'0','0',c3(2,:),c4(1,:),...
          '0','0',c4(2,:));
      nc=16;
      return;
    end
  elseif nc==3,
    if nc2==1,
      cval2=eval(c2,'NaN');
    elseif nc2==2,
      cval2=eval(c2(1,:),'NaN');
      if cval2==0,

        cval2=eval(c2(2,:),'NaN');
      end
    elseif nc2==3,
      cval2=eval(c2(1,:),'NaN');
      if cval2==0,
        cval2=eval(c2(2,:),'NaN');
      end
      if cval2==0
        cval2=eval(c2(3,:),'NaN');
      end
    end
    if nc3==1,
      cval3=eval(c3,'NaN');
    elseif nc3==2,
      cval3=eval(c3(1,:),'NaN');
      if cval3==0,
        cval3=eval(c3(2,:),'NaN');
      end
    elseif nc3==3,
      cval3=eval(c3(1,:),'NaN');
      if cval3==0,
        cval3=eval(c3(2,:),'NaN');
      end
      if cval3==0
        cval3=eval(c3(3,:),'NaN');
      end
    end
    if nc1==1,
      c1=str2mat(c1,'0',c1);
    elseif nc1==2,
      c1=str2mat(c1(1,:),'0',c1(2,:));
    end
    if nc4==1,
      c4=str2mat(c4,'0',c4);
    elseif nc4==2,
      c4=str2mat(c4(1,:),'0',c4(2,:));
    end
    if cval2==0 & cval3==0,
      if strcmp(c1,c4)
        % case 3
        crows=c1;
        nc=3;
        return;
      else
        % case 3*N
        crows=str2mat(c1,c4);
        nc=6;
        return;
      end
    else
      if nc2==1,
        c2=str2mat(c2,'0',c2);
      elseif nc2==2,
        c2=str2mat(c2(1,:),'0',c2(2,:));
      end
      if nc3==1,
        c3=str2mat(c3,'0',c3);
      elseif nc3==2,
        c3=str2mat(c3(1,:),'0',c3(2,:));
      end
      tmp=str2mat(c1(1,:),c1(2,:),c1(2,:),c1(3,:),c2(1,:),...
          c2(2,:),c2(2,:),c2(3,:));
      crows=str2mat(tmp,c3(1,:),c3(2,:),c3(2,:),c3(3,:),...
          c4(1,:),c4(2,:),c4(2,:),c4(3,:));
      nc=16;
      return;
    end
  elseif nc==4,
    if nc2==1,
      cval2=eval(c2,'NaN');
    elseif nc2==2,
      cval2=eval(c2(1,:),'NaN');
      if cval2==0,
        cval2=eval(c2(2,:),'NaN');
      end
    elseif nc2==3,
      cval2=eval(c2(1,:),'NaN');
      if cval2==0,
        cval2=eval(c2(2,:),'NaN');
      end
      if cval2==0
        cval2=eval(c2(3,:),'NaN');
      end
    elseif nc2==4,
      cval2=eval(c2(1,:),'NaN');
      if cval2==0,
        cval2=eval(c2(2,:),'NaN');
      end
      if cval2==0
        cval2=eval(c2(3,:),'NaN');
      end
      if cval2==0
        cval2=eval(c2(4,:),'NaN');
      end
    end
    if nc3==1,
      cval3=eval(c3,'NaN');
    elseif nc3==2,
      cval3=eval(c3(1,:),'NaN');
      if cval3==0,
        cval3=eval(c3(2,:),'NaN');
      end
    elseif nc3==3,
      cval3=eval(c3(1,:),'NaN');
      if cval3==0,
        cval3=eval(c3(2,:),'NaN');
      end
      if cval3==0
        cval3=eval(c3(3,:),'NaN');
      end
    elseif nc3==4,
      cval3=eval(c3(1,:),'NaN');
      if cval3==0,
        cval3=eval(c3(2,:),'NaN');
      end
      if cval3==0
        cval3=eval(c3(3,:),'NaN');
      end
      if cval3==0
        cval3=eval(c3(4,:),'NaN');
      end
    end
    if nc1==1,
      c1=str2mat(c1,'0','0',c1);
    elseif nc1==2,
      c1=str2mat(c1(1,:),'0','0',c1(2,:));
    elseif nc1==3,
      c1=str2mat(c1(1,:),c1(2,:),c1(2,:),c1(3,:));
    end
    if nc4==1,
      c4=str2mat(c4,'0','0',c4);
    elseif nc4==2,
      c4=str2mat(c4(1,:),'0','0',c4(2,:));
    elseif nc4==3,
      c4=str2mat(c4(1,:),c4(2,:),c4(2,:),c4(3,:));
    end
    if cval2==0 & cval3==0,
      if strcmp(c1,c4)
        % case 4
        crows=c1;
        return;
      else
        % case 4*N
        crows=str2mat(c1,c4);
        nc=8;
        return;
      end
    else
      if nc2==1,
        c2=str2mat(c2,'0','0',c2);
      elseif nc2==2,
        c2=str2mat(c2(1,:),'0','0',c2(2,:));
      elseif nc2==3,
        c2=str2mat(c2(1,:),c2(2,:),c2(2,:),c2(3,:));
      end
      if nc3==1,
        c3=str2mat(c3,'0','0',c3);
      elseif nc3==2,
        c3=str2mat(c3(1,:),'0','0',c3(2,:));
      elseif nc3==3,
        c3=str2mat(c3(1,:),c3(2,:),c3(2,:),c3(3,:));
      end
      crows=str2mat(c1,c2,c3,c4);
      nc=16;
      return;
    end
  end
end

