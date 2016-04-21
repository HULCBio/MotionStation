% Called by PARSLSYS
% performs the lhs or rhs  parsing
% term = list of terms

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.8.2.3 $


function term=parslmi(hdl,lmi,nlmi,varlist,header)


term=[];
if nlmi>0, side='lhs'; else side='rhs'; end
if dblnk(lmi)=='0'; return; end


% construct smap such that
%------------------------
%  smap(j)=1 if the closest [ or ( char on the left of lmi(j) is a
%            bracket or if  the closest ] or ) char on the right
%            is a bracket
%  depth counts the level of nested [] or ()

depth=0; bool=0; openlist=0; j=0; smap=zeros(1,length(lmi));
for c=lmi,
  if any(c=='[('),
     depth=depth+1; bool=(c=='['); openlist(depth+1)=bool;
  elseif any(c=='])')
     bool=openlist(depth); depth=depth-1;
  end
  j=j+1; smap(j)=bool;
end

if depth~=0,
  str1=sprintf('Unmatched parentheses or brackets in LMI  #%d',nlmi);
  parslerr(hdl,str1); term='???'; return
end



% get rid of all blanks that are not block separators
% --------------------------------------------------

% eliminate all blanks that are not directly exposed to brackets
lmi=lmi(find(lmi~=' ' | smap));

% handle ambiguities with +/-
lmi=strrep(lmi,'+ ',' + ');
lmi=strrep(lmi,'- ',' - ');

% remove multiple blanks
lmi(find(filter([1 1],2,lmi==' ')==1))=[];
%lmi=lmi(find(lmi~=' ' | ['$' lmi(1:length(lmi)-1)]~=' '));

