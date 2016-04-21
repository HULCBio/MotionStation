% SORTED   メッシュサイトに対するサイトの位置付け
%
% POINTER = SORTED(MESHSITES, SITES) は、以下の条件に従う行ベクトルです。
%
% すべての j で
% POINTER(j) = #{ i : MESHPOINTS(i)  <=  sort(SITES)(j) }
%
% 従って、MESHPOINTS と SITES の両方が非減少の場合、
%
% すべての j で
% MESHSITES(POINTER(j))  <=  SITES(j)  <  MESHSITES(POINTER(j)+1)
%
% となり、POINTER(j) が0に等しいときは、SITES(j) < MESHSITES(1) である
% ことを意味し、length(MESHSITES) に等しいときは、MESHSITES(end) <= SITES(j) 
% であることを意味します。
%
% 例題:
%
%      sorted( 1:4 , [0 1 2.1 2.99 3.5 4 5])
%
% は、MESHSITES として 1:4 を、SITES として [0 1 2.1 2.99 3.5 4 5] を指定
% します。また、
%
%      sorted( 1:4 , [2.99 5 4 0 2.1 1 3.5])
% 
% としても、出力 [0 1 2 2 3 4 4] が与えられます。
%
% 参考 : PPUAL, SPVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
