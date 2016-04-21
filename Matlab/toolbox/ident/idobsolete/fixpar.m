function eta=fixpar(etaold,mat1,arg1,fixpar)
%FIXPAR   Fixes parameters in state-space and ARX model structures.
%   OBSOLETE function. Use IDSS and the structure matrices 'As', 'Bs', etc instead.
%   See HELP IDSS.
%
%   TH = FIXPAR(TH_OLD,MATRIX,ELEMENTS,PARAMETERVALUES)
%
%   TH : The new theta-matrix
%   TH_OLD: The old theta-matrix
%   MATRIX: What matrix to manipulate (one of 'A','B','C','D','K' or 'X0')
%   ELEMENTS: Which elements to manipulate; an n by 2 matrix, where   each
%   row contains the row- and column numbers of the elements in question.
%   If this argument is omitted, all elements in the matrix will be fixed.
%   PARAMETERVALUES: The values of the new, fixed parameters;a vector with
%   n entries. If this argument is omitted, the parameters will be fixed to
%   the values of the current estimates in TH_OLD.
%   If MATRIX is given the value 'A1', 'A2', etc or 'B0', 'B1' etc
%   the manipulations will be obtained in the corresponding matrix
%   in an ARX-structure, provided TH_OLD is defined as such.
%
%   Example: th1 = FIXPAR(th,'A',[3,1;2,2;1,3])
%
%   Note: FIXPAR works only on standard model structures originally
%   defined by MS2TH, ARX2TH or ARX; if TH_OLD is based on a user-
%   defined structure, you could obtain the same result with THINIT and by
%   using the 3rd argument in PEM.
%   See also ARX, ARX2TH, MS2TH, PEM, UNFIXPAR.

%   L. Ljung 10-4-90,3-13-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:37 $

if nargin < 2
   disp('Usage: THF = FIXPAR(TH,MATRIX)')
   disp('       THF = FIXPAR(TH,MATRIX,ELEMENTS,PARAMETER_VALUES)')
   disp('       MATRIX is one of ''A'', ''B'', ''C'', ''D'', ''K'', ''X0''.')
   disp('       or ''B0'', ''A1'', ''B1'', ''A2'', ''B2'', etc.')
   return
end

if nargin<4,fixpar='d'; deff=1;else deff=0;end
if nargin<3,arg1=[];end



if nargin==4,
   [npr,npc]=size(arg1);
   if ~isempty(arg1)&length(fixpar)~=npr,
   error(['The length of the new parameter vector does not match the',...
         ' number of matrix entries marked']),
end,
end

 switch class(etaold)
 case {'idarx','idpoly'}
    if isa(etaold,'idpoly')
       nc = pvget(etaold,'nc');nd = pvget(etaold,'nd');
       nf = pvget(etaold,'nf');
       if sum([nc nd nf])~=0
          error('Only IDPOLY models with nc=nd=nf=0 can be used in FIXPAR.')
       else
          etaold = idarx(etaold);
       end
    end
    eta = setpname(etaold);
    fixold = pvget(eta,'FixedParameter');
   Ss = mat1;
   if lower(Ss(1)) == 'a'
      Ss = ['-A',Ss(2:end)];
   else
      Ss(1) = upper(Ss(1));
      end
   if nargin<3
      pars = {[Ss,'*']};
   else
      pars = [];
      for kp=1:size(arg1,1)
         pars{kp} = [Ss,'(',int2str(arg1(kp,1)),',',int2str(arg1(kp,2)),')'];
      end
   end
   if nargin == 4
      pna = pvget(eta,'PName');
      par = pvget(eta,'ParameterVector');
      for k1 = 1:length(pars)
         pnr = strmatch(pars{k1},pna,'exact');
         par(pnr) = fixpar(k1);
      end
      eta = pvset(eta,'ParameterVector',par);
   end
   fixnew = union(pars,fixold);
   eta = pvset(eta,'FixedParameter',fixnew);
   case 'idss'
Ss = [mat1,'s'];
if nargin<3
   set(etaold,Ss,get(etaold,mat1));
else 
   ssm = get(etaold,Ss); sm = get(etaold,mat1);
   if nargin<4
      fixpar = [];
      for kk=1:size(arg1,1)
         fixpar = [fixpar;sm(arg1(kk,1),arg1(kk,2))];
      end
   end
   for kk=1:size(arg1,1);
      ssm(arg1(kk,1),arg1(kk,2)) = fixpar(kk);
   end
   set(etaold,Ss,ssm)
end
eta = etaold;

otherwise
   error('FIXPAR can be used only for IDSS and IDARX objects.')
end