% remove blanks around operators
aux=(lmi=='*' | lmi=='\' | lmi=='/' | lmi==';' | lmi==',');
auxl=aux | (lmi=='[' | lmi=='(');              auxl=[0 auxl(1:length(lmi)-1)];
auxr=aux | (lmi==']' | lmi==')' | lmi=='''');  auxr=[auxr(2:length(lmi)) 0];
lmi=lmi(find(lmi~=' ' | ~(auxl | auxr)));

lmi=strrep(lmi,' + ','+');
lmi=strrep(lmi,' - ','-');
lmi=strrep(lmi,'0(','zeros(');
lmi=strrep(lmi,'1(','eye(');




% construct the depth map
%------------------------
%    dmap(j) counts the levels of nested () or [] around  lmi(j)

depth=0; j=0; dmap=zeros(1,length(lmi));
for c=lmi,
  depth=depth+any(c=='[(');
  j=j+1; dmap(j)=depth;
  depth=depth-any(c=='])');
end



% detect outer factors and isolate inner factor
% --------------------------------------------
ind0=find(dmap==0);
lmi0=lmi(ind0);
lel=length(lmi);

%%% v5 code
% added the isempty to prevent the empty matrix == scalar
% warning
if ~isempty(lmi0),
   if any(lmi0=='\' | lmi0=='/'),
     str1=sprintf('LMI #%d:',abs(nlmi));
     str1=[str1 ' \ and / only allowed inside parentheses'];
     parslerr(hdl,str1); term='???'; return
   end
end
imult=find(lmi=='*' & dmap==0);  % 0-depth multiplications

if isempty(lmi0),
  infac=lmi(2:lel-1);
  dmap=dmap(2:lel-1)-1;
elseif any(lmi0=='+' | lmi0=='-') | length(imult)~=2,
  infac=lmi;
else
  range=(imult(1)+1:imult(2)-1);

  if all(dmap(range))>0,
    lof=lmi(1:imult(1)-1);
    rof=lmi(imult(2)+1:lel);
    if strcmp(rof,[lof '''']) | strcmp(lof,[rof '''']),
      outdef=[header '[' num2str(nlmi) ' 0 0 0],' rof ');' ];
      outdef=[outdef blanks(max(5,48-length(outdef))) '% '];
      outdef=[outdef sprintf('LMI #%d: %s',abs(nlmi),rof)];
      term=strstack(term,outdef);
    else
      str1=sprintf([side ...
          ' of LMI #%d: use parentheses to group constant terms '],abs(nlmi));
      str2='and make outer factors transposed of one another';
      parslerr(hdl,str1,str2); term='???'; return
    end
    range=range(2:length(range)-1);
    infac=lmi(range); dmap=dmap(range)-1;
  else
    infac=lmi;
  end
end


% replace blank bloc separator by commas
infac=strrep(infac,' ',',');



% detect inversions
if any((infac=='/' | infac=='\') & dmap==0),
  str1='Use / and \ only in coefficients and write (A/B) instead';
  str2='of A/B';
  parslerr(hdl,str1,str2); term='???'; return
end


% look for separators
indr=find(infac==';' & dmap==0);
indc=find(infac==',' & dmap==0);
nrows=1+length(indr);
if rem(length(indc),nrows)~=0,
  str1=sprintf(['Bad block partitioning in the ' side ' of LMI #%d'],...
                                                abs(nlmi));
  parslerr(hdl,str1); term='???'; return
elseif round(length(indc)/nrows)+1~=nrows,
  str1=sprintf(['Non square inner factor in the ' side ' of LMI #%d'],...
                                                abs(nlmi));
  parslerr(hdl,str1); term='???'; return
end
sep=[0 sort([indr indc]) length(infac)+1];
nblck=length(sep)-1;


% main loop
% ---------

i=1; j=1; b=1;

while i<=nrows,

   blck=infac(sep(b)+1:sep(b+1)-1);
   bmap=dmap(sep(b)+1:sep(b+1)-1);
   cterm=[];

   while ~isempty(blck),

     % get terms one by one
     [t,tmap,blck,bmap]=parslblk(blck,bmap,'+-');

     tsave=t; sgn='+';  vflag=0;  % indicates variable term
     if t(1)=='-',
        t=t(2:length(t)); tmap=tmap(2:length(tmap)); sgn='-';
     end
     A=[];

     % decompose term
     while ~isempty(t),

        % get factors one by one
        [fact,fmap,t,tmap]=parslblk(t,tmap,'*');

        if max(fmap)==0,   % depth 0 term

          if ~isempty(findstr(varlist,...
                   [',' strrep(fact,'''','') ','])),
             vflag=1; var=fact; B=t; break
          else
             A=[A '*' fact];
          end
        else
          A=[A '*' fact];
        end
     end

     if ~isempty(A), A(1)=[]; end


     %  store term

     if ~vflag & ~strcmp(A,'0'),           % constant term

       cterm=[cterm sgn A];

     elseif vflag,                 % variable term

       if var(length(var))=='''', var=['-' var(1:length(var)-1)]; end
       tail=');'; tailc='';

       % handle diagonal terms
       if i==j,
         tt=trterm(A,[var ''''],B,sgn);
         k=strfind(blck,tt);

         if isempty(k) & ~(isempty(A) & isempty(B)),  % Watch for Q matching Q1!
           tt=trterm(A,var,B,sgn);
           k=strfind(blck,tt);
         end

         if ~isempty(k),    % conjugated pair
           lt=length(tt);
           if k>1, if blck(k-1)=='+', k=k-1; lt=lt+1; end,end
           blck(k:k+lt-1)=[]; bmap(k:k+lt-1)=[]; tail=',''s'');';
           if length(blck)>0, if blck(1)=='+'; blck(1)=[]; bmap(1)=[]; end,end
           if tt(1)=='-', tsave=[tsave tt]; else tsave=[tsave '+' tt]; end
         elseif ~strcmp(tsave,trterm(A,var,B,sgn)),
           if isempty(A), A='1'; end
           A=['.5*' A];   tail=',''s'');';  tailc=' (NON SYMMETRIC?)';
         end
       end


       if isempty(A), A='1'; end
       if isempty(B), B='1'; end
       if sgn=='-', B=['-' B]; end

       newt=[header '[' num2str(nlmi) ' ' num2str(i) ' ' ...
                              num2str(j) ' ' var '],' A ',' B tail];
       newt=[newt blanks(max(5,48-length(newt))) '% '];
       newt=[newt sprintf('LMI #%d: %s',abs(nlmi),tsave) tailc];
       term=strstack(term,newt);

    end
  end

  % store constant term
  if ~isempty(cterm),
     if cterm(1)=='+', cterm(1)=[]; end
     newt=[header '[' num2str(nlmi) ' ' num2str(i) ' ' ...
                              num2str(j) ' 0],' cterm ');'];
     newt=[newt blanks(max(5,48-length(newt))) '% '];
     newt=[newt sprintf('LMI #%d: %s',abs(nlmi),cterm)];
     term=strstack(term,newt);
  end


%  i=i+floor(j/nrows);
%  if j==nrows, j=i; else j=j+1; end
%  b=(i-1)*nrows+j;


  if j==i, i=i+1; j=1; else j=j+1; end
  b=(i-1)*nrows+j;

end



