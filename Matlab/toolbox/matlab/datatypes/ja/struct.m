% STRUCT   �\���̔z��̍쐬�܂��͕ϊ�
%
% S = STRUCT('field1',VALUES1,'field2',VALUES2,...) �w�肵���t�B�[���h
% �ƒl�����\���̔z����쐬���܂��B�l�̔z��VALUES1�AVALUES2...�́A����
% �T�C�Y�̃Z���z�񂩁A�X�J���̃Z���܂��͒P��̒l�łȂ���΂Ȃ�܂���B
% �l�̔z��̑Ή�����v�f�́A�Ή�����\���̔z��̗v�f�ɐݒ肳��܂��B
% ���ʂ̍\���̂̃T�C�Y�́A�l�̃Z���z��Ɠ������A�l���Z���łȂ���΁A
% 1�s1��ɂȂ�܂��B
%
% STRUCT(OBJ) �́A�I�u�W�F�N�gOBJ�𓙉��ȍ\���̂ɕϊ����܂��B�N���X��
% ���͎����܂��B
%
% STRUCT([]) �́A��̍\���̂��쐬���܂��B
%
% �Z���z����܂ރt�B�[���h���쐬����ɂ́A�Z���z��VALUE�̒��ɃZ���z���
% �u���Ă��������B���Ƃ���
%
%     s = struct('strings',{{'hello','yes'}},'lengths',[5 3])
%
% �́A ���̂悤��1x1�̍\���̂��쐬���܂��B
%
%      s = 
%         strings: {'hello'  'yes'}
%         lengths: [5 3]
%
% ���
%      s = struct('type',{'big','little'},'color','red','x',{3 4})
%
% �Q�l: ISFIELD, GETFIELD, SETFIELD, RMFIELD, FIELDNAMES, DEAL, 
%       SUBSTRUCT.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:47:51 $
%   Built-in function.

