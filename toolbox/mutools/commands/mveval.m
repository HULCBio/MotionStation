% function [out1,out2,out3,...] = mveval(name,mask,in1,in2,in3,...)
%
%   Works like MATLAB FEVAL, but on collections of VARYING and
%   CONSTANT/SYSTEM matrices. NAME is a character string with
%   the name of a MATLAB function (user written, or MATLAB
%   supplied).  The function is applied to each input argument
%   at the INDEPENDENT VARIABLE's values. Any CONSTANT/SYSTEM
%   matrices are held at their value while the sweep through
%   INDEPENDENT VARIABLE is done. Currently limited to 10
%   output arguments, and an unlucky 13 input arguments, which
%   is easily changeable. VEVAL can be used to easily generate
%   VARYING system matrices.
%
%   See also: EVAL, FEVAL, VEBE, and VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [out1,out2,out3,out4,out5,out6,out7,out8,out9,out10] =...
mveval(name,mask,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13)

 if nargin == 0
   disp('usage: [out1,out2,out3,...] = mveval(name,mask,in1,in2,in3,in4,...)')
   return
 end

 nin = nargin - 2;	% CHANGED due to additional MASK input
 nout = nargout;

 if nargout == 0
   nout = 0;
 end

 coldata = [];
 rowdata = [];
 typedata = [];
 varyflg = 0;
 for j=1:nin
   eval(['[mtype,mrows,mcols,mnum] = minfo(in' int2str(j) ');']);
     typedata = [typedata;mtype];
     if mtype == 'vary'
       if mask(j) > 0		% CHANGED
         rowdata = [rowdata mrows];
         coldata = [coldata mcols];
         if varyflg == 0
           firstvary = j;
           nindv = mnum;
           eval(['indv = getiv(in' int2str(j) ');']);
           varyflg = 1;
         else
           eval(['code = indvcmp(in' int2str(firstvary) ',in' int2str(j) ');']);
           if code ~= 1
             error(['inconsistent varying data']);
             return
           end
         end
       else					% ADDED THIS TO TREAT VARYING AS CONSTANT
         rowdata = [rowdata mrows*mnum+1];	% ADDED THIS TO TREAT VARYING AS CONSTANT
         coldata = [coldata mcols+1];		% ADDED THIS TO TREAT VARYING AS CONSTANT
       end
     elseif mtype == 'syst'
         rowdata = [rowdata mnum+mrows+1];
         coldata = [coldata mnum+mcols+1];
     else
         rowdata = [rowdata mrows];
         coldata = [coldata mcols];
     end
 end

 if varyflg == 0
   nindv = 1;
 end

 pt = [];
 ve = (0:(nindv-1))';
 vee = (1:nindv)';
 oness = ones(nindv,1);
 for i=1:nin
   if typedata(i,1:4) == 'vary'
     pt = [pt oness+ve*rowdata(i) vee*rowdata(i)];
   else
     pt = [pt oness*[1 rowdata(i)]];
   end
 end

 istring = [];
 if nargout > 0
   ostring = ['['];
   for j=1:nout
     ostring = [ostring 'outt' int2str(j) ','];
   end
   ostring = ostring(1:length(ostring)-1);
   ostring = [ostring '] = '];
 else
   ostring = ' ';
 end

 for j=1:nin
   istring = [istring 'inn' int2str(j) ','];
 end
 istring = istring(1:length(istring)-1);

 for j=1:nout
   eval(['out' int2str(j) '= [];']);
 end

 loc = '(pt(i,2*j-1):pt(i,2*j),1:coldata(j));';
 for i=1:nindv
   for j=1:nin
     eval(['inn' int2str(j) '=in' int2str(j) loc]);
   end
%  ADJUSTED IT FROM HERE
   if varyflg == 0
     eval([ostring 'feval(''' name ''',' istring ');']);
   else
     tmask = mask - 1;
     eval([ostring 'mveval(''' name ''',tmask,' istring ');']);
   end
%  TO HERE
   for j=1:nout
     eval(['out' int2str(j) '= [out' int2str(j) '; outt' int2str(j) '];']);
   end
 end
 if varyflg == 1
   for j=1:nout
     eval(['out' int2str(j) '= vpck(out' int2str(j) ',indv);']);
   end
 end
%
%