% STREAMPARTICLES は、ストリーム粒子の表示を行います。
% 
% STREAMPARTICLES(VERTICES) は、ベクトル場のストリーム粒子を描画します。
% ストリーム粒子は、通常、あるマーカで表し、ストリームラインの速度を
% 位置で示すことができます。VERTICES は、(STREAM2 や STREAM3 で作成した)
% 2次元、3次元の頂点のセル配列です。
%
% STREAMPARTICLES(VERTICES, N) は、ストリーム粒子を描画する数を N を
% 使って設定します。'ParticleAlignment' プロパティは、N をどのように解釈
% するかをコントロールします。'ParticleAlignment' が 'off' (デフォルト)で、
% Nが1以上の場合は、近似的に、N 個の粒子はストリームライン頂点に渡り、
% 等間隔に描画されます。N が1に等しいか小さい場合は、N はオリジナルの
% ストリーム頂点の数からある部分(割合)のみを使用します。たとえば、N が
% 0.2の場合は、約20%の頂点数が使われます。N は、描画する粒子の数の上限を
% 設定します。粒子の実際の数は、2のベキ乗の型で N から求まります。
% 'ParticleAlignment' が 'on' の場合は、N は、頂点全体を結ぶストリーム
% ラインに関して、そこで使用する粒子の数を決定します。すなわち、他の
% ストリームライン上の間隔として、この値を設定します。デフォルトは1です。
%
% STREAMPARTICLES(... 'NAME1',VALUE1,'NAME2',VALUE2,...) は、プロパティ名
% とそれに設定した値を使って、ストリーム粒子をコントロールします。設定
% していないプロパティには、デフォルト値が使われます。プロパティ名の設定
% には、大文字、小文字の区別は行いません。
%
% STREAMPARTICLES PROPERTIES(ストリーム粒子のプロパティ)
% 
% Animate           - ストリーム粒子の運動 [ 非負の整数 ]
% 　　　　　　　　　　ストリーム粒子をアニメーションする回数。デフォルト
%                     は0で、アニメーションを行いません。Inf は、Ctrl-C 
%                     で停止するまで、アニメーションは続きます。
%
% FrameRate         - 単位時間(秒単位)あたりのアニメーションのフレーム数
%                     [ 非負の整数 ] 
%                     アニメーションでの単位時間あたりのフレーム数を指定
%                     します。デフォルトは、Inf で、アニメーションを可能
%                     な限り高速にします。注意：フレーム比は、アニメーシ
%                     ョンのスピードアップにはなりません。
%
% ParticleAlignment - ストリームラインを使って、粒子を結合 
%                     [ on | {off} ] 
%                     このプロパティを 'on' に設定する場合は、ストリーム
%                     ラインの最初の部分に粒子を描画します。このプロパティ
%                     は、N をどのように解釈するかをコントロールします。
% 
% また、いくつかのラインプロパティとそれに関連した値に、'erasemode' また
% は 'marker' を使用することができます。つぎに、STREAMPARTICLES で設定
% するラインプロパティのデフォルトを示します。これらは、プロパティ名/値を
% ユーザが設定することにより、書き換えることができます。
%
%   プロパティ名        値
%   ------------        --
%   'EraseMode'        'xor'
%   'LineStyle'        'none'
%   'Marker'           'o'
%   'MarkerEdgeColor'  'none'
%   'MarkerFaceColor'  'red'
%
% STREAMPARTICLES(H,...) は、LINE オブジェクト H を使って、ストリーム
% 粒子を描画します。
%
% STREAMPARTICLES(AX,...) は、GCAの代わりにAXにプロットします。Hを指定する
% 場合は、このオプションは、無視されます。
%
% H = STREAMPARTICLES(...) は、LINE オブジェクトのハンドル番号をベクトル
% として出力します。
%
% 例題 1:
% 
%      load wind
%      [sx sy sz] = meshgrid(80, 20:1:55, 5);
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      sl = streamline(verts);
%      iverts = interpstreamspeed(x,y,z,u,v,w,verts,.025);
%      axis tight; view(30,30); daspect([1 1 .125])
%      set(gca, 'drawmode', 'fast')
%      camproj perspective; box on
%      camva(44); camlookat; camdolly(0,0,.4, 'f');
%      h = line; 
%      streamparticles(h, iverts, 35, 'animate', 10, ...
%                      'ParticleAlignment', 'on');
%
% 例題 2:
% 
%      load wind
%      daspect([1 1 1]); view(2)
%      [verts averts] = streamslice(x,y,z,u,v,w,[],[],[5]); 
%      sl = streamline([verts averts]);
%      axis tight off;
%      set(sl, 'linewidth', 2, 'color', 'r', 'vis', 'off')
%      iverts = interpstreamspeed(x,y,z,u,v,w,verts,.05);
%      set(gca, 'drawmode', 'fast', 'position', [0 0 1 1])
%      set(gcf, 'color', 'k')
%      h = line; 
%      streamparticles(h, iverts, 200, ...
%                      'animate', 100, 'framerate',40, ...
%                      'markers', 10, 'markerf', 'y');
%
% 参考：INTERPSTREAMSPEED, STREAMLINE, STREAM3, STREAM2.


%   Copyright 1984-2002 The MathWorks, Inc. 
