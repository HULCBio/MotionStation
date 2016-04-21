% [a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r)
% data = hinfpar(P,r,string)
%
% 標準Hinfプラント
%
%                    |  a   b1   b2 |
%             P  =   | c1  d11  d12 |
%                    | c2  d21  d22 |
%
% をアンパックし、状態空間行列a,b1,b2,...を出力します。2行1列ベクトルRは
% D22のサイズを設定します。すなわちR = [ NY , NU ]で、ここで
% 
%     NY = 観測量の数	      NU = 制御量の数
% 
% です。Pは、LTISYSを使って作成されたものでなければなりません。
%
% 特定の状態空間行列(例えばc1)を得るためには、3番目の引数を文字列'a','b1',
% 'b2',...のいずれかに設定してください。たとえば、c1 = hinfpar(P,r,'c1')
% となります。
%
% 参考：    LTISYS, LTISS.



% Copyright 1995-2002 The MathWorks, Inc. 
