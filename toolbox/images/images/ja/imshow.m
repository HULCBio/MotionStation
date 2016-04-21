% IMSHOW   イメージの表示
% IMSHOW(I,N) は、強度イメージ I を N 個のグレーの離散レベルで表示しま
% す。N を省略すると、IMSHOW は24ビット表示では256個のグレーレベルを、
% 他のシステムでは64個のグレーレベルを使います。
%
% IMSHOW(I,[LOW HIGH]) は、イメージ I のデータ範囲に制約を付けて、そ
% の範囲でグレースケール強度イメージとして表示します。値 LOW(とLOW よ
% り小さい値)は黒で、値 HIGH(とHIGH より大きい値)は白で表現され、その
% 間の値は、グレーの中間色で表示されます。IMSHOW は、デフォルトのグ
% レーレベル数を使います。[LOW HIGH]を空行列で設定すると、IMSHOW は、
% [min(I(:)) max(I(:))] を使います。ここで、I の最小値は黒で、最大値は
% 白で表示されます。
%
% IMSHOW(BW) は、バイナリイメージ BW を表示します。値0は黒として表示
% し、値1は白として表示します。
%
% IMSHOW(X,MAP) は、カラーマップ MAP を使って、インデックス付きイ
% メージ X を表示します。
%
% IMSHOW(RGB) は、トゥルーカラーイメージ RGB を表示します。
%
% IMSHOW(...,DISPLAY_OPTION) は、DISPLAY_OPTION が 'truesize' の場合、
% 関数 TRUESIZE を使い、また、'notruesize' の場合、関数 TRUESIZEを使わ
% ないでイメージを表示します。どちらのオプションの文字列も省略して書く
% ことができます。これらの引数を設定しないと、IMSHOW は、'ImshowTruesize' 
% の優先順位の設定をベースに、関数 TRUESIZE を読み込むかどうかを決定します。
%
% IMSHOW(x,y,A,...) は、デフォルトでない空間座標系を作るために、イメージ
% の XData と YData を設定する2要素ベクトル x と y を使います。
% x と y は、2以上の要素数をもっていますが、最初と最後の要素のみが、
% 実際に使われることに注意してください。
%
% IMSHOW(FILENAME) は、グラフィックスファイル FILENAME に格納されて
% いるイメージを表示します。IMSHOW は、ファイルからイメージを読み込
% むために IMREAD を使いますが、MATLAB ワークスペースにイメージ
% データを格納することはありません。ファイルは、カレントディレクトリ
% か、または、MATLAB パス上になければなりません。
%
% H = IMSHOW(...) により作成されるイメージオブジェクトのハンドルを出
% 力します。
%
% クラスサポート
% -------------
% 入力イメージは、logical、uint8、uint16、double のいずれのクラスも
% サポートしています。入力イメージは、非スパースである必要があります。
%
% 注意
% ----
% IPTSETPREF 関数を使用して、いくつかのツールボックスの優先順位を設
% 定して、IMSHOW の動作を変更することができます。
%
%   - 'ImshowBorder' は、IMSHOW がイメージのまわりに境界を表示するかど
%     うかを制御します。
%
%   - 'ImshowAxesVisible' は、IMSHOW が軸ボックスと軸ラベルを表示する
%     かどうかを制御します。
%
%   - 'ImshowTruesize' は、IMSHOW が TRUESIZE 関数を呼び出すかどうかを
%     制御します。
%
% これらの優先順位の詳細については、IPTSETPREF のリファレンスの項目
% を参照してください。
%
% 参考：IMREAD, IPTGETPREF, IPTSETPREF, SUBIMAGE, TRUESIZE, WARP, 
%         IMAGE, IMAGESC



%   Copyright 1993-2002 The MathWorks, Inc.  
