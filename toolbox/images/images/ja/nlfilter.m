% NLFILTER   ��ʓI�ȃX���C�f�B���O�𔺂��ߖT���������s
%   B = NLFILTER(A,[M N],FUN) �́A�֐� FUN �� A �̊e�X M �s N �� �̃X
%   ���C�f�B���O�u���b�N�ɓK�p���܂��BFUN �́A���͂Ƃ��� M �s N ��̃u
%   ���b�N���󂯓���A���̊֐��𖞂����o�͂��s���܂��B
%
%       C = FUN(X)
%
%   �����ŁAC �́AM �s N ��̃u���b�N X �̒��S�s�N�Z���̏o�͒l�ɂȂ��
%   ���BNLFILTER �́AA �̊e�s�N�Z���ɑ΂��āAFUN ��ǂݍ��݂܂��BNLFI-
%   LTER �́AM �s N ��̃u���b�N�ɂ��邽�߂ɁA�K�v�ȏꍇ�G�b�W�Ƀ[����
%   �t�����܂��B
%
%   B = NLFILTER(A,[M N],FUN,P1,P2,...) �́A�t���I�ȃp�����[�^ 
%   P1,P2,... �� FUN �ɓ]�����܂��B
%
%   B = NLFILTER(A,'indexed',...) �́AA �̃N���X�� double �̏ꍇ0���A
%   uint8 �̏ꍇ1��t�����ăC���f�b�N�X�t���C���[�W�Ƃ��� A ����������
%   ���B
%
%   �N���X�T�|�[�g
% -------------
%   ���̓C���[�W A �́AFUN ���T�|�[�g���Ă���N���X���g�����Ƃ��ł���
%   ���BB �̃N���X�́AFUN ����̏o�͂̃N���X�Ɉˑ����܂��B
%
%   ����
%   ----
%   NLFILTER �́A�傫�ȃC���[�W����������̂ɒ����Ԃ�K�v�Ƃ��܂��B��
%   �̂悤�ȏꍇ�A�֐� COLFILT �́A������������葬���s���܂��B
%
%   ���
%   ----
%   FUN �́A@ ���g���č쐬����� FUNCTION_HANDLE �ł��B���̗��́A
%   3�s3��̋ߖT�� MEDFILT2 �ŏ����������ʂƓ��l�ł��B
%
%       B = nlfilter(A,[3 3],@myfun);
%
%   �����ŁAMYFUN �́A���̓��e���܂� M-�t�@�C���ł��B
%
%       function scalar = myfun(x)
%       scalar = median(x(:));
%
%   FUN �́A�C�����C���I�u�W�F�N�g�ł��\���܂���B��̗��́A���̂�
%   ���ɂ��\���ł��܂��B
%
%       fun = inline('median(x(:))');
%       B = nlfilter(A,[3 3],fun);
%
%   �Q�l�FBLKPROC, COLFILT, FUNCTION_HANDLE, INLINE



%   Copyright 1993-2002 The MathWorks, Inc.
