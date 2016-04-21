% DFILTPARSE は、dfilt オブジェクト用の基本的なコンストラクタです。
% F = DFILTPARSE(DFILTTYPE,...) は、DFILTTYPE に設定されているタイプと等
% しい dfilt を作成します。DFILTTYPE は、dft, ssd, latcma 等、任意のもの
% を使用できます。
%
% たとえば、dtf オブジェクトに対して、つぎのシンタックス
% F = DFILTPARSE(DFILTTYPE,B1,A1,B2,A2,...)、または、F = DFILTPARSE(DF-
% ILTTYPE,{{B1,A1},{B2,A2},...}) を使って、カスケードセクションのdtf オ
% ブジェクト F を作成します。i 番目のセクションの分子と分母は、それぞれ
% ベクトル Bi と Ai に係数で与えます。
%
% F = DFILTPARSE(...,C) は、C に示される接続セクションの dfilt オブジェ
% クトを作成します。C は、カスケード接続 'cas'、または、パラレル接続 
% 'par' のいずれかを使います。

% $Revision: 1.4 $ $Date: 2002/06/17 12:57:13 $
%   Copyright 1988-2002 The MathWorks, Inc.
