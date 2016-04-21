% SPAPI   �X�v���C�����
%
% SPAPI(KNOTS,X,Y)      (KNOTS �� X �͗����Ƃ��x�N�g��)
% �́A���ׂĂ� j �ɂ��� Y(:,j) �� f(X(j)) �ɓ������Ȃ�ߓ_�� KNOTS ��
% ������
%         k := length(KNOTS) - length(X)
% �̃X�v���C�� f ��(���݂����)�o�͂��܂��B
% ����́A�������̃f�[�^�T�C�g���J��Ԃ��ꂽosculatory�̈Ӗ��ŁA
% ���Ȃ킿�Am(j) := #{ i<j : X(i) = X(j) } ���� D^m(j) f �� f ��m(j)�Ԗ�
% �̔����ł���Ƃ��ɁAD^m(j) f(X(j)) = Y(:,j) �����藧�Ƃ����Ӗ���
% ���߂���܂��B���̃f�[�^�l Y(:,j) �́A�X�J���A�x�N�g���A�s��A�܂���
% N�����z��ł��B
%
% SPAPI(K,X,Y)          (K �͐��̐���)
% �́ASPAPI(APTKNT(sort(X),K),X,Y) �Ɠ����ł��B���Ȃ킿�A�K�؂Ȑߓ_���
% X �� K ���瓾�邽�߂� APTKNT ���g�p���܂��B
%
% SPAPI({KNOTS1,...,KNOTSm},{X1,...,Xm},Y)
% �́Ai=1,...,m �Ƃ��āAi�Ԗڂ̕ϐ��ɐߓ_�� KNOTSi �����g�ݍ��킹����
%      ki := length(KNOTSi) - length(Xi)
% ��m�ϐ��e���\���σX�v���C���� SP �ɏo�͂��܂��B����ɑ΂��ẮA���ׂĂ� 
% j := (j1,...,jm) �ɂ��� Y(:,j1,...,jm) = f(X1(j1),...,Xm(jm)) ������
% �����܂��B
% 1�ϐ��̏ꍇ�̂悤�ɁAKNOTSi �����̐����ł��邩������܂���B���̏ꍇ�A
% i�Ԗڂ̐ߓ_�� APTKNT �ɂ���� Xi ���瓾���܂��B
% d�v�f�̒l�̃f�[�^�ւ̕�Ԃ̉\���ɒ��ڂ��܂��B1�ϐ��̏ꍇ�ƈقȂ�A
% ��Ԃ����f�[�^���X�J���l�Ȃ�΁A���͔z�� Y �́Am�����ɂ��邱�Ƃ�
% �ł��܂��B���̏ꍇ�A���ׂĂ� 
% j := (j1,...,jm) �ɑ΂��āAY(j1,...,jm) = f(X1(j1),...,Xm(jm)) ��
% �Ȃ�܂��B
% �� Xi �̑��d�x�́A���傤��1�ϐ��̏ꍇ�̂悤�ɕ�Ԃ��ڐG(osculatory)
% ���܂��B
%
% ���Ƃ��΁A�x�N�g�� t ���̓_���A���ׂĈقȂ�ꍇ�A
%
%      sp = spapi(augknt(t,4,2),[t t],[cos(t) -sin(t)]);
%
% �́At ���̓_�Ŋ֐� f(x) = cos(x) �� C^1 �̋敪�I�ȃL���[�r�b�N�G��
% �~�[�g��Ԃ�^���܂��B���z�̈�v�������At �̍��[�ƉE�[�̓_���܂��
% ���邪�����I�ł���� s �ŗv�������ꍇ�A�����
%
%      sp = spapi( augknt([t s],4), [t s], [cos(t) -sin(s)] );
%
%
% �܂��́A�����P��
%
%      sp = spapi( 4, [t s], [cos(t) -sin(s)] );
%
% ���g�p���܂��Bs �� t �̒[�_���܂ނ̂Ɏ��s���A�����̃G���~�[�g�f�[�^ 
% �� C^2 �̋敪�I�ȃL���[�r�b�N��Ԃ�^����Ƃ��Ă��A�Ō�̂��̂͋@�\
% ���܂��B
%
% �ʂ̗�Ƃ��āA
%
%      sp = spapi( {[0 0 1 1],[0 0 1 1]}, {[0 1],[0 1]}, [0 0;0 1] );
%
% �́A���L�X�e�[�g�����g���s���悤�ɁA�l�p�`�̋��̒l�ւ̑o�ꎟ��Ԃ�
% �\�����܂��B
%
%      sp = spapi({2,2},{[0 1],[0 1]},[0 0;0 1]);
%
% �ʂ̗�Ƃ��āA�X�e�[�g�����g
%
%      x = -2:.5:2; y=-1:.25:1; [xx, yy] = ndgrid(x,y); 
%      z = exp(-(xx.^2+yy.^2)); 
%      sp = spapi({3,4},{x,y},z);
%      fnplt(sp)
%
% �́A2�ϐ��֐��ւ�(x �ɂ��ċ敪�I��2�����Ay �ɂ��ċ敪�I��3������
% ����)��Ԃ̐}�𐶐����܂��B
% ������ NDGRID �̑���� MESHGRID ���g�p����ƁA�G���[�ɂȂ�܂��B
%
% �O���b�h�����ꂽ�f�[�^�ւ̐ڐG���(osculatory interpolation)�̐�����
% ���āA���S�ȑo�O����Ԃ������܂��B�����ŁA�f�[�^�͑o�O�������� 
% g(x,y) = x^3y^3 ���疾���I�ɓ�����邽�߁A���z��A���z�̌��z(���Ȃ킿�A
% ��������(cross derivative))���^����ꂽ�f�[�^�l�̂ǂ��Ɉʒu�t�����
% �Ȃ���΂Ȃ�Ȃ����𐳊m�ɗ\�z���邱�Ƃ��e�Ղł��Bg �͑o�O����������
% ���邽�߁A��� f �́Ag ���̂��̂łȂ���΂Ȃ�܂���B������e�X�g
% ���܂��B
%
%      sites = {[0,1],[0,2]}; coefs = zeros(4,4); coefs(1,1) = 1;
%      g = ppmak(sites,coefs);
%      Dxg = fnval(fnder(g,[1,0]),sites);
%      Dyg = fnval(fnder(g,[0,1]),sites);
%      Dxyg = fnval(fnder(g,[1,1]),sites);
%      f = spapi({4,4}, {sites{1}([1,2,1,2]),sites{2}([1,2,1,2])}, ...
%               [fnval(g,sites), Dyg ; ...
%                Dxg.'         , Dxyg]);
%      if any( squeeze( fnbrk(fn2fm(f,'pp'), 'c') ) - coefs )
%        'something went wrong', end
%
% �Q�l : SPAPS, SPAP2.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
