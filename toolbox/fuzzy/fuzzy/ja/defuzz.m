% DEFUZZ メンバシップ関数の非ファジィ化
% 
% 表示
%   out = defuzz(x,mf,type)
% 
% 詳細
% defuzz(x,mf,type) は、設定した変数値xで、それぞれに対応するメンバシッ
% プ関数 mfを、引数 type に従って選択した非ファジィ化法を使って非ファジ
% ィ化値 out を出力します。変数 type は、つぎの中の1つに対応します。
% 
% centroid  : 面積重心法
% bisector  : 面積二分法
% mom       : 最大平均値
% som       : 最大値の最小化法
% lom       : 最大値の最大化法
% 
% type で設定したものが上述のものに対応しない場合、ユーザ設定の関数とし
% て扱われます。x と mf は、非ファジィ化した出力を作成するために、ユーザ
% 関数に渡されます。
% 
% 例題
%    x = -10:0.1:10;
%    mf = trapmf(x,[-10 -8 -4 7]);
%    xx = defuzz(x,mf,'centroid');
% 
% さらに、多くの例題については、DEFUZZDM をお試しください。



%   Copyright 1994-2002 The MathWorks, Inc. 
