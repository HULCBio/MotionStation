% STREAMSLICE �́A�X���C�X���ʓ��ŃX�g���[�����C�����쐬���܂��B
% 
% STREAMSLICE(X,Y,Z,U,V,W,Sx,Sy,Sz) �́A�x�N�g�� Sx,Sy,Sz �Œ�`�����_
% �Ɗ֘A����x,y,z���ʂł̎��̃x�N�g���f�[�^U,V,W ����A����ɑΉ�����
% �Ԋu��(���ŕ���������)�X�g���[�����C����`�悵�܂��B�z�� X,Y,Z �́A
% U,V,W �Ɋւ�����W���`���A�P����(MESHGRID �ō쐬����)3�����i�q������
% ���Ȃ���΂Ȃ�܂���BV �́AM x N x P ��3�����I�Ȕz������Ă��܂��B
% �܂��A����̓X���C�X���ʂɕ��s�Ƃ͍l���Ă��܂���B���Ƃ��΁A�萔 z �ł�
% �X�g���[�����C���ŁA�x�N�g����� z �����AW �́A���ʂɑ΂���X�g���[��
% ���C�����v�Z����ꍇ�ɖ�������܂��B�X�g���[���X���C�X�́A�X�g���[��
% ���C���A�X�g���[���`���[�u�A�X�g���[�����{���̏o���_�����肷��̂�
% �L���Ȃ��̂ł��B�ʏ�ASTREAMSLICE���R�[������O�ɁADataAspectRatio ��
% �ݒ肷�邱�Ƃ��]�܂�܂��B
%
% STREAMSLICE(U,V,W,Sx,Sy,Sz) �́A���̃X�e�[�g�����g�����肵�Ă��܂��B
% 
%       [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% �����ŁA[M,N,P] = SIZE(V) �ł��B
%
% STREAMSLICE(X,Y,U,V) �́A�x�N�g���f�[�^ U,V ����(���ŕ���������)
% �X�g���[�����C����`�悵�܂��B�z�� X,Y �́AU,V �Ɋւ�����W���`���A
% �P����(MESHGRID �ō쐬����)2�����i�q�����Ă��Ȃ���΂Ȃ�܂���B
%
% STREAMSLICE(U,V) �́A���̃X�e�[�g�����g�����肵�Ă��܂��B
% 
%       [X Y] = meshgrid(1:N, 1:M)
% 
% �����ŁA[M,N] = SIZE(V) �ł��B
%
% STREAMSLICE(..., DENSITY) �́A�X�g���[�����C���̎����I�Ɍ��肵���Ԋu��
% �ύX���܂��BDENSITY ��0�ȏ�łȂ���΂Ȃ�܂���B�f�t�H���g�l��1�ł��B
% �傫�Ȓl�́A�e���ʂł�葽���̃X�g���[�����C�����쐬���܂��B���Ƃ��΁A
% 2�́A�����悻�{�̃X�g���[�����C����`�悵�A0.5 �͔����̐��̃X�g���[��
% ���C����`�悵�܂��B
% 
% STREAMSLICE(...,'arrows') �́A���ŕ����������܂�(�f�t�H���g)�B
% STREAMSLICE(...,'noarrows') �́A��������������\�����܂���B
%
% STREAMSLICE(...,'method') �́A�g�p������}�@��ݒ肵�܂��B'method' �́A
% 'linear','cubic','nearest' ��ݒ肷�邱�Ƃ��ł��܂��B'linear' ���f�t�H���g
% �ł�(INTERP3 ���Q��)�B
% 
% STREAMSLICE(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = STREAMSLICE(...) �́ALINE �I�u�W�F�N�g�̃n���h���ԍ����x�N�g����
% ���ďo�͂��܂��B
%
% [VERTICES ARROWVERTICES] = STREAMSLICE(...) �́A�X�g���[�����C����
% ����`�悷�邽�߂ɁA���_��2�̃Z���z����o�͂��܂��B�����́A�C�ӂ�
% �X�g���[�����C����`�悷��֐�(streamline)�ɓn�����Ƃ��ł��܂��B
%
% ��� 1:
%      load wind
%      daspect([1 1 1])
%      streamslice(x,y,z,u,v,w,[],[],[5]); 
%
% ��� 2:
%      load wind
%      daspect([1 1 1])
%      [verts averts] = streamslice(u,v,w,10,10,10); 
%      streamline([verts averts]);
%      spd = sqrt(u.*u + v.*v + w.*w);
%      hold on; slice(spd,10,10,10);
%      colormap(hot)
%      shading interp
%      view(30,50); axis(volumebounds(spd));
%      camlight; material([.5 1 0])
%
% ��� 3:
%      z = peaks;
%      surf(z); hold on
%      shading interp;
%      [c ch] = contour3(z,20); set(ch, 'edgecolor', 'b')
%      [u v] = gradient(z); 
%      h = streamslice(-u,-v);  %ownhill 
%      set(h, 'color', 'k')
%      for i = 1:length(h); 
%        zi = interp2(z,get(h(i), 'xdata'), get(h(i),'ydata'));
%        set(h(i),'zdata', zi);
%      end
%      view(30,50); axis tight
%
% �Q�l�FSTREAMLINE, SLICE, CONTOURSLICE.


%   Copyright 1984-2002 The MathWorks, Inc. 
