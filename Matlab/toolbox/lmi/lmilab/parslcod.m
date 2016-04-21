% CALLED BY LMIEDIT

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $

function [sysname,varname,vartype,varstruct,lmides]=...
                                  parslcod(hdl,stop,sbot)

% stop: setlmis/lmivar commands
% sbot: lmiterm/getlmis commands

caret=sprintf('\n');


% (1) process the variable definitions

varname=[]; vartype=[]; varstruct=[]; unnamed=[];
lmides = []; sysname = [];
buffer=[]; nvars=0;  nsets=0;
startV=0; % first j s.t. Vj is not a variable name

for line=stop',

  % handle % and ...
  line=dblnk(strtok(line,'%'))';
  if length(buffer), line=[buffer , ' ' , line]; buffer=[]; end
  idxx=findstr(line,'...');
  if length(idxx),
    buffer=line(1:idxx-1); line=[];
  elseif length(line)<8,
    line=[];
  end

  % build depth map
  depth=0; jjx=0; dmap=zeros(1,length(line));
  for char=line,
    depth=depth+any(char=='[(');
    jjx=jjx+1; dmap(jjx)=depth;
    depth=depth-any(char=='])');
  end
  if depth, parslerr(hdl,['Syntax error near ' line]); varname=[]; return, end

  % find command separator
  ixsep=find((line==',' | line==';') & ~dmap);
  if length(ixsep), line(ixsep)=setstr('$'*ones(1,length(ixsep))); end


  % process each command
  while length(line)>=8,

    if strcmp(line(1),'$'), line(1)=[]; end
    [command,line]=strtok(line,'$');

    % determine command type
    type=0;
    if length(command)<8, command=[]; end
    type=~isempty(findstr(command,'setlmis'));
    if ~type,
      type=~isempty(findstr(command,'lmivar'));
    else
      nsets=nsets+1; type=0;
    end

    if type,
      nvars=nvars+1; ktrack(nvars,1)=0;
      [args,command]=strtok(command,'=');

      % get var name
      if isempty(command), % no output args
        command=args; unnamed=[unnamed nvars]; vname=caret;
      elseif args(1)=='[',
        command=dblnk(command(2:length(command)));
        idxx=findstr(args,','); vname=dblnk(args(2:idxx(1)-1));
        eval([vname '=' num2str(nvars) ';']);
      else
        command=dblnk(command(2:length(command)));
        vname=dblnk(args); eval([vname '=' num2str(nvars) ';']);
      end

      % detect vars starting with V
      lvname=length(vname);
      if lvname>1, firstl=vname(1); else firstl='$'; end
      if firstl=='V',
        alldig=1;
        for char=vname(2:lvname), alldig=alldig & any(char=='0123456789'); end
        if alldig, startV=max(startV,eval(vname(2:lvname))); end
      end

      % store names
      varname=strstack(varname,[blanks(1) vname]);

      idxx=findstr(command,',');
      if ~length(idxx),
        parslerr(hdl,['Syntax error in command  ' command],...
                     'LMIVAR must have two arguments');
        varname=[]; return,
      end

      vtype=dblnk(command(8:idxx(1)-1));
      if ~any(vtype=='123'),
        parslerr(hdl,['Unknown variable type "' vtype '"']);varname=[];return
      elseif vtype=='1', vtype=' S';
      elseif vtype=='2', vtype=' R';
      elseif vtype=='3', vtype=' G'; end
      command=command(idxx(1)+1:length(command));
      idxx=findstr(command,')');
      vstruct=dblnk(command(1:idxx(length(idxx))-1));

      vartype=strstack(vartype,vtype);
      varstruct=strstack(varstruct,[blanks(1) vstruct]);
    end
  end % while
end % for


% name the unnamed vars
for who=unnamed,
  startV=startV+1;
  vname=[' X' num2str(startV)]; ldata=length(vname);
  eval([vname '=' num2str(who) ';']);
  shft=ktrack(who,1); ktrack(who,1)=shft+ldata;
  varname(who,1:ldata)=vname;
end

