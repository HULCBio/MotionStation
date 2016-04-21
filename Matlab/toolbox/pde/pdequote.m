function [M,L]=pdequote(A)
%PDEQUOTE Doubles all quotes in a string matrix.
%   SS=PDEQUOTE(S) replaces all occurrences of ' (single quote)
%   with '' (two single quotes) so that the string can be
%   written inside a pair of single quotes. SS is padded using
%   space characters.
%   [SS,I]=PDEQUOTE(S) returns an additional vector I containing the
%   lengths of each row in SS, excluding the padded spaces.

%   L. Langemyr, M. Ringh 9-14-95.
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2003/11/18 03:11:47 $

if isempty(A),
  M=A;
  L=[];
  return
end

if size(A,1)==1
  M=strrep(A,'''','''''');
  L=length(M);
else
  B=A=='''';
  S=sum(B')';
  C=cumsum(B')';

  m=size(A,1);
  n=max(S)+size(A,2);

  I=(1:size(A,1))'*ones(1,size(A,2));
  J=ones(size(A,1),1)*(1:size(A,2));
  M=sparse(I,J+C,double(A),m,n);

  [I,J]=find(B);
  M=M+sparse(I,J+C(I+m*(J-1))-1,''''*ones(size(I)),m,n);

  [I,J]=find(M==0);
  M=M+sparse(I,J,' '*ones(size(I)),m,n);

  M=char(full(M));
  L=S+size(A,2);
end

