% LUINC   �X�p�[�X�s���SLU����
% 
% LUINC �́A2��ނ̕s���S��LU�������o�͂��܂��B�����́A�h���b�v�g��
% �����X�ƁA0���x���̃t�������ł��B�����̕����́ABICG(�o�����X�Ζ@)
% �̂悤�ȌJ��Ԃ���@�ɂ����������`�������V�X�e���ɑ΂���O�����
% �Ƃ��ėL���ł��B
%
% LUINC(X,DROPTOL) �́A�h���b�v�g�������X DROPTOL ���g���āAX �̕s���S
% LU�������s���܂��B
%
% LUINC(X,OPTS) �́A�I�v�V�������g���ĕs���SLU�������s���܂��BOPTS �́A
% �ő�4�̃t�B�[���h�����\���̂ł��B
% 
%     DROPTOL --- �s���SLU�����̃h���b�v�g�������X
%     MILU    --- �C���s���SLU
%     UDIAG   --- U�̑Ίp��̃[����u�������܂��B
%     THRESH  --- �s�{�b�g�X���b�V���z�[���h(LU���Q��)�B
%
% ���ڂ���t�B�[���h�݂̂�ݒ�ł��܂��B
%
% DROPTOL �́A�s���SLU�����ł̃h���b�v�g�������X�Ƃ��Ďg�p�����A����
% �Ȃ��X�J���ł��B���̕����́ALU�����Ɠ������@�Ōv�Z����܂��BLU������
% �قȂ�_�Ƃ��āAL��U�̊e�񂪌v�Z���ꂽ��ŁA���[�J���ȃh���b�v�g����
% ���X(X �̗�� DROPTOL * NORM )��菬������́AL�܂���U����h���b�v
% �����_��% ���B���̃h���b�v���̗B��̗�O�́A��O�p�s����qU�̑Ίp
% �v�f�ŁA����͏������Ă��ۑ�����Ă��܂��B���O�p�s����qL�̗v�f�́A
% �s�{�b�g�ɂ��X�P�[�����O�����O�Ƀe�X�g����܂��BDROPTOL = 0 ��
% �ݒ肷��ƁA�f�t�H���g�̕s���SLU�������s���܂��B
%
% MILU �́A�C���s���SLU�������Ӗ����܂��B���̒l��0(�C�����s��Ȃ�LU�����A
% �f�t�H���g)�A�܂��� 1(�C���s���SLU����)�ł��B�V���ɍ쐬���ꂽ���q�̗�
% ���炱���̗v�f�������������ɁA��O�p���qU�̑Ίp���������܂��B
%
% UDIAG �́A0�܂���1�ł��B1�̏ꍇ�́A��O�p�s��U�̑Ίp��̃[���͓���
% �ȗv�f����菜�����߂Ƀ��[�J���ȃh���b�v�g�������X�Œu���������܂��B
% �f�t�H���g��0�ł��B
%
% THRESH �́A[0,1] �̃s�{�b�g�X���b�V���z�[���h�ł��B��̑Ίp�v�f������
% ��̎�Ίp�v�f�� THRESH �{��菬�����Ƃ��A�s�{�b�g���N����܂��BTHRESH
% ��0�̂Ƃ��́A�����I�ɑΊp�̃s�{�b�g���s���܂��BTHRESH �̃f�t�H���g��1
% �ł��B
%
% ���:
%
%    load west0479
%    A = west0479;
%    nnz(A)
%    nnz(lu(A))
%    nnz(luinc(A,1e-6))
%
% A ��1887�̔�[���v�f�������A�s���SLU������16777�̔�[���v�f�������A
% �h���b�v�g�������X��1e-6�̕s���SLU������10311�̔�[���v�f��������
% �������܂��B
%
% [L,U,P] = LUINC(X,'0') �́A���x��0�Ŗ�������Ă���(���Ȃ킿�[�U�����
% ���Ȃ�)�X�p�[�X�s��̕s���SLU�������s���܂��BL �͒P�ʉ��O�p�s��ŁA
% U�͏�O�p�s��AP �͒u���s��ł��BU �́Atriu(P*X) �Ɠ����X�p�[�X�p�^�[��
% �������܂��BL �́AP*X ���[���ł��� L �̑Ίp��1�ł����O�������āA
% tril(P*X) �Ɠ����X�p�[�X�p�^�[���������܂��BL �� U �́AP*X ��0�łȂ�
% �L�����Z���ɂ��[��������܂��BL*U �͋��ɁAP*X �̃X�p�[�X�p�^�[����
% �ł̂� X �ƈ�v���܂��B
%
% [L,U] = LUINC(X,'0') �́A��O�p�s�� U ���쐬���AL �͒P�ʉ��O�p�s���
% �u���s��ł��B�]���āAnnz(L) + nnz(U) = nnz(X) + n �ł͂����Ă��AL�A
% U�AX �̃X�p�[�X�p�^�[���̔�r�͂ł��܂���BL*U �́A�X�p�[�X�p�^�\����
% �ł̂� X �ƈ�v���܂��B
%
% LU = LUINC(X,'0') �́A"L+U-I" ���o�͂��܂��BL �͒P�ʉ��O�p�s��ŁAU ��
% ��O�p�s��ŁA�u���s��̏��͎����܂��B
%
% ���:
%
%    load west0479
%    A = west0479;
%    [L,U,P] = luinc(A,'0');
%    isequal(spones(U),spones(triu(P*A)))
%    spones(L) ~ =  spones(tril(P*A))
%    D = (L*U) .* spones(P*A) - P*A
%
% spones(L) �́A�Ίp��� spones(tril(P*A)) �ƈقȂ�ʒu������܂��B�܂��A
% P*A �̔�[���v�f�̃[���A�E�g�̃L�����Z���ɂ��AL ���� spones(tril(P*A))
% �ƈقȂ�ʒu������܂��BD �́Aeps���x�̗v�f�������܂��B
% 
% LUINC �́A�X�p�[�X�s��ɑ΂��Ă̂݋@�\���܂��B
% 
% �Q�l�FLU, CHOLINC, BICG.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $
%   Built-in function.

