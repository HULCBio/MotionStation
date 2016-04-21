% CP2TFORM   �R���g���[���|�C���g�̑g�����ԓI�ȕϊ��𐄑�
% CP2TFORM �́A�R���g���[���|�C���g�̑g���g���āA��ԓI�ȕϊ��𐄑����܂��B%
% TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,TRANSFORMTYPE) �́A��ԓI��
% �ϊ����܂� TFORM �\���̂��o�͂��܂��BINPUT_POINTS �́A���[�U���ϊ���
% �����C���[�W�̒��ŁA�R���g���[���_��X �� Y ���W���܂� M �s 2 ��� do-
% uble �s��ł��BBASE_POINTS �́A�x�[�X�C���[�W�̃R���g���[���_��X �� 
% Y ���W���܂� M �s 2 ��� double �s��ł��BTRANSFORMTYPE �́A'linear 
% conformal', 'affine', 'projective',  'polynomial', 'piecewise linear', 
% 'lwm' �̂����ꂩ���g���܂��BTRANSFORMTYPE �̑I���Ɋւ�����ɂ���
% �́ACP2TFORM �̃��t�@�����X�y�[�W���Q�Ƃ��Ă��������B
%
% TFORM = CP2TFORM(CPSTRUCT,TRANSFORMTYPE) �́A���̓C���[�W�ƃx�[�X�C��
% �[�W�ɑ΂��āA�R���g���[���|�C���g�s����܂ލ\���� CPSTRUCT �ɋ@�\����
% ���B�R���g���[���|�C���g�I���c�[�� CPSELECT �́ACPSTRUCT ���쐬���܂��B
%
% [TFORM,INPUT_POINTS,BASE_POINTS] = CP2TFORM(CPSTRUCT,...) �́AINPUT_
% POINTS �̒��Ŏ��ۂɎg��ꂽ�R���g���[���|�C���g���o�͂��܂��B��v����
% ���Ȃ��_��\���_�́A�g���܂���BCPSTRUCT2PAIRS ���Q�Ƃ��Ă��������B
%
% TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,'polynomial',ORDER) �́AORDER
%  ���g���āA�g�p���鑽�����̎�����ݒ肵�܂��BORDER �́A2, 3, 4 �̂�����
% �����g�p���邱�Ƃ��ł��܂��BORDER ���ȗ�����ƁA�f�t�H���g�́A3 ���g��
% �܂��B
%
% TFORM = CP2TFORM(CPSTRUCT,'polynomial',ORDER) �́A�\���� CPSTRUCT �ɋ@
% �\���܂��B
%
% TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,'piecewise linear') �́A�x�[
% �X�R���g���[���|�C���g��Delaunay �̎O�p�`���쐬���A�Ή�������̓R���g��
% �[���|�C���g���x�[�X�R���g���[���|�C���g�Ƀ}�b�s���O���܂��B�}�b�s���O
% �́A�e�O�p�`�ɑ΂��āA���`(�A�t�B��)�ŁA�R���g���[���|�C���g���N���X��
% �ĘA���ł����A�X�̎O�p�`���A���ꎩ�g�}�b�s���O���ꂽ���̂ɂȂ�̂ŁA
% �����\�ł����A�A���ł͂���܂���B
%
% TFORM = CP2TFORM(CPSTRUCT,'piecewise linear') �́A�\���� CPSTRUCT �ɋ@
% �\���܂��B
%
% TFORM = CP2TFORM(INPUT_POINTS,BASE_POINTS,'lwm',N) �́A�Ǐ��I�ȏd�ݕt��
% ����(lwm)�@���g���āA�}�b�s���O���쐬���A�e�R���g���[���|�C���g�ŁA�ߖT
% �̃R���g���[���|�C���g���g���āA�������𐄒肵�܂��B�C�ӂ̈ʒu�ŁA�C��
% �̈ʒu�ł̃}�b�s���O�́A�����̑������̏d�ݕt�����ςɈˑ����܂��B�X
% �̑������𐄒肷��_�� N ���I�v�V�����Őݒ肵�܂��BN �̍ŋߖT�_�́A
% �X�̃R���g���[���|�C���g�ɑ΂��āA����2�̑������𐄘_���邽�߂Ɏg����
% ���BN ���ȗ�����ƁA�f�t�H���g��12���g���܂��BN ��6�Ƃ����悤�ɏ�������
% �邱�Ƃ��ł��܂��B�������AN ������������ƁA�������̈������������쐬��
% ��댯������܂��B
%
% TFORM = CP2TFORM(CPSTRUCT,'lwm',N) �́A�\���� CPSTRUCT ��ŋ@�\���܂��B
%
% [TFORM,INPUT_POINTS,BASE_POINTS,INPUT_POINTS_BAD,BASE_POINTS_BAD] = ...
%    CP2TFORM(INPUT_POINTS,BASE_POINTS,'piecewise linear') �́AINPUT_
% POINTS �� BASE_POINTS �̒��ɁA���ۂɎg��ꂽ�R���g���[���|�C���g���o��
% ���܂��B�����āAINPUT�QPOINTS�QBAD �� BASE_POINTS_BAD �ɁA�d�Ȃ荇����
% �O�p�`�ɂ��򉻂��������̒��_�����݂���̂ŁA�폜�����R���g���[���|�C
% ���g���o�͂��܂��B
%
% [TFORM,INPUT_POINTS,BASE_POINTS,INPUT_POINTS_BAD,BASE_POINTS_BAD] = ...
%     CP2TFORM(CPSTRUCT,'piecewise linear') �́A�\���� CPSTRUCT ��ɋ@�\
% ���܂��B
%
% TRANSFORMTYPE
% -------------
% CP2TFORM �́A�eTRANSFORMTYPE�� TFORM �𐄒肷�邽�߂ɁA�R���g���[���|
% �C���g�̍ŏ��̐���K�v�Ƃ��܂��B 
%
%       TRANSFORMTYPE         MINIMUM NUMBER OF PAIRS
%       -------------         -----------------------
%       'linear conformal'               2 
%       'affine'                         3 
%       'projective'                     4 
%       'polynomial' (ORDER=2)           6
%       'polynomial' (ORDER=3)          10
%       'polynomial' (ORDER=4)          15
%       'piecewise linear'               4
%       'lwm'                            6
%      
% TRANSFORMTYPE ���A'linear conformal', 'affine', 'projective', 'polyno-
% mial'�ŁAINPUT_POINTS �� BASE_POINTS (�܂��́ACPSTRUCT) ���A���ʂȕϊ�
% �̂��߂ɕK�v�ȃR���g���[���|�C���g�̍ŏ��������ꍇ�A�W���́A���m�ɋ�
% �܂�܂��BINPUT_POINTS �� BASE_POINTS ���A�ŏ�����葽���ꍇ�A�ŏ����
% �������܂�܂��B�֐� MLDIVIDE ���Q�Ƃ��Ă��������B
%
% ���
%   -------
%   I = checkerboard;
%   J = imrotate(I,30);
%   base_points = [11 11; 41 71];
%   input_points = [14 44; 70 81];
%   cpselect(J,I,input_points,base_points);
%
%   t = cp2tform(input_points,base_points,'linear conformal');
%
%   % �p�x�ƃX�P�[������
%   ss = t.tdata.Tinv(2,1); % ss = scale * sin(angle)
%   sc = t.tdata.Tinv(1,1); % sc = scale * cos(angle)
%   angle = atan2(ss,sc)*180/pi
%   scale = sqrt(ss*ss + sc*sc)
%
% �Q�l�F CPSELECT, CPCORR, CPSTRUCT2PAIRS, IMTRANSFORM.



%   Copyright 1993-2002 The MathWorks, Inc. 
