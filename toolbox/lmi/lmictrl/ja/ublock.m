% block = ublock(dims,bound,type)
%
% �s�m���Ȑ��`�V�X�e���̐��`�����\���̒��ɓ���X�̕s�m���ȃu���b�N���
% �肵�܂��B
%
% ���́F
%  DIMS     �u���b�N�̎����BDIMS = 3 �́A3�s3��̃u���b�N���Ӗ����ADIMS 
%           = [1 2] �́A1�s2��̃u���b�N���Ӗ����܂��B
%  BOUND    �s�m�����̎��I�ȏ��F
%            * �m�����ɂ��͈͕t���s�m����
%                BOUND �́A��l�͈͂ɑ΂��Ă͐��̃X�J���A�܂��́A���g��
%                �d�݂ɂ��͈͂ɑ΂��Ă�SISO �V�X�e�� W �̂����ꂩ���g
%                �p���܂��B
%                      | Delta (jw) | <  | W(jw) |
%            * �Z�N�^�ɂ��͈͕t���s�m����
%                �Z�N�^ {a,b}�̒��̕s�m�����̒l�ɑ΂��Ă� BOUND = [a,b] 
%                �Őݒ肵�܂��B
%  TYPE     �s�m�����̃v���p�e�B��ݒ肷�镶����
%            * �����F  'lti'   -> ���`���s�� (�f�t�H���g)
%                      'ltv'   -> ���`����
%                      'nl'    -> �C�ӂ̔���`
%                      'nlm'   -> ����`�������[���X
%            * �\���F      'f' -> �t���u���b�N(�f�t�H���g)
%                          's' -> �X�J���u���b�N d*eye(DIMS)
%            * �l�F        'c' -> ���f���l(�f�t�H���g)
%                          'r' -> �����l
% �o�́F
%  BLOCK    ���̏����i�[�����x�N�g��
%
% ���F1��菬�����Q�C��������2�s3���LTI �s�m�����u���b�N���`�����
%       �́A���̂悤�ɓ��͂��Ă��������B
%                  block = ublock ([2 3],1,'ltifc')
%        ���̃X�e�[�g�����g�����l�Ȍ��ʂ��o�͂��܂��B
%                  block = ublock ([2 3],1)
%
% �Q�l�F    UINFO, UDIAG, SLFT, AFF2LFT.



% Copyright 1995-2002 The MathWorks, Inc. 
