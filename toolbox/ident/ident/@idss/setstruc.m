function setstruc(m,a,b,c,d,k,x0)
%SETSTRUC Function to set Structure matrices in IDSS model objects.
%
%   SETSTRUC(M,An,Bn,Cn,Dn,Kn,X0n)
%   
%   Same as SET(M,'As',An,'Bs',Bn,'Cs',Cn,'Ds',Dn,'Ks',Kn,'X0s',X0n)
%   Use empty matrices for those structure matrices that should not be changed.
%   Trailing arguments may be omitted.
%
%   An alternaive syntax is
%
%   SETSTRUC(M,ModStruc)
%
%   where ModStruc is a structure with fieldnames As, Bs, etc, 
%   and values An, Bn etc.
%   ModStruc need not have all the fieldnames above.
%
%   See also IDSS and IDPROPS IDSS.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $ $Date: 2004/04/10 23:18:14 $


if nargin <2
	disp('Usage: SETSTRUC(M,A,B,C,D,K,X0)')
	disp('       SETSTRUC(M,struc)')
	return
end
kc = 1;
if isstruct(a)
	fn = fieldnames(a);
 
	for kn = 1:length(fieldnames(a))
		
		fi = fn{kn};
	val = getfield(a,fi);
	fi(1)=upper(fi(1));
	if ~any(strcmp(fi,{'As','Bs','Cs','Ds','Ks','X0s'}))
		error(spintf(['The fields of the model structure must be',...
				'\n''As'', ''Bs'',''Cs'',''Ds'',''Ks'', and/or ''X0s''']))
	end
	var(kc)={fi};
		kc=kc+1;
		var(kc)={val};
		kc=kc+1;
	end
else
	if nargin < 7
		x0=[];
	end
	if nargin < 6
		k =[];
	end
	if nargin < 5
		d = [];
	end
	if nargin < 4
		c = [];
	end
	if nargin < 3
		b = [];
	end
	if ~isempty(a)
      var(kc)={'As'};
	  var(kc+1)= {a};
	  kc = kc+2;
  end
  if ~isempty(b)
	  var(kc) = {'Bs'};
	  var(kc+1) = {b};
	  kc=kc+2;
  end
  if ~isempty(c)
	  var(kc) = {'Cs'};
	  var(kc+1) = {c};
	  kc=kc+2;
  end
  if ~isempty(d)
	  var(kc) = {'Ds'};
	  var(kc+1) = {d};
	  kc=kc+2;
  end
  if ~isempty(k)
	  var(kc) = {'Ks'};
	  var(kc+1) = {k};
	  kc=kc+2;
  end
  if ~isempty(x0)
	  var(kc) = {'X0s'};
	  var(kc+1) = {x0};
	  kc=kc+2;
  end
end
  m = pvset(m,var{:});
  assignin('caller',inputname(1),m)
  