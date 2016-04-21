% COLFILT   列方向処理関数を使って、近傍演算を実行
% COLFILT は、個々のブロック、または、スライディングブロックを列として処
% 理します。COLFILT は、BLKPROC や NLFILTER と同様の演算を行いますが、
% 非常に高速になります。
% 
% B = COLFILT(A,[M N],BLOCK_TYPE,FUN) は、イメージ A を、個々に M 行 N 列
% のブロックに再配列して、テンポラリの行列の列に並び替えて処理します。そ
% して、関数 FUN をその行列に適用します。FUN は、@または、INLINE オブジ
% ェクトを使って作成した FUNCTION_HANDLE です。
% COLFILT は、必要なら A にゼロを付加します。
% 
% FUN を呼び出す前に、COLFILT は、テンポラリ行列を作成するために、IM2COL
% を呼び出します。FUN を呼び出した後、COLFILT は、COL2IM を使って、行列
% の列を M 行 N 列のブロックに並び替えます。
% 
% BLOCK_TYPE には、つぎのいずれかの値を設定することができます。
% 
% 'distinct' は、M 行 N 列の重なりのないブロック
% 'sliding' は、M 行 N 列のスライディングブロック
% 
% B = COLFILT(A,[M N],'distinct',FUN) は、A の M 行 N 列のブロックをテン
% ポラリ行列に再配列し、その行列に関数 FUN を適用します。FUN は、テンポ
% ラリ行列として、同サイズの行列を出力します。そして、COLFILT は、FUN が
% 出力する行列の列を、M 行 N 列のブロックに再配列します。
% 
% B = COLFILT(A,[M N],'sliding',FUN) は、A の各 M 行 N 列のスライディング
% 近傍を並べ替えて、テンポラリ行列の列にします。そして、関数 FUN をこの
% 行列に適用します。FUN は、テンポラリ行列内の各列に対して、単一値を含む
% 行ベクトルを出力しなければなりません(SUM のような列圧縮関数は、適切な
% タイプの出力を返します)。COLFILT は、FUN が出力するベクトルを A と同サ
% イズの行列に再配列します。
% 
% B = COLFILT(A,[M N],BLOCK_TYPE,FUN,P1,P2,...) は、付加的なパラメータ P1
% P2,...,を FUN に渡します。COLFILT は、つぎのように FUN を呼び出します。
% 
%    Y = FUN(X,P1,P2,...)
% 
% ここで、X は処理前のテンポラリ行列で、Y は処理後のテンポラリ行列です。
% 
% B = COLFILT(A,[MN],[MBLOCKNBLOCK],BLOCK_TYPE,FUN,...) は、上述のように
% 行列 A を処理しますが、メモリを節約するため、MBLOCKS 行 NBLOCKS 列の大
% きさのブロックを使います。[MBLOCK  NBLOCK] 引数を使うことは、演算結果
% に影響を与えません。
% 
% B = COLFILT(A,'indexed',...) は、A をインデックス付きイメージとして処
% 理し、A がクラス uint8、または、uint16 の場合0、クラス double の場合1
% を必要に応じて付加します。
% 
% クラスサポート
% -------------
% 入力イメージ A には、FUN がサポートするクラスを使うことができます。B 
% のクラスは、FUN から出力されるクラスに依存します。
% 
% 例題
%       I = imread('tire.tif');
%       imshow(I)
%       I2 = uint8(colfilt(I,[5 5],'sliding',@mean));
%       figure, imshow(I2)
%
% 参考：BLKPROC, COL2IM, FUNCTION_HANDLE, IM2COL, INLINE, NLFILTER.



%   Copyright 1993-2002 The MathWorks, Inc.  
