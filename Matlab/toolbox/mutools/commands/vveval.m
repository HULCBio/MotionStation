% function [out1,out2,out3,...] = vveval(name,in1,in2,in3,...)
%
%   Works like MATLAB FEVAL, but on collections of VARYING and
%   CONSTANT/SYSTEM matrices. NAME is a character string with
%   the name of a MATLAB function (user written, or MATLAB
%   supplied).
%
%	If in1, in2, ... in_last are all either CONSTANT or
%	SYSTEM matrices, then VVEVAL calls the function specified
%	by the variable NAME, using FEVAL.
%
%   If any of in1, in2, ... in_n are VARYING, say in_K, then VVEVAL
%   checks that all of the VARYING data is the same, and performs
%   a loop, recursively calling itself in the following manner
%
%
%   out1 = [];
%	  .
%   outm = [];
%   for i=1:length(getiv(in_K))
%     [t1,t2,..,tm] = vveval(xtracti(in1,i),xtracti(in2,i),.,xtracti(in_n,i);
%     out1 = [out1;t1];
%     out2 = [out2;t2];
%     outm = [outm;tm];
%   end
%   out1 = vpck(out1,ivvalue);
%   out2 = vpck(out2,ivvalue);
%   outm = vpck(outm,ivvalue);
%
%   See also: EVAL, FEVAL, SWAPIV, VEVAL, and MVEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out1,out2,out3,out4,out5,out6,out7,out8,out9,out10] =...
vveval(name,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,in13)

 if nargin == 0
   disp('usage: [out1,out2,out3,...] = vveval(name,in1,in2,in3,in4,...)')
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
             error(['inconsistent varying data']);
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
%  adjusted it here
   if varyflg == 0
     eval([ostring 'feval(''' name ''',' istring ');']);
   else
     eval([ostring 'vveval(''' name ''',' istring ');']);
   end
%  to here
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