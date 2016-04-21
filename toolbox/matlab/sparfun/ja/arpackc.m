% ARPACKC  EIGS によるARPACKライブラリへのC-MEX インタフェース
% 
% ARPACKC('dsaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
% IDO: 通信パラメータを無効にする。すなわち、0に初期化 {int32}
% BMAT: 標準問題に対しては 'I'、一般化問題に対しては 'G'  {char}
% N: 問題のサイズ {int32}
% WHICH: 'LM','SM','LA','SA','BE'. {長さ 2 の char}
% NEV: 必要となる固有値の数 {int32}
% TOL: 収束のトレランス。デフォルトは、eps/2です。 {double}
% RESID: スタートベクトル用の初期化 {長さ N の double}
% NCV: Lanczos ベクトルの数 {int32}
% V: Lanczos 基底ベクトル {長さ N*NCV の double}
% LDV: V の先頭次元 {int32}
% IPARAM: {長さ 11 int32}
% IPNTR: {長さ 15 int32}
% WORKD: {長さ 3*N double}
% WORKL: {長さ LWORKL double}
% LWORKL: WORKLの長さ >= NCV^2+8*NCV {int32}
% INFO {int32}
%
%   ARPACKC('dseupd',RVEC,HOWMNY,SELECT,D,Z,LDZ,SIGMA,...
%           BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   RVEC: 固有値を計算するか否か {int32}
%   HOWMNY: Ritz ベクトルに対しては 'A'。'S' は、SELECT から選択 {char}
%   SELECT: 計算する Ritz ベクトルの指定 {長さ NEV の int32}
%   D: 固有値 {長さ NEV の double}
%   Z: Ritz ベクトル {長さ N*NEV の double}
%   LDZ: Z の先頭次元 {int32}
%   SIGMA: スカラ固有値シフト {double}
%   Remaining 入力は、最新の'dsaupd' 呼び出しからは変化しません。
%
%   ARPACKC('dnaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   つぎの事柄を除いて、'dsaupd' に対するものと同じです。
%   WHICH: 'LM','SM','LR','SR','LI','SI'. {長さ 2 の char}
%   LWORKL: WORKL の長さ>= 3*NCV*(NCV+2) {int32}
%
%   ARPACKC('dneupd',RVEC,HOWMNY,SELECT,D,DI,Z,LDZ,SIGMAR,SIGMAI,....
%            WORKEV, BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   つぎの事柄を除いて、'dseupd' と'dnaupd' に対するものと同じです。
%   HOWMNY: 'A'：RItz ベクトル用、'P'：全 Schur ベクトル用
%           'S'：SELECT から Ritz ベクトルを選択 {char}
%   D: Ritz 値の実数部 {長さ NEV+1 の double}
%   DI: Ritz 値の虚数部 {長さ NEV+1 の double}
%   Z: {長さ N*(NEV+1) の double}
%   SIGMAR: スカラ固有値シフトの実数部 {double}
%   SIGMAI: スカラ固有値シフトの虚数部 {double}
%   WORKEV: {長さ 3*NCV の double}
%
%   ARPACKC('znaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,RWORK,INFO)
%   つぎの事柄を除いて、'dnaupd' と同じです。
%   RESID: {長さ 2*N の double}
%   V: {長さ 2*N*NCV の double}
%   WORKD: {長さ 2*3*N の double}
%   WORKL: {長さ 2*LWORKL の double}
%   LWORKL: 複素数 WORKL の長さ >= 3*NCV^2+5*NCV {int32}
%   RWORK: {2*NCV double}
%
%   ARPACKC('zneupd',RVEC,HOWMNY,SELECT,D,Z,LDZ,SIGMA,WORKEV,...
%           BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,RWORK,INFO)
%   つぎの事柄を除いて、'dneupd' と 'znaupd' と同じです。
%   D: {長さ 2*(NEV+1) の double}
%   Z: {長さ 2*N*NEV の double}
%   SIGMA: 実数ベクトルにストアされている複素数シフト {長さ 2 の double}
%   WORKEV: {長さ 2*2*NCV の double}
%
% 注意：znaupd と zneupd に対して、すべての double の変数は、複素数を
% ストアするので、ARPACK で必要とされている長さの2倍を必要とします。
% MATLAB の複素数入力 RESID と WORKD は、znaupd へ渡す前に、FORTRANスト
% レージにインタリーブするために変換することが必要です。D と V は、
% zneupd から戻された後、FORTRAN ストレージから変換される必要があります。
% 他の"複素数"ベクトルは、入力も出力でもなく、一度割り当てられると変更
% する必要がありません。
%
% ARPACKは、FORTRANサブルーチンを集めたもので、つぎのアドレスから利
% 用できます。
%      http://www.caam.rice.edu/software/ARPACK/
%
% 詳細については、以下を参照してください。
%
%   R.B. Lehoucq, D.C. Sorensen and C. Yang,
%   ARPACK Users' Guide: Solution of Large-Scale Eigenvalue Problems
%   with Implicitly Restarted Arnoldi Methods
%   SIAM Publications, Philadelphia, (1998).
%   ISBN 0-89871-407-9
%
%  D.C. Sorensen,
%  Implicit application of polynomial filters in a k-Step Arnoldi Method,
%   SIAM J. Matrix Analysis and Applications, 13, pp. 357-385, (1992).
%
%   R.B. Lehoucq  and D.C. Sorensen,
%   Deflation Techniques for an Implicitly Re-started Arnoldi Iteration,
%   SIAM J. Matrix Analysis and Applications, 17, pp. 789-821, (1996).
%
% ARPACK のThe MathWorksバージョンは、June 2,2000 の日付のパッチを含
% んでいます。
%
% The MathWorksは、ARPACK をわずかに変更して、IPNTR の長さを15まで長く
% しました。そのため、カレントの繰り返し回数は、IPNTR(15) に戻されます。
% The MathWorksは、つぎのトップレベルのFORTRANサブルーチンをコンパイル
% しました。
%      dsaupd と dseupd (real symmetric)
%      dnaupd と dneupd (real nonsymmetric)
%      znaupd と zneupd (complex)
% および、LAPACK 3.0 にリンクする共有ライブラリ内の DLAHQR のLAPACK 
% 2.0 バージョンに含まれているすべてのサポートしているサブルーチン。
% C mex-ファイル ARPACKC は、MATLAB入力を処理し、対応するARPACK 
% ルーチンを呼び出します。ARPACKC は EIGS で用いられ、ARPCK逆通信や
% 行列アプリケーションを実現します。
%
% 参考：EIGS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:02:26 $
