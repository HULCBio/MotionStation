% PATCH   patch�̍쐬
% 
% PATCH(X,Y,C) �́A�x�N�g�� X �� Y �Œ�`�����"patch"�܂���2�����̑��p�`���A
% �J�����g�̎��ɒǉ����܂��BX �� Y �������T�C�Y�̍s��̏ꍇ�A�񂲂Ƃ�
% 1�̑��p�`("��")���ǉ�����܂��BC �́A��("���R"�ȐF�t��)�܂��͒��_
% ("��Ԃ��ꂽ"�J���[�����O)�̃J���[���w�肵�܂��B���p�`�̓����̃J���[��
% �w�肷�邽�߂ɁA���`��Ԃ��g�p����܂��B
% 
% X �� Y ���x�N�g���܂��͍s��ɑ΂��āAC ��������̏ꍇ�A�e�ʂ�'color'��
% �h��Ԃ���܂��B'color' �́A'r','g','b','c','m','y','w','k' �̂����ꂩ
% �ł��BC ���X�J���̏ꍇ�A�J���[�}�b�v���C���f�b�N�X�t�����āA�ʂ̃J���[��
% �w�肵�܂��B1�s3��̃x�N�g�� C �́A�J���[�𒼐ڎw�肷��RGB��3�v�f��
% ���肳��܂��B
%
% X �� Y ���x�N�g���̂Ƃ��AC �����������̃x�N�g���̏ꍇ�A�e���_�̃J���[��
% �J���[�}�b�v�̃C���f�b�N�X�Ƃ��Ďw�肵�A���`��Ԃ��g�p���đ��p�`�̓�����
% �J���[���w�肵�܂�("��Ԃ��ꂽ"�V�F�[�f�B���O)�B
%
% X �� Y ���s��̂Ƃ��An�� X �� Y �̗񐔂ŁAC ��1�sn��̏ꍇ�A�e�� 
% j = 1:n �́A�J���[�}�b�v�̃C���f�b�N�X C(j) �ɂ���ĕ��R�ȃJ���[�����O��
% �s���܂��BC ��1�s3��̏ꍇ�́A���RGB��3�v�f ColorSpec �Ɖ��肳��A
% �e�ʂɑ΂��ē������R�ȃJ���[���w�肷�邱�Ƃɒ��ӂ��Ă��������BC �� X �� 
% Y �Ɠ����T�C�Y�̍s��̏ꍇ�A���_�̃J���[���J���[�}�b�v�̃C���f�b�N�X
% �Ƃ��Ďw�肵�A�ʂ��J���[�����O����̂ɐ��`��Ԃ��g�p����܂��B
% C ��1xnx3�̏ꍇ�An�� X �� Y �̗񐔂̂Ƃ��A�e��j��RGB��3�v�f C(1,j,:) ��
% ����ĕ��R�ȃJ���[�����O������܂��BC ��mxnx3�̏ꍇ�AX �� Y ��m�sn���
% �Ƃ��A�e���_ (X(i,j),Y(i,j)) �́ARGB��3�v�f C(i,j,:) �ɂ���ăJ���[�����O
% ����A�ʂ͕�Ԃ��g���ăJ���[�����O����܂��B
%
% PATCH(X,Y,Z,C )�́A3�������W��patch���쐬���܂��BZ �́AX �� Y �Ɠ���
% �T�C�Y�łȂ���΂Ȃ�܂���B
%
% PATCH�́APatch�I�u�W�F�N�g�̃n���h���ԍ����o�͂��܂��BPatch�́AAXES
% �I�u�W�F�N�g�̎q�ł��B
%
% X,Y,C ��3�v�f(3�����ɑ΂��Ă� X,Y,Z,C ��4�v�f)�̌�ɁAPatch�̃v���p�e�B
% ���w�肷�邽�߂ɁA�p�����[�^�ƒl�̑g���킹�𑱂��邱�Ƃ��ł��܂��BX,Y,C
% ��3�v�f(3�����ɑ΂��Ă� X,Y,Z,C ��4�v�f)���ȗ����āA�p�����[�^�ƒl��
% �g���킹���g���Ă��ׂẴv���p�e�B���w��ł��܂��B
%
% �p�b�`�I�u�W�F�N�g�́A�v���p�e�B Faces,Vertices,FaceVertexCData �Őݒ�
% ���ꂽ�f�[�^���g���܂�(�ڍׂ́A���t�@�����X�}�j���A�����Q��)�B������
% �v���p�e�B�́A�֗��ȃV���^�b�N�X�������Ă��܂��񂪁A�v���p�e�B�̖��O��
% �l�̑g���g���Đݒ肳��Ă��܂��BXData,YData,Zdata,Cdata �Ƃ��Ďw�肷��
% �p�b�`�f�[�^�́A�ϊ�����AFaces,Vertices,FaceVertexCData �Ƃ��āA������
% �ۑ�����A�I���W�i���̍s��Ƃ��ăX�g�A����܂���BGET �� Xdata,YData,
% Zdata,Cdata �����p���Ďg���ꍇ�A�o�͒l�́AFaces,Vertices,FaceVertexCData 
% ����ϊ�����܂��B
%
% GET(H) �́AH ��patch�I�u�W�F�N�g�̃n���h���ԍ��̂Ƃ��Apatch�I�u�W�F�N�g
% �̃v���p�e�B�Ƃ��̃J�����g�l�̃��X�g��\�����܂��BSET(H) �́Apatch
% �I�u�W�F�N�g�̃v���p�e�B�ƗL���ȃv���p�e�B�l�̃��X�g��\�����܂��B
% 
% �Q�l�FFILL, FILL3, LINE, TEXT, SHADING.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:27 $
%   Built-in function.