if ~nsets,
  parslerr(hdl,'The SETLMIS command is missing');varname=[];return
elseif nsets>1,
  parslerr(hdl,'Too many SETLMIS: ','Please specify one LMI system per file');
  varname=[]; return
end

if isempty(sbot),return,end




% (2) Process the LMI description

sysname=[]; lmides=[];
lmiblck=zeros(40,10);
Acoeff=setstr(' '*ones(80,10));
Bcoeff=setstr(' '*ones(40,10));
nlmis=0; ngets=0; ktrack=zeros(10,4); buffer=[];
% ktrack(j,1) : # blocks in LMI #j
% ktrack(j,2) : length of string lmiblck(:,j)
% ktrack(j,3) : same for Acoeff
% ktrack(j,4) : same for Bcoeff


for line=sbot',

  % handle % and ...
  line=dblnk(strtok(line,'%'))';
  if length(buffer), line=[buffer , ' ' , line]; buffer=[]; end
  idxx=findstr(line,'...');
  if length(idxx),
    buffer=line(1:idxx-1); line=[];
  elseif length(line)<8,
    line=[];
  end

  % build depth map
  depth=0; jjx=0; dmap=zeros(1,length(line));
  for char=line,
    depth=depth+any(char=='[(');
    jjx=jjx+1; dmap(jjx)=depth;
    depth=depth-any(char=='])');
  end
  if depth, parslerr(hdl,['Syntax error near  ' line],...
               'Unmatched parentheses or brackets');lmides=[];return, end

  % find command separator
  ixsep=find((line==',' | line==';') & ~dmap);
  if length(ixsep), line(ixsep)=setstr('$'*ones(1,length(ixsep))); end

  % process each command
  while length(line)>=7,

    if strcmp(line(1),'$'), line(1)=[]; dmap(1)=[]; end
    lline=length(line);
    [command,line]=strtok(line,'$');
    cmap=dmap(1:length(command));
    dmap=dmap(length(command)+1:lline);

    % determine type of command
    type=0;  if length(command)<7, command=[]; end
    type=2*(~isempty(findstr(command,'lmiterm')));
    if ~type, type=~isempty(findstr(command,'newlmi')); end
    if ~type, type=3*(~isempty(findstr(command,'getlmis'))); end


    if type==3,      % getlmis
      [args,rmdr]=strtok(command,'=');
      if isempty(rmdr),
        parslerr(hdl,'GETLMIS has no output argument');lmides=[];return
      end
      ngets=ngets+1;  sysname=[' ' dblnk(args)];

    elseif type==1,  % newlmi
      nlmis=nlmis+1;
      [args,rmdr]=strtok(command,'=');
      if ~isempty(rmdr),
         lminame=dblnk(args); eval([lminame '=' num2str(nlmis) ';']);
      end

    elseif type==2,  % lmiterm

      % get termid
      [xzxz,termid]=strtok(command,'[');
      [termid,termcoef]=strtok(termid,']');
      termcoef(1)=[]; cmap(1:length(command)-length(termcoef))=[];

      % evaluate termid
      termid=[termid ']']; undef=0;
      eval('termid=eval(termid);','undef=1;');
      if undef,
        parslerr(hdl,['Error in command  ' command ':'],...
                 'Term identifier cannot be evaluated');lmides=[];return
      elseif length(termid)~=4,
        parslerr(hdl,['Syntax error in  ' command ':'],...
           'the first argument must be a four-entry vector');lmides=[];return
      end


      % get coeffs
      idxx=find(termcoef==',' & cmap==1);  % argument separators
      if isempty(idxx),
        parslerr(hdl,['Syntax error in  ' command ':'],...
                'LMITERM must have at least two arguments');lmides=[];return
      end
      idxx=[idxx length(dblnk(termcoef))];
      range=idxx(1)+1:idxx(2)-1; cfA=pckterm(termcoef(range),cmap(range));
      if length(idxx)==2 & termid(4),
        parslerr(hdl,['Error in command  ' command ':'],...
                     'B coefficient is missing');lmides=[];return
      end
      if length(idxx)>2,
         range=idxx(2)+1:idxx(3)-1;
         cfB=pckterm(termcoef(range),cmap(range));
      else
         cfB=' ';
      end
      if length(idxx)>3, cfB=['$' cfB]; end

      % which LMI
      wlmi=abs(termid(1));
      if wlmi > nlmis, nlmis=wlmi; ktrack(4,nlmis)=0; end

      % store term data
      shft=ktrack(wlmi,2); ktrack(wlmi,2)=shft+4;
      lmiblck(shft+1:shft+4,wlmi)=termid';
      shft=ktrack(wlmi,3); ldata=length(cfA)+1; ktrack(wlmi,3)=shft+ldata;
      Acoeff(shft+1:shft+ldata,wlmi)=[caret;cfA(:)];
      shft=ktrack(wlmi,4); ldata=length(cfB)+1; ktrack(wlmi,4)=shft+ldata;
      Bcoeff(shft+1:shft+ldata,wlmi)=[caret;cfB(:)];

      % update # blocks in LMI "wlmi"
      ktrack(wlmi,1)=max([ktrack(wlmi,1) termid(2) termid(3)]);

    end % if
  end % while
