% function [out1,out2,out3,...] = veval(name,in1,in2,in3,...)
%
%   Works like MATLAB FEVAL, but on collections of VARYING and
%   CONSTANT/SYSTEM matrices. NAME is a character string with
%   the name of a MATLAB function (user written, or MATLAB
%   supplied).  The function is applied to each input argument
%   at the INDEPENDENT VARIABLE's values. Any CONSTANT/SYSTEM
%   matrices are held at their value while the sweep through
%   INDEPENDENT VARIABLE is done. Currently limited to 10
%   output arguments, and an unlucky 13 input arguments, which
%   is easily changeable.
%
%   VEVAL can be used to easily generate VARYING system matrices.
%
%   See also: EVAL, FEVAL and VEBE.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [out1,out2,out3,out4,out5,out6,out7,out8,out9,out10] =...
veval(name,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13)

 if nargin == 0
   disp('usage: [out1,out2,out3,...] = veval(in1,in2,in3,in4,...)')
   return
 end

 nin = nargin - 1;
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
             error(['Inconsistent Varying Data:' ...
                    '  check InputArg_' int2str(firstvary) ' and InputArg_' int2str(j)]);
             return
           end
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
   if strcmp(typedata(i,1:4),'vary')
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

 szdata = zeros(nout,2);
 i = 1;
   for j=1:nin
     eval(['inn' int2str(j) '=in' int2str(j) loc]);
   end
   eval([ostring 'feval(''' name ''',' istring ');']);
   for j=1:nout
     sj = int2str(j);
     eval(['szdata(j,:) = size(outt' sj ');']);
     eval(['out' sj '=zeros(szdata(j,1)*nindv,szdata(j,2));']);
     eval(['out' sj '((i-1)*szdata(j,1)+1:i*szdata(j,1),1:szdata(j,2)) = outt' sj ';']);
   end

 for i=2:nindv
   si = int2str(i);
   for j=1:nin
     sj = int2str(j);
     eval(['inn' sj '=in' sj loc]);
   end
   eval([ostring 'feval(''' name ''',' istring ');']);
   for j=1:nout
     sj = int2str(j);
     % eval(['out' int2str(j) '= [out' int2str(j) '; outt' int2str(j) '];']);
        eval(['out' sj '((i-1)*szdata(j,1)+1:i*szdata(j,1),1:szdata(j,2)) = outt' sj ';']);
   end
 end
 if varyflg == 1
   for j=1:nout
     sj = int2str(j);
     eval(['out' sj '= vpck(out' sj ',indv);']);
   end
 end
%