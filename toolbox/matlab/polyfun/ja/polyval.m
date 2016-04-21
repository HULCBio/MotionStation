% POLYVAL   �������̌v�Z
% 
% Y = POLYVAL(P,X)�́AP������N+1�̃x�N�g���ŁA�������̌W����v�f�ɂ���
% �Ƃ��AX �Ōv�Z���ꂽ�������̒l�ł��B
%
%     Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)
%
% X ���s��܂��̓x�N�g���̏ꍇ�́A�������́AX �̂��ׂĂ̓_�Ōv�Z����܂��B
% �s��ɂ��Ă̌v�Z�́APOLYVALM ���Q�Ƃ��Ă��������B
%
% Y = POLYVAL(P,X,[],MU) �́AX �̑���ɁAXHAT = (X-MU(1))/MU(2) ���g��
% �܂��B���S�ƃX�P�[�����O�Ɋւ���p�����[�^ MU �́APOLYFIT �Ōv�Z�����
% �I�v�V�����̏o�͂ł��B
%
% [Y,DELTA] = POLYVAL(P,X,S) �܂��� [Y,DELTA] = POLYVAL(P,X,S,MU) �́A
% �G���[���� Y +/- delta ���쐬���邽�߂ɁAPOLYFIT �ŗ^������I�v�V����
% �o�͍\���� S ���g���܂��BPOLYFIT �ւ̃f�[�^���͂ł̃G���[���萔��
% ���U�ƓƗ��Ȑ��K���z����ꍇ�́AY +/- DELTA �́A���Ȃ��Ƃ��\����50%��
% �܂݂܂��B
%
% ���� P,X,S,MU �̃T�|�[�g�N���X
%      float: double, single
%
% �Q�l POLYFIT, POLYVALM.

%   Copyright 1984-2004 The MathWorks, Inc.
