% IDWTPER2�@ �P�ꃌ�x���̋t���U2�����E�F�[�u���b�g�ϊ�(�����I�Ȏ�舵��)
% X = IDWTPER2(CA,CH,CV,CD,'wname') �́A�f�[�^�̎����������������t�E�F�[�u���b�g
% �ϊ����g���āA�ݒ肵�����x���� Approximation �s�� CA �� Detail �s�� CH�ACV�ACD
% ���x�[�X�ɂ��āA�P�ꃌ�x���ł̍č\�� Approximation �W���s�� X ���v�Z���܂��B
% 'wname' �́A�E�F�[�u���b�g���̕��������ł�(WFILTER ���Q��)�B
%
% �E�F�[�u���b�g���̑���Ƀt�B���^��ݒ肷�邱�Ƃ��ł��܂��BX = IDWTPER2(...
% CA,CH,CV,CD,Lo_R,Hi_R) �ɑ΂��āA
%   Lo_R �́A�č\�����[�p�X�t�B���^
%   Hi_R �́A�č\���n�C�p�X�t�B���^�ł��B
%
% sa = size(CA) = size(CH) = size(CV) = size(CD) �̏ꍇ�Asize(X) = 2*sa ��������
% �܂��B
%
% X = IDWTPER2(CA,CH,CV,CD,'wname',S)�A�܂��́AX = IDWTPER2(CA,CH,CV,CD,...
% Lo_R,Hi_R,S) �ɑ΂��āAS �͏o�͂̃T�C�Y�ƂȂ�܂��B
%
% �Q�l�F DWTPER2.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
