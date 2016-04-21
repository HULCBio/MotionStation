function guess = Usmoothguess(mesh,new,old,Dsides);

% guess = Usmoothguess(mesh,new,old,Dsides);

  if ~isfield("mesh","wjacdet")
    mesh = Umeshproperties(mesh);
  end

  Nelements = columns(mesh.t);
  Nnodes = columns(mesh.p);

  Dnodes = Unodesonside(mesh,Dsides);
  varnodes = setdiff([1:Nnodes]',Dnodes);
  guess = new;

  A = Ucomplap(mesh,ones(Nelements,1));
  Aie = A(varnodes,Dnodes);
  Aii = A(varnodes,varnodes);

  guess(varnodes) = Aii\(-Aie*(new(Dnodes)-old(Dnodes))+Aii*old(varnodes));
