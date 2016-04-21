function pdesetlb(label,col)
%PDESETLB Set object label and update OBJNAMES matrix.
%       PDESETLB(LABEL,COL) sets column COL in the OBJNAMES matrix
%       (a property of the PDETOOL figure) to LABEL and updates the
%       set formula string in PDETOOL.

%       Magnus G. Ringh 11-15-94
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:57 $


pde_fig=findobj(allchild(0),'flat','Tag','PDETool');
objmtx=getappdata(pde_fig,'objnames');
evalhndl=findobj(allchild(pde_fig),'flat','Tag','PDEEval');
evalstr=get(evalhndl,'String');

[n,m]=size(objmtx);
l=length(label);
if col==m+1,
  % case: new label
  objmtx(1:l,col)=label';
  if m==0,
    evalstr=label;
  else
    evalstr=[evalstr '+' label];
  end
elseif col<=m,
  % case: replace existing label
  oldlabel=deblank(char(objmtx(:,col)'));
  if l<n
    mtxlabel=[label blanks(n-l)];
    ll=n;
  else
    mtxlabel=label;
    ll=l;
  end
  objmtx(1:ll,col)=mtxlabel';
  rp=findstr(evalstr, oldlabel);
  if length(rp)>1,                      % there may be a: 'R1+R11+R111' situation
    rp=findstr(evalstr, [oldlabel '+']);
    if isempty(rp),
      rp=findstr(evalstr, [oldlabel '-']);
      if isempty(rp),
        rp=findstr(evalstr, [oldlabel ')']);
        if isempty(rp),
          rp=findstr(evalstr, [oldlabel '*']);
          if isempty(rp),
            rp=findstr(evalstr, oldlabel);
            rp=max(rp);
          end
        end
      end
    end
  end
  ol=length(oldlabel);
  evalstr=[evalstr(1:rp-1) label evalstr(rp+ol:length(evalstr))];

else

  error('PDE:pdesetlb:ColNum', 'Column number is incorrect.')
  return;

end

setappdata(pde_fig,'objnames',objmtx)
set(evalhndl,'String',evalstr,'UserData',evalstr)

