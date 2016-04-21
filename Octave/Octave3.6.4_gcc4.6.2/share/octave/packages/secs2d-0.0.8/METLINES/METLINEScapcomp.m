function [C,L,Lii,LiI,LII,Dnodes,varnodes]=...
      METLINEScapcomp(imesh,epsilon,contacts)

##
##
## [C,L,Lii,LiI,LII,Dnodes,varnodes]=METLINEScapcomp(imesh,epsilon,contacts)
##
##

Ncontacts = length(contacts);
Nnodes = columns(imesh.p);
varnodes = [1:Nnodes];

for ii=1:Ncontacts
  Dnodes{ii}=Unodesonside(imesh,contacts{ii});
  varnodes = setdiff(varnodes,Dnodes{ii});
end

L = Ucomplap (imesh,epsilon);

for ii=1:Ncontacts
  Lii{ii} = L(Dnodes{ii},Dnodes{ii});
  LiI{ii} = L(Dnodes{ii},varnodes);
end
LII =  L(varnodes,varnodes);

for ii=1:Ncontacts
  for jj=ii:Ncontacts
    if ii==jj
      C(ii,jj)=sum(sum(Lii{ii}-LiI{ii}*(LII\(LiI{ii})')));
    else
      C(ii,jj)=sum(sum(-LiI{ii}*(LII\(LiI{jj})')));
    end
  end
end

for ii=1:4
  for jj=1:ii-1
    C(ii,jj)=C(jj,ii);
  end
end
