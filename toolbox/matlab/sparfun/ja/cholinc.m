% CHOLINC   �X�p�[�X�s���SCholesky������Cholesky��������q����
% 
% CHOLINC �́A2��ނ̕s���SCholesky�������o�͂��܂��B�����́A�h���b�v
% �g�������X�ƁA0���x���̃t�����q�����ł��B�����̕����́APCG(�O�����
% �t�������X�Ζ@)�̂悤�ȌJ��Ԃ���@�ɂ��������Ώ̐���s��V�X�e����
% ���`�������ɑ΂���O������Ƃ��ėL���ł��B
%
% R = CHOLINC(X,DROPTOL) �́A�h���b�v�g�������X DROPTOL ���g���āAX ��
% �s���SCholesky�������s���܂��B
%
% R = CHOLINC(X,OPTS) �́A�I�v�V�������g���āA�s���SCholesky�������s��
% �܂��BOPTS �́A�ő�3�̃t�B�[���h�����\���̂ł��B
% 
%     DROPTOL --- �s���S�����̃h���b�v�g�������X�ł��B
%     MICHOL  --- �C���s���SCholesky�ł��B
%     RDIAG   --- R�̑Ίp��̃[����u�������܂��B
%
% �����̂���t�B�[���h�݂̂�ݒ�ł��܂��B
%
% DROPTOL �́A�s���SCholesky�����Ńh���b�v�g�������X�Ƃ��Ďg�p�����A
% �񕉂̃X�J���ł��B���̕����́A�s�|�b�g�̃X���b�V���z�[���h�I�v�V������
% 0�ɐݒ肵(�Ίp�s�|�b�g�Ɍ���)�A�s���SLU�������s�����Ƃɂ��v�Z���܂��B
% �����āA�e��̑Ίp�v�f�̕��������g���āA�s���S��O�p�t�@�N�^�̍s U ��
% �X�P�[�����O���܂��B��[���v�f U(I,J) �́ADROPTOL*NORM(X(:,J)) ����
% �傫��(LUINC ���Q��)�̂ŁA��[���v�f R(I,J) ��
% DROPTOL*NORM(X(:,J))/R(I,I) �����傫���Ȃ�܂��BDROPTOL = 0 �Ɛݒ�
% ����ƁA�f�t�H���g�ł���s���SCholesky�������s���܂��B
%
% MICHOL �́A�C���s���SCholesky�������Ӗ����܂��B���̒l�́A0(�C������
% �Ă��Ȃ��A�f�t�H���g)�A�܂��� 1(�C������Ă���)�ł��B����́AX��
% �C���s���SLU���������s���A�o�͂��ꂽ��O�p���q����L�̂悤�ɃX�P�[
% �����O���܂��B
%
% RDIAG �́A0�܂���1�ł��B1�ł���΁A��O�p���q R �̑Ίp��̃[���͓��ق�
% �v�f������邽�߂ɁA���[�J���ȃh���b�v�g�������X�̕������Œu���������
% �܂��B�f�t�H���g��0�ł��B
%
% ���:
%
%    A = delsq(numgrid('C',25));
%    nnz(A)
%    nnz(chol(A))
%    nnz(cholinc(A,1e-3))
%
% A ��2063�̔�[���v�f�������A�s���SCholesky������8513�̔�[���v
% �f�������A�h���b�v�g�������X��1e-3�̕s���SCholesky������4835�̔�[
% ���v�f�������Ƃ������܂��B
%
% R = CHOLINC(X,'0') �́A���x��0�̃t���̗v�f����������Ă���(���Ȃ킿�A
% �[�U����Ă��Ȃ�)�����Ώ̐���X�p�[�X�s��̕s���SCholesky�������o��
% ���܂��BX ���A�L�����Z���ɂ���[���ł���ʒu�ŁAR ���[���ł����Ă��A
% ��O�p�s�� R �́Atriu(X) �Ɠ����X�p�[�X�p�^�[���ł��BX �̉��O�p�s��́A
% ��O�p�s��̓]�u�ƍl�����܂��BX �̐��萫�͗v������Ă���X�p�[�X����
% �����q�����邱�Ƃ�ۏ؂��Ȃ����Ƃɒ��ӂ��Ă��������B�����ł��Ȃ���΁A
% �G���[���b�Z�[�W���\������܂��BR'*R �́A�X�p�[�X�p�^�[���� X �ƈ�v
% ���܂��B
%
% [R,p] = CHOLINC(X,'0') �́A2�̏o�͈����������A�G���[���b�Z�[�W��\��
% ���܂���BR �����݂���΁Ap ��0�ł��B�������A�s���S���q�����݂��Ȃ���
% �΁Ap �͐��̐����ŁAR �� q = p-1 �̂Ƃ� q �s n ��̏�O�p�s��ŁAR ��
% �X�p�[�X�p�^�[���� X �� q �s n ��̏�O�p�s��̃X�p�[�X�p�^�[���ɂȂ�
% �܂��BR'*R �́A�ŏ��� q �s�� q ��̃X�p�[�X�p�^�[���� X �ƈ�v���܂��B
%
% ���:
%
%    A = delsq(numgrid('N',10));
%    R = cholinc(A,'0');
%    isequal(spones(R)�Aspones(triu(A)))
%
%    A(8,8) = 0;
%    [R2,p] = cholinc(A,'0');
%    isequal(spones(R2)�Aspones(triu(A(1:p-1,:))))
%
%    D = (R'*R) .* spones(A) - A;
%
%    D �́Aeps�̑傫���������Ă��܂��B
%
% R = CHOLINC(X,'inf') �́ACholesky-Infinity���q�������s���܂��B���̕���
% �́ACholesky�������x�[�X�ɁA����������s��Ƃ��Ď�舵���܂��B
% primal-dual���_�@���ɐ�������̃\�[�g����������̂ɗ��p�ł��܂��B
% �ʏ��Cholesky�����Ń[���s�|�b�g��������ƁACholesky-Infinity�t�@�N�^
% �̑Ίp�v�f��Inf�ɐݒ肵�A�c��̍s���[���Őݒ肵�܂��B����́A�֘A����
% ���`�������̒��ŉ��x�N�g���ɑΉ����镔���Ƀ[����ݒ肵�悤�Ƃ������
% �ł��B���ۂɁAX �͔�����Ɖ��肵�Ă���̂ŁA���̃s�|�b�g�����AInf��
% �u���������܂��B
%
% ���F�ȉ��̑Ώ̃X�p�[�X�s�񂪓��ق̏ꍇ�́ACholesky������3�Ԗڂ̍s��
% �[���s�|�b�g�Ŏ��s���܂��B�������Acholinc �́ACholesky-Infinity������
% ���ׂĂ̍s���v�Z����̂ŁA���܂������܂��B
%
%   S = sparse([1   0   3   0;
%              0  25   0  30;
%              3   0   9   0;
%              0  30   0  661])
%   [R,p] = chol(S);
%   Rinf = cholinc(S,'inf');
%
% CHOLIN C�́A�X�p�[�X�s��݂̂ɋ@�\���܂��B
%
% �Q�l�FCHOL, LUINC, PCG.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:02:30 $
%   Built-in function.
