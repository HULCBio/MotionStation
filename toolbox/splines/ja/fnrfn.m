% FNRFN   F �ɑ΂���敪�ɒǉ��̃T�C�g��}��
%
% FNEW = FNRFN(F) �� FNRFN(F,'mid') �́A���ɓ����`���ŁAF �ɂ���֐���
% �L�q���o�͂��܂����A���̋敪�Ԋu�̂��ꂼ��ɒ��_��}�����邱�Ƃɂ��
% ���ǂ��ꂽ�敪�Ƃ��ďo�͂��܂��B
%
% FNEW = FNRFN(F,ADDPTS) �́A�����`���ŁAF �ɂ���֐��̋L�q���o�͂���
% �����AADDPTS �̗�ŁA�T�C�g��}�����邱�Ƃŉ��ǂ����敪���o�͂��܂��B
% ADDPTS ����̏ꍇ�A�ǉ������T�C�g�͂���܂���B
%
% �֐���B-�^�̏ꍇ�AADDPTS �́A�X�v���C���̎����𒴂��Đߓ_�̑��d�x
% �𑝉������Ȃ��͈͂ŁA�ǉ�����ߓ_�Ƃ��ĉ��߂���܂��B
%
% �֐���pp-�^�ł���ꍇ�A�u���[�N�|�C���g�̗�ɂ܂����݂��Ȃ� ADDPTS ��
% �e�v�f���A�ǉ��̃u���[�N�|�C���g�Ƃ��Ďg�p����܂��B
%
% F �ɂ���֐���m�ϐ��֐��̏ꍇ�AADDPTS �́A���� m �̃Z���z��łȂ����
% �Ȃ�܂���B����j�Ԗڂ̃Z���́A��������΁Aj�Ԗڂ̕ϐ��ɒǉ��̃T�C�g
% ���w�肵�܂��B
%
% ���:
% B-�^�X�v���C�����쐬���ăv���b�g���A���̌�A2�̒��_��p�������ǂ�
% �K�p���܂��B����ɁA���ǂ��ꂽ���ʂ̃X�v���C���̐��䑽�p�`���A�X�v���C��
% ���g�ɔ��ɋ߂����̂ł���Ƃ݂Ȃ��A�v���b�g���܂��B
%
%      k = 4; sp = spapi( k, [1,1:10,10], [cos(1),sin(1:10),cos(10)] );
%      fnplt(sp), hold on
%      sp3 = fnrfn(fnrfn(sp));
%      plot( aveknt( fnbrk(sp3,'knots'),k), fnbrk(sp3,'coefs'), 'r')
%      hold off 
%
% ��3�̉��ǂł́A2�̋Ȑ�����ʂł��Ȃ��悤�ɂ��܂��B
%
% ���̗�Ƃ��āA��������������2��B-�X�v���C���������邽�߂ɁAFNRFN 
% ���g�p���܂��B
%
%      B1 = spmak([0:4],1); B2 = spmak([2:6],1);
%      B1r = fnrfn(B1,fnbrk(B2,'knots'));
%      B2r = fnrfn(B2,fnbrk(B1,'knots'));
%      B1pB2 = spmak(fnbrk(B1r,'knots'),fnbrk(B1r,'c')+fnbrk(B2r,'c'));
%      fnplt(B1,'r'),hold on, fnplt(B2,'b'), fnplt(B1pB2,'y',2)
%      hold off
%   
% �Q�l : PPRFN, SPRFN, FNCMB.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
