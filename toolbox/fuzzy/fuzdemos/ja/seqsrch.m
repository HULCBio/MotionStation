% SEQSRCH �́AANFIS ���f�����O SEQSRCH �̒��̓��͕��ɑ΂���A���I�őO��
% ���ȒT��
%
% SEQSRCH �́AANFIS ���f�����O�p�̓��͌��̏W����1����4�܂ł̓��͂�I��
% ���Ȃ���A���I�ȑO�����T�����s���܂��B
% 
% SEQSRCH �́AM �̌�₩�� N �̓��͂�I���������ꍇ�A(2*M-N+1)*N/2 
% ��� ANFIS ���f�����O�v���Z�X�����s���܂��B
% 
%	�g�p�@:
%	[INPUT_INDEX, ELAPSED_TIME] = ...
%	SEQSRCH(IN_N, TRN_DATA, CHK_DATA, INPUT_NAME, MF_N, EPOCH_N)
%
%	INPUT_INDEX  : SEQSRCH �Ɉ˂�I���������͌Q�̃C���f�b�N�X
%	ELAPSED_TIME : ���͕��̒��ł̌o�ߎ���
%	IN_N         : ���͌�₩��I���������͐�
%		       (����́A1����4�̊Ԃ̐����Ƃ��܂�)
%	TRN_DATA     : �I���W�i���̌P���f�[�^
%	CHK_DATA     : �I���W�i���̃`�F�b�N�f�[�^
%	INPUT_NAME   : ���ׂĂ̓��͌��ɑ΂�����͖�
%		       (�I�v�V�����ŁA�f�t�H���g�́A'in1', 'in2', 'in3' 
%                      ���ł�)
%	MF_N         : �e���͗p�̃����o�[�V�b�v�֐��̔ԍ�
%		       (�I�v�V�����ŁA�f�t�H���g�� 2�ł�)
%	EPOCH_N      : ANFIS�p�̌P���񐔂̔ԍ�
%		      (�I�v�V�����ŁA�f�t�H���g��1�ł�)
% �����Ԃ̔R��(1�K�����ł̃}�C����)�\���p�̑I����͂̃Z���t�f���ł́A
% EXHSRCH �Ɠ���
%
% �Q�l  SEQSRCH.
		
%45 %%%%%%%%%%%%%%%

