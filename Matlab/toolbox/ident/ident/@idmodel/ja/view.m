% VIEW は、モデルの種々の特性をプロットします。
% 
% このルーチンは、LTIVIEW を必要とするので、Control System Toolbox を必
% 要とします。
%   
% VIEW(Mod)
% 
% Mod は、任意のIDMODEL (IDGREY, IDARX, IDPOLY, IDSS)、または、IDFRD モ
% デルです。
% VIEW は、CSTB の中の LTIVIEW 関数にアクセスし、極や零点図と同様に、ス
% テップ応答、インパルス応答、ボード線図、ナイキスト線図、ニコルス線図、
% 極零プロットを描きます。
%
% 共分散や不確かさの情報は示しません。信頼区間を調べるには、コマンド BO-
% DE, NYQUIST, STEP,IMPULSE, PZMAP を使ってください。
%
% 測定可能な入力をもつモデルに対して、これらの入力から出力への伝達関数の
% 特徴のみが示されます。ノイズ源から出力までの伝達関数の性質を調べるには
% VIEW(m('n')) ('n' は、'noise'の略)を使います。ノイズの伝達関数は、モデ
% ルの NoiseVariance を使って正規化され、ノイズ源は、単位共分散行列をも
% つ白色ノイズとなります。
%
% 時系列モデル(測定入力がない)に対して、正規化されたノイズ源からの伝達関
% 数となります。
%
% いくつかのモデルが、VIEW(Mod1,Mod2,....,ModN) を使って比べられます。種
% 々のモデルに対して、PlotStyle(カラー、マーカ、ラインスタイル)は、
%
%    VIEW(Mod1,'PlotStyle1',Mod2,'PlotStyle2',...,ModN,'PlotStyleN')
% 
% で設定できます。PlotStyle は、 'b', 'b+:'のような値を取ることができま
% す。HELP PLOT を参照してください。
%   
% 引数の最後に、つぎの文字列
% 
%   'step','impulse','bode','nyquist','nichols','sigma','pzmap','iopzmap';
% 
% を加えることができ、対応するタイプで、プロットを初期化します。これらの
% いくつか(6 まで)のセル配列を使って、マルチプロットを作成することができ
% ます。
%
% VIEW は、IDFRD モデル用の(SPA や ETFE で得られる)出力分散スペクトルを
% サポートしていません。
%
% VIEW は、LTIVIEW のすべてのオプションをカバーしていません。LTIVIEW の
% 機能性を十分に利用するためには、Control Toolbox のコマンド ltiview を
% 使用してください。これらを直接インポートできるため、モデルを lti オブ
% ジェクトに変換する必要はありません。


%   Copyright 1986-2001 The MathWorks, Inc.
