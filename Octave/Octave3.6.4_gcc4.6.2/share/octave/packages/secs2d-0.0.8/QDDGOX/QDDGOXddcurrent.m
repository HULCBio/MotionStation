function [current,divrg]=QDDGOXddcurrent(mesh,Sinodes,data,contacts,options);

% [current,divrg]=QDDGOXddcurrent(mesh,Sinodes,data,contacts);
constants
Nelements = size(mesh.t,2);


mob = Ufielddepmob(mesh,data.un,data.Fn,data.vsatn,data.mubn);

if (~isfield("options","FD")|(options.FD==0))
data.FDn=0;
data.FDp=0;
end

An  = Uscharfettergummel(mesh,data.V(Sinodes)+data.G+data.FDn,mob);

if (options.holes==1)
mob = Ufielddepmob(mesh,data.up,data.Fp,data.vsatp,data.mubp);
Ap  = Uscharfettergummel(mesh,-data.V(Sinodes)-data.Gp-data.FDp,mob);
divrg     = An * data.n + Ap * data.p;
else
divrg     = An * data.n;
end

for con = 1:length(contacts)

    cedges = [];
    cedges=[cedges,find(mesh.e(5,:)==contacts(con))];
    cnodes = mesh.e(1:2,cedges);
    cnodes = [cnodes(1,:) cnodes(2,:)];
    cnodes = unique(cnodes);

    current(con) = sum(divrg(cnodes));

end

Is = q*data.us*data.Vs*data.ns;
current = current * Is;