end  % for

if ~ngets,
  parslerr(hdl,'The GETLMIS command is missing');lmides=[];return
elseif ngets>1,
  parslerr(hdl,'Too many GETLMIS: ','Please specify one LMI system per file');
  lmides=[];return
end



% (3) build the symbolic display

for wlmi=1:nlmis,

  nblcks=ktrack(wlmi,1);
  terms=lmiblck(1:ktrack(wlmi,2),wlmi);
  lcoeffs=dblnk(Acoeff(:,wlmi));
  rcoeffs=dblnk(Bcoeff(:,wlmi));
  lbkdes=zeros(nblcks^2,2);  % lengths of block descriptions
  loutf=[]; routf=[]; linfac=[]; rinfac=[];
  side=['linfac';'rinfac'];

  while ~isempty(terms),
    rhside=terms(1)<0; row=terms(2); col=terms(3); mvar=terms(4);
    terms(1:4)=[];
    [cfA,lcoeffs]=strtok(lcoeffs,caret);
    [cfB,rcoeffs]=strtok(rcoeffs,caret);
    varlb=abs(mvar);
    if varlb,
      vartransp=[(mvar<0) strcmp(dblnk(vartype(varlb,:)),'S')];
      mvar=dblnk(varname(varlb,:));
    end
    if ~row,  % outer factor
      if rhside,
        if isempty(routf), routf=cfA; else
        parslerr(hdl,sprintf('Too many right outer factors in LMI #%d',wlmi));
        lmides=[];return, end
      else
        if isempty(loutf), loutf=cfA; else
        parslerr(hdl,sprintf('Too many left outer factors in LMI #%d',wlmi));
        lmides=[];return, end
      end

    elseif row>=col,
      if varlb, term=mkterm(cfA,cfB,mvar,vartransp,0); else term=cfA; end
      sgn=(term(1)=='-'); cols=(col-1)*nblcks+row;
      shft=lbkdes(cols,1+rhside);
      if shft & ~sgn, term=['+';term]; end
      lterm=length(term); lbkdes(cols,1+rhside)=shft+lterm;
      eval([side(1+rhside,:) '(shft+1:shft+lterm,cols)=term;']);

    else  % reflect to lower diag
      if varlb, term=mkterm(cfA,cfB,mvar,vartransp,1);
      else term=pckterm(cfA); end
      cols=(row-1)*nblcks+col; shft=lbkdes(cols,1+rhside);
      if shft & ~sgn, term=['+';term]; end
      lterm=length(term); lbkdes(cols,1+rhside)=shft+lterm;
      eval([side(1+rhside,:) '(shft+1:shft+lterm,cols)=term;']);

    end
  end % while


  % build the matrix representation
  % (a) lhs
  zerlhs=0;
  lcols=max(reshape(lbkdes(:,1),nblcks,nblcks));
  if any(lcols),
    lcols=lcols+5; total=sum(lcols);
    lhs=setstr(' '*ones(total,nblcks));
    aux=nblcks; aux=linfac;
  else
    lhs=setstr(' '*ones(1,nblcks));
    lhs(1)='0'; aux=[]; zerlhs=1;
  end

  k=0; base=zeros(1,nblcks);
  for blck=aux,
    k=k+1; blck=dblnk(blck);
    i=rem(k,nblcks); if ~i, i=nblcks; end
    j=1+(k-i)/nblcks;
    if isempty(blck), if i>=j, blck='0'; else blck=('(*)')'; end, end
    lb=length(blck);
    pad=1+fix((lcols(j)-lb)/2);
    lhs(base(i)+pad+1:base(i)+pad+lb,i)=blck;
    base(i)=base(i)+lcols(j);
  end
  if ~zerlhs & nblcks > 1,
    lhs(1)='[';
    lhs(total,:)=[setstr(';'*ones(1,nblcks-1))  ']'];
  end

  % add outer factor
  if length(loutf) & ~zerlhs,
    lof=length(loutf);
    if strcmp(loutf(lof),''''), loutft=loutf(1:lof-1);
    else loutft=[loutf ; '''']; end
    if nblcks==1, lhs=['(' ; lhs ; ')']; end
    addleft=setstr(' '*ones(length(loutft)+2,nblcks));
    addleft(:,1)=[loutft ; '*' ; ' '];
    addright=setstr(' '*ones(lof+2,nblcks));
    addright(:,nblcks)=[' ' ; '*'; loutf];
    lhs=[addleft ; lhs ; addright];
  end


  % (a) rhs
  zerrhs=0;
  lcols=max(reshape(lbkdes(:,2),nblcks,nblcks));
  if any(lcols),
    lcols=lcols+5; total=sum(lcols);
    rhs=setstr(' '*ones(total,nblcks));
    aux=nblcks; aux=rinfac;
  else
    rhs=setstr(' '*ones(1,nblcks));
    rhs(nblcks)='0'; aux=[]; zerrhs=1;
  end

  k=0; base=zeros(1,nblcks);
  for blck=aux,
    k=k+1; blck=dblnk(blck);
    i=rem(k,nblcks); if ~i, i=nblcks; end
    j=1+(k-i)/nblcks;
    if isempty(blck), if i>=j, blck='0'; else blck=('(*)')'; end, end
    lb=length(blck);
    pad=1+fix((lcols(j)-lb)/2);
    rhs(base(i)+pad+1:base(i)+pad+lb,i)=blck;
    base(i)=base(i)+lcols(j);
  end
  if ~zerrhs & nblcks > 1,
    rhs(1)='[';
    rhs(total,:)=[setstr(';'*ones(1,nblcks-1))  ']'];
  end

  % add outer factor
  if length(routf) & ~zerrhs,
    rof=length(routf);
    if strcmp(routf(rof),''''), routft=routf(1:rof-1);
    else routft=[routf ; '''']; end
    if nblcks==1, rhs=['(' ; rhs ; ')']; end
    addleft=setstr(' '*ones(length(routft)+2,nblcks));
    addleft(:,1)=[routft ; '*' ; ' '];
    addright=setstr(' '*ones(rof+2,nblcks));
    addright(:,nblcks)=[' ' ; '*'; routf];
    rhs=[addleft ; rhs ; addright];
  end

  pad=setstr(' '*ones(nblcks,3));
  if zerlhs, pad(1,2)='<'; else pad(nblcks,2)='<'; end
  if nblcks==1 | zerlhs | zerrhs,
    lmides=strstack(strstack(lmides,[lhs' pad rhs']),' ');
  else
    lmides=strstack(strstack(lmides,[lhs' pad]),' ');
    pad=setstr(' '*ones(nblcks,min(size(lhs,1)+5,50-size(rhs,1))));
    lmides=strstack(strstack(lmides,[pad,rhs']),' ');
  end


end % for


lmides=[setstr(' '*ones(size(lmides,1),2)) lmides];


if strcmp(get(hdl(22),'str'),'Decoding in progress...'),
   set(hdl(21:23),'vis','off');
end
