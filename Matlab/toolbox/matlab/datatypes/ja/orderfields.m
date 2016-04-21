% ORDERFIELDS   構造体配列のフィールドの順番の並べ替え
% 
% SNEW = ORDERFIELDS(S1) は、新しい構造体配列 SNEW が、ASCIIで設定
% された順番のフィールド名となるようにS1 のフィールドを並べ替えます。
% 
% SNEW = ORDERFIELDS(S1, S2) は、新しい構造体配列 SNEW が、S2 の
% フィールドと同じ順のフィールド名となるように S1 のフィールドを
% 並べ替えます。S1 と S2 は、同じフィールドをもたなければなりません。
% 
% SNEW = ORDERFIELDS(S1, C) は、新しい構造体配列 SNEW が、C のフィールド名
% 文字列のセル配列と同じ順番になるように S1 のフィールドを並べ替えます。
% S1 と C は、同じフィールド名をもたなければなりません。
% 
% SNEW = ORDERFIELDS(S1, PERM) は、PERM のインデックスによって指定された
% 順番になるように S1 のフィールドを並べ替えます。S1 が N 個のフィールド
% 名をもつ場合、PERM の要素は1から N の数の並び替えでなければなりません。
% 再度並び替えを行いたい構造体が1つ以上ある場合に、すべて同一の方法で
% 行えるため、これは特に便利です。
% 
% [SNEW, PERM] = ORDERFIELDS(...) は、並び替えを実行した結果である SNEW
% に出力された構造体配列のフィールドの変更を示す順番のベクトルを出力します。
%
% ORDERFIELDS は、トップレベルのフィールドのみを並べ替えます。(繰り返す
% ことはできません).
% 
% 例題:
%          s = struct('b',2,'c',3,'a',1);
%          snew = orderfields(s);
%          [snew, perm] = orderfields(s,{'b','a','c'});
%          s2 = struct('b',3,'c',7,'a',4);
%          snew = orderfields(s2,perm);


%   Copyright 1984-2003 The MathWorks, Inc. 
