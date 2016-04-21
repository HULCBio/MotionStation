% DSP Blockset
% Version 5.0 (R13.0.1)  14-Mar-2003 
%
% ニュース
%
%   このバージョンでの新機能、バグフィックス、変更点
%
%   Version 5.0 のリリースノートを表示するには、MATLABコマンドプロンプトで
%   "whatsnew" と入力してください。
%
% DSP Blockset サポート関数
%
%   dsp_links      - ライブラリリンクの情報の表示と出力
%   dspfwiz        - Filter realization wizardユーザインタフェース
%   dsplib         - DSP Blocksetライブラリを開く
%   dspstartup     - DSPシステムに対するデフォルトのSimulinkモデルの設定
%   rebuffer_delay - Bufferブロックによる遅れを計算
%
% DSP Blockset ライブラリ v5.x
%
%   dspadpt3      - 適応フィルタ
%   dsparch4      - フィルタ設計
%   dspbuff3      - バッファ
%   dspfactors    - 行列の分解
%   dspindex      - インデックス付け
%   dspinverses   - 逆行列
%   dsplp         - 線形予測
%   dsplibv4      - v5.x のメインDSP Blocksetライブラリ
%   dspmathops    - 数学演算
%   dspmlti3      - マルチレートフィルタ
%   dspmtrx3      - 行列演算
%   dspparest3    - パラメータ推定
%   dsppolyfun    - 多項式関数
%   dspquant2     - 量子化
%   dspsigattribs - 信号の属性
%   dspsigops     - 信号の操作
%   dspsnks4      - DSP表示
%   dspsolvers    - 線形システムソルバ
%   dspspect3     - パワースペクトル推定
%   dspsrcs4      - DSP信号源
%   dspstat3      - 統計
%   dspswit3      - スイッチとカウンタ
%   dspxfrm3      - 変換
%   dspwin32      - Windows (WIN32)
%
% DSP Blockset ライブラリ v4.x
%
%   dspadpt3      - 適応フィルタ
%   dsparch3      - フィルタ構造
%   dspbuff3      - バッファ
%   dspddes3      - フィルタ設計
%   dspfactors    - 行列の分解
%   dspindex      - インデックス付け
%   dspinverses   - 逆行列
%   dsplp         - 線形予測
%   dsplibv4      - v4.xのメインDSP Blocksetライブラリ
%   dspmathops    - 数学演算
%   dspmlti3      - マルチレートフィルタ
%   dspmtrx3      - 行列関数
%   dspparest3    - パラメータ推定
%   dsppolyfun    - 多項式関数
%   dspquant2     - 量子化
%   dspsigattribs - 信号の属性
%   dspsigops     - 信号の演算
%   dspsnks3      - DSP表示
%   dspsolvers    - 線形システムソルバ
%   dspspect3     - スペクトル推定
%   dspsrcs3      - DSP信号源
%   dspstat3      - 統計
%   dspswit3      - スイッチとカウンタ
%   dspxfrm3      - 変換(ベクトルベース)
%
% DSP Blockset ライブラリ v3.x
%
%   dspadpt2   - 適応フィルタ構造
%   dsparch2   - 非適応フィルタアーキテクチャ
%   dspbdsp2   - 基本的なDSP信号演算
%   dspbuff2   - データバッファリングブロック
%   dspddes2   - ディジタル、アナログフィルタ設計ブロック
%   dspelem2   - 基本的な関数ライブラリ
%   dsplibv3   - Ver 3.xのメインDSP Blocksetライブラリ
%   dsplinalg  - 線形代数ライブラリ
%   dspmlti2   - マルチレートフィルタブロック
%   dspmtrx2   - 行列関数ブロック
%   dspquant   - 量子化ブロック(バージョン3.1に付加)
%   dspparest2 - パラメータ推定ライブラリ
%   dspsnks2   - DSP 表示ライブラリ
%   dspspect2  - スペクトル解析ライブラリ
%   dspsrcs2   - DSP 信号源ライブラリ
%   dspstat2   - 統計ブロック
%   dspswit2   - スイッチとカウンタ
%   dspvect2   - ベクトル関数演算
%   dspxfrm2   - ベクトル信号変換
%
%  Ver 2.2、および、それ以前のDSP Blocksetライブラリ
%
%   dspadpt    - 適応フィルタ構造
%   dsparch    - 非適応フィルタアーキテクチャ
%   dspbdsp    - 基本的なDSP信号操作
%   dspbuff    - データバッファリングブロック
%   dspcmplx   - 複素数演算ブロック
%   dspddes    - ディジタル、アナログフィルタ設計ブロック
%   dspelmat   - 基本(スカラ)演算ブロック
%   dsplibv2   - Ver 2.2のメインDSP Blocksetライブラリ
%   dspmlti    - マルチレートフィルタブロック
%   dspmtrx    - 行列演算操作
%   dspsnks    - DSP 表示ライブラリ
%   dspspect   - スペクトル解析ライブラリ
%   dspsrcs    - DSP 信号源ライブラリ
%   dspstat    - 統計ブロック
%   dspswit    - スイッチ
%   dspvect    - ベクトル関数演算
%   dspxfrm    - ベクトル信号変換


% Copyright 1995-2002 The MathWorks, Inc.
