% CONTROLSRESIZE �R���|�[�l���g�̑����y�[�W��uicontrol�����T�C�Y
% C=CONTROLSRESIZE(C)�́AC.x.LayoutManager�Ŏw�肳�ꂽuicontrol�����C�A
% �E�g���܂��BC.x.LayoutManager�́A�Z���z��A�n���h���A������A�t���[��
% �\���̂��܂ރZ���z��ł��B
%
% �e�Z���z��́A���ꎩ�g���O���b�h���`�����܂��B�O���b�h�́A���p�\�Ȑ�
% �������̋�Ԃ𒲐����āA���p�\�Ȑ��������̋�Ԃ��l�������ɉ����Ɋg��
% ���āA�_�C�i�~�b�N�ɍ쐬����܂��B
%
% �z����̊e�v�f�́A�ȉ��̂����ꂩ�łȂ���΂Ȃ�܂���B
% 
%   * �P���UIcontrol�̃n���h��(uicontrol�̃x�N�g���͗��p�ł��܂���)
%   * ���l 
%     - �X�y�[�T�Ƃ��ċ@�\���鐔�l
%     - 1�s1���[M]�̐��l�́AM�_�̃X�y�[�X�𐅕���������ѐ��������ɑ}��
%       ���܂��B
%     - 2�s1���[M N]�̐��l�́AM�_�𐅕������ɁAN�_�𐂒������ɑ}������
%       ���B
%     - M = inf�̏ꍇ�́A�X�y�[�T�̓G�f�B�b�g�{�b�N�X�Ɠ����X�y�[�X����
%       ��܂��B
%     - m = -inf�̏ꍇ�́A�X�y�[�T�͗��p�\�ȃX�y�[�X���Ƃ�܂��B
%   *������ 
%     - ������̒��ɂ́A���l�̑g���킹���������̂�����܂��B
%     - 'indent' �́A[20 1]�Ɠ����ł��B
%     - 'spacer' �́A[inf 1]�Ɠ����ł��B
%     - 'buffer' �́A[-inf 1]�Ɠ����ł��B
%   *�\���� 
%     - CONTROLSFRAME�́ACONTROLSRESIZE�ɂ���ēǂݍ��܂��\���̂��o��
%       ���܂��B'FrameContent'�t�B�[���h�́AC.x.LayoutManager�Ɠ����K��
%       �ɏ]���܂��B
%
% �Ō��UIcontrol�̍ŏ���Y�̈ʒu�́Ac.x.lowLimit�ɏo�͂���܂��Bc.x.lo-
% wLimit�����p�\�ȍŏ���Y�̈ʒu(c.x.yzero)�����������ꍇ�́Ac.x.al-
% lInvisible���K�p����"error"�X�N���[���������y�[�W�̑���ɕ\�������
% ���B
%
% �Q�l: CONTROLSMAKE, CONTROLSUPDATE, CONTROLSFRAME





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:44 $
%   Copyright 1997-2002 The MathWorks, Inc.
