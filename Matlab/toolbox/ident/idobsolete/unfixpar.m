function eta=unfixpar(etaold,mat1,arg1)
%UNFIXPAR Unfixes parameters in state-space and ARX model structures.
%   OBSOLETE function. Use the structure matrices 'As', 'Bs', etc instead.
%   See HELP IDSS and IDPROPS IDSS.
%
%   TH = UNFIXPAR(TH_OLD,MATRIX,ELEMENTS)
%
%   TH : The new theta-matrix
%   TH_OLD: The old theta-matrix
%   MATRIX: What matrix to manipulate
%           (one of 'A','B','C','D','K' or 'X0')
%   ELEMENTS: Which elements to manipulate; an n by 2 matrix, where
%           each row contains the row- and column numbers of the elements
%           in question. If this argument is omitted, all elements in the
%           matrix will be unfixed.
%
%   Example: th1 = unfixpar(th,'A',[3,1;2,2;1,3]);
%
%   If MATRIX is given the value 'A1', 'A2', etc or 'B0', 'B1' etc
%   the manipulations will be obtained in the corresponding matrix
%   in an ARX-structure, provided TH_OLD is defined as such.
%
%   Note: UNFIXPAR works only on standard model structures
%   originally defined by MS2TH, ARX2TH or ARX; if TH_OLD is based on a
%   user-defined structure (by MF2TH), you must unfix it yourself
%   See also ARX, ARX2TH, MS2TH, FIXPAR, PEM, THSS.

%   L. Ljung 10-2-90,1-9-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:42 $

if nargin < 2
   disp('Usage: THU = UNFIXPAR(TH,MATRIX)')
   disp('       THU = UNFIXPAR(TH,MATRIX,ELEMENTS)')
   disp('       MATRIX is one of ''A'', ''B'', ''C'', ''D'', ''K'', ''X0''.')
   disp('       or ''B0'', ''A1'', ''B1'', ''A2'', ''B2'', etc.')
   return
end

if nargin<3, arg1=[];end
if ~(isa(etaold,'idss')|isa(etaold,'idarx'))
   error('FIXPAR only handles IDSS and IDARX models')
end
if isa(etaold,'idarx')
   % First find the names of the parameters to be unfixed.
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
   fixold = pvget(etaold,'FixedParameter');
   fixnew = setdiff(fixold,pars);
   eta = pvset(etaold,'FixedParameter',fixnew);
else
   
   Ss = [mat1,'s'];
   if nargin<3
      set(etaold,Ss,NaN*ones(size(get(etaold,Ss))));
   else 
      ssm = get(etaold,Ss);  
      for kk=1:size(arg1,1);
         ssm(arg1(kk,1),arg1(kk,2)) = NaN;
      end
      set(etaold,Ss,ssm)
   end
   eta = etaold;
   
end