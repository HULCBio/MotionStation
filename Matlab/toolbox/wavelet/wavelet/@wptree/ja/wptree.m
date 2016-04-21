% WPTREE   クラス WPTREE 用のコンストラクタ
%
% T = WPTREE(ORDER,DEPTH,X,WNAME,ENT_TYPE,ENT_PAR) は、ウェーブレット
% パケットツリー T の全てを出力します。
%
% ORDER は、ツリーの順番を示す整数です(それぞれ、終端ノードでない
% "children" の数)。2 または 4 に等しくなければなりません。
%
% ORDER = 2 の場合、T は、はベクトル(信号) X を、特定のウェーブレット 
% WNAME でレベル DEPTH でウェーブレットパケット分解した結果に対応する
% WPTREE オブジェクトです。
%
% ORDER = 4 の場合、T は、行列(イメージ) X を、特定のウェーブレット 
% WNAME でレベル DEPTH でウェーブレットパケット分解した結果に対応する 
%   WPTREE オブジェクトです。 
%
% ENT_TYPE は、エントロピーのタイプを含む文字列で、ENT_PAR は、エント
% ロピーの計算のために使われる最適化パラメータです (より詳しい情報は、
% WENTROPY, WPDEC または WPDEC2 を参照してください)。
%
%   T = WPTREE(ORDER,DEPTH,X,WNAME) は、
%   T = WPTREE(ORDER,DEPTH,X,WNAME,'shannon') と等価です。
%
%   T = WPTREE(ORDER,DEPTH,X,WNAME,ENT_TYPE,ENT_PAR,USERDATA) として、
%   ユーザデータフィールドを設定します。
%
%   関数 WPTREE は、WPTREE オブジェクトを出力します。
%   オブジェクトフィールドに関するより詳細な情報は、help wptree/get をタ
%   イプしてください。
%
%   参考: DTREE, NTREE


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Copyright 1995-2002 The MathWorks, Inc.
