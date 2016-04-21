% MAKERESAMPLER  ���T���v�����O�\���̂̐���
% R = MAKERESAMPLER(INTERPOLANT,PADMETHOD) �́ATFORMARRAY �� IMTRANSFORM 
% ���g���āA�ʁX�̃��T���v�����O�\���̂𐶐����܂��B���̍ł��ȒP�Ȍ^�ŁA
% INTERPOLANT �́A���̕����� 'nearest', 'linear', 'cubic' �̂����ꂩ��
% �Ȃ�܂��BINTERPOLANT �́A�����\�ȃ��T���v�����g�p������}�J�[�l����
% �w�肵�܂��BPADMETHOD �́A'replicate', 'symmetric', 'circular', 'fill', 
% 'bound' �̂����ꂩ��ݒ�ł��܂��BPADMETHOD �́A���T���v�����A���͔z��
% �̃G�b�W�̋߂���O���Ń}�b�s���O����o�͗v�f�ɒl���ǂ̂悤�ɓ��}������A
% ���蓖�Ă邩���R���g���[�����܂��B
%
% PADMETHOD �I�v�V����
% -----------------
% 'fill', 'replicate', 'circular', 'symmetric' �̏ꍇ�ATFORMARRAY�A�܂���
% IMTRANSFORM �ɂ����s�ł��郊�T���v�����O�́A2�̘_���X�e�b�v���o�R��
% �܂��B(1) ���ׂĂ̓��͕ϊ��X�y�[�X�𖞂����܂ŁAA �𖳌���t�����܂��B
% �����āA(2) �􉽊w�}�b�v�Ŏw�肵���o�͓_�ŁA���T���v�����O�J�[�l���ƕt
% �����ꂽ A �̃R���{�����[�V�������v�Z���܂��B�X�̕ϊ��Ɋ֌W�Ȃ�������
% �ʁX�Ɏ�舵���܂��B�t����Ƃ́A�p�t�H�[�}���X�⃁�����̌����I�Ȋϓ_
% �Ŏg�p���鉼�z�I�Ȃ��̂ł��B
%  
% 'circular', 'replicate', 'symmetric' �́APADARRAY �ł̎g�p�Ɠ����Ӗ���
% �����Ă��āAA �̕ϊ������ɓK�p����܂��B
%   
%     'replicate' -- �O���v�f���J��Ԃ�
%     'circular'  -- A ������I�ɌJ��Ԃ�
%     'symmetric' -- A �����E����ɑΏ̂ɌJ��Ԃ�
%   
% 'fill' �́A���͔z��̃G�b�W�̋߂��Ƀ}�b�s���O�����o�͓_�Ɋւ��āA����
% �C���[�W�ƃt���l��g�ݍ��킹�Ă���̂ŁA�ŋߖT���}���g����������������
% �X���[�Y�Ɍ�����G�b�W�����o�͂��쐬���܂��B
%  
% 'bound' �́A'fill'�Ɠ��l�ł����A�t���l�Ɠ��̓C���[�W�l��g�ݍ��킹�镔
% �����s���܂���B�}�b�v�̊O���̓_�́A�t���l�z�񂩂�l�����蓖�Ă܂��B�}
% �b�v�̓����̓]�́A'replicate' ���g���āA��舵���܂��B
% 'bound' �� 'fill' �́AINTERPOLANT ���A'nearest'�̏ꍇ�ɓ������ʂ��o��
% ���܂��B
% 
% �J�X�^���̃��T���v���̏ꍇ�A�����̋������������邱�Ƃ��ł��܂��B
% 
% INTERPOLANT �p�̃A�h�o���X�g�ȃI�v�V����
% --------------------------------
% ��ʓI�ɁAINTERPOLANT �́A���̌^�̈���g���܂��B
%
%       1. ���̕�����̈�F'nearest', 'linear', 'cubic'
%
%       2. �Z���z��F{HALF_WIDTH, POSITIVE_HALF}
%          HALF_WIDTH �́A�Ώ̂ȓ��}�J�[�l���̔����̕����w�肷�鐳�̃X�J
%          ���l�ł��BPOSITIVE_HALF �́A[0 POSITIVE_HALF] �̕�ԂŁA�K
%          ���I�ȃT���v�����O�J�[�l���l�̃x�N�g���ł��B
%
%       3. �Z���z��F{HALF_WIDTH, INTERP_FCN}
%          INTERP_FCN �́A��� [0 POSITIVE_HALF] �̒��̓��͒l�̔z���^
%          ���A���}����J�[�l���l���o�͂���֐��n���h���ł��B
%
%       4. �Z���z��v�f�́A���3�^�C�v�̈�ł��B
%
% �^ 2 �� 3 �́A�J�X�^���̓��}�J�[�l�����g�������}�Ɏg���܂��B�^ 4 �́A
% �e�����Ɋւ��āA�Ɨ��ɓ��}�@���w�肷�邽�߂Ɏg���܂��B�^ 4 �ɑ΂���Z
% ���z��̒��̗v�f���́A�ϊ������̐��ɓ��������܂��B���Ƃ��΁AINTERPO-
% LANT ���A{'nearest', 'linear', {2  KERNEL_TABLE}} �̏ꍇ�A���T���v��
% �́A�ŏ��̕ϊ������Ɋւ��āA�ŋߖT���}���g���A2�Ԗڂ̕ϊ������Ɋւ��āA
% ���`���}���A3�Ԗڂ̕ϊ������Ɋւ��āA�J�X�^���̃e�[�u���x�[�X�̓��}��
% �g���܂��B
%
% �J�X�^�����T���v��
% -----------------
% ��ɋL�q�����V���^�b�N�X�́AImage Processing Toolbox �Ƌ��ɏo�ׂ��Ă�
% �镪���\�ȃ��T���v���֐����g�� resampler �\���̂��쐬���܂��B����
% �V���^�b�N�X���g���āA���[�U�ݒ�̃��T���v�����g�p���� resampler �\��
% �̂��쐬���邱�Ƃ��ł��܂��B
%
%   R = MAKERESAMPLER(PropertyName,PropertyValue,...)  
%
% PropertyName �́A'Type', 'PadMethod', 'Interpolant', 'NDims', 'Resam-
% pleFcn', 'CustomData' �̂����ꂩ��ݒ肷�邱�Ƃ��ł��܂��B
%
% 'Type' �́A'separable'�A�܂��́A'custom' �̂ǂ��炩��ݒ肷�邱�Ƃ���
% ���A��ɁA�^����K�v������܂��B'Type' ���A'separable' �̏ꍇ�A�ݒ��
% ���鑼�̃v���p�e�B�́A'Interpolant' �� 'PadMethod' �݂̂ŁA���ʂ́A
% MAKERESAMPLER(INTERPOLANT,PADMETHOD) ���g�������̂Ɠ����ł��B'Type' 
% ���A'custom' �̏ꍇ�A'NDims' �� 'ResampleFcn' ���K�v�ƂȂ�v���p�e�C
% �ŁA'CustomData' �̓I�v�V�����ł��B'NDims' �́A���̐����ŁA�J�X�^����
% �T���v������舵���������������̂ł��BInf �l���g���āA�J�X�^���̃��T��
% �v�����C�ӂ̎�������舵�����Ƃ��ł��邱�Ƃ������܂��B'CustomData' ��
% �l�ɂ́A���񂪂���܂���B
%
% 'ResampleFcn' �́A���T���v�����O���s���֐��̃n���h���ł��B
% �֐��́A���̃C���^�t�F�[�X�Ƌ��ɃR�[������܂��B
%
%       B = RESAMPLE_FCN(A,M,TDIMS_A,TDIMS_B,FSIZE_A,FSIZE_B,F,R)
% 
% ���� A, TDIMS_A, TDIMS_B, F �Ɋւ���ڍׂ́ATFORMARRAY �ɑ΂���w���v
% ���Q�Ƃ��Ă��������B
%
% M �́A�z��ŁAB �̕ϊ��T�u�X�N���v�g��Ԃ� A �̕ϊ��T�u�X�N���v�g���
% �Ƀ}�b�s���O������̂ł��BA �� N �̕ϊ�����(N = length(TDIMS_A))�ŁAB
% �� P �̕ϊ�����(P = length(TDIMS_B))�����ꍇ�AN > 1 �ɑ΂��āANDI-
% MS(M) = P + 1 �ƂȂ�AN == 1 �̏ꍇ P �ɂȂ�ASIZE(M, P + 1) = N �Ƃ�
% ��܂��BM �̍ŏ��� P �����́A�o�͕ϊ���ԂɑΉ����ATDIMS_B �Ƀ��X�g��
% ���o�͕ϊ������̏��Ԃɏ]���āA�u������܂�(��ʂɁATDIMS_A �� TDIMS
% _B �́A���������̂���傫�����̂֕ۑ�����K�v�͂���܂��񂪁A�w�肵��
% ���T���v���ɂ��A���̂悤�Ȑ������ۂ�����ꍇ�������܂�)�B����ŁA
% SIZE(M) �̍ŏ��� P �v�f�́AB �̕ϊ������̃T�C�Y�����肵�܂��B�e�_���}
% �b�s���O�������͕ϊ����W�́ATDIMS_A �ɗ^�����鏇�Ԃɏ]���āAM ��
% �Ō�̎������ׂ��ŁA�z�u����܂��B
%
% FSIZE_A �� FSIZE_B �́AA �� B �̃t���T�C�Y�ŁATDIMS_A, TDIMS_B, SIZE(A)
% �Ɛ�������ۂK�v������ꍇ1��t�����܂��B
%
% ���
% -------
% y-�����ŃL���[�r�b�N��Ԃ�K�p���Ax-�����ōŋߖT��Ԃ�K�p���郊�T���v
% �����g���āAy-�����ɃC���[�W�������L�΂��܂�(����́A�o�L���[�r�b�N���
% ���g�����̂Ɠ����ł����A�����ł�)�B
%
%       A = imread('moon.tif');
%       resamp = makeresampler({'nearest','cubic'},'fill');
%       stretch = maketform('affine',[1 0; 0 1.3; 0 0]);
%       B = imtransform(A,stretch,resamp);
%
% �Q�l�F IMTRANSFORM, TFORMARRAY.



%   Copyright 1993-2002 The MathWorks, Inc.
