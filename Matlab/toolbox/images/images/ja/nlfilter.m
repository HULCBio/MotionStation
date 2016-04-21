% NLFILTER   一般的なスライディングを伴う近傍処理を実行
%   B = NLFILTER(A,[M N],FUN) は、関数 FUN を A の各々 M 行 N 列 のス
%   ライディングブロックに適用します。FUN は、入力として M 行 N 列のブ
%   ロックを受け入れ、つぎの関数を満たす出力を行います。
%
%       C = FUN(X)
%
%   ここで、C は、M 行 N 列のブロック X の中心ピクセルの出力値になりま
%   す。NLFILTER は、A の各ピクセルに対して、FUN を読み込みます。NLFI-
%   LTER は、M 行 N 列のブロックにするために、必要な場合エッジにゼロを
%   付加します。
%
%   B = NLFILTER(A,[M N],FUN,P1,P2,...) は、付加的なパラメータ 
%   P1,P2,... を FUN に転送します。
%
%   B = NLFILTER(A,'indexed',...) は、A のクラスが double の場合0を、
%   uint8 の場合1を付加してインデックス付きイメージとして A を処理しま
%   す。
%
%   クラスサポート
% -------------
%   入力イメージ A は、FUN がサポートしているクラスを使うことができま
%   す。B のクラスは、FUN からの出力のクラスに依存します。
%
%   注意
%   ----
%   NLFILTER は、大きなイメージを処理するのに長時間を必要とします。こ
%   のような場合、関数 COLFILT は、同じ処理をより速く行います。
%
%   例題
%   ----
%   FUN は、@ を使って作成される FUNCTION_HANDLE です。つぎの例題は、
%   3行3列の近傍を MEDFILT2 で処理した結果と同様です。
%
%       B = nlfilter(A,[3 3],@myfun);
%
%   ここで、MYFUN は、つぎの内容を含む M-ファイルです。
%
%       function scalar = myfun(x)
%       scalar = median(x(:));
%
%   FUN は、インラインオブジェクトでも構いません。上の例題は、つぎのよ
%   うにも表現できます。
%
%       fun = inline('median(x(:))');
%       B = nlfilter(A,[3 3],fun);
%
%   参考：BLKPROC, COLFILT, FUNCTION_HANDLE, INLINE



%   Copyright 1993-2002 The MathWorks, Inc.
