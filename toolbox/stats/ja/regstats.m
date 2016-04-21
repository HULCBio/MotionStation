% REGSTATS   ���`���f���ɑ΂����A�f�f
%
% REGSTATS(RESPONSES,DATA,MODEL) �́A�s�� DATA �̒l�ɑ΂��āA�x�N�g�� 
% RESPONSES�Őݒ肳�ꂽ�����ŁA��A�ߎ����s���܂��B�֐��́A���[�U�C���^
% �t�F�[�X���쐬���A�`�F�b�N�{�b�N�X�Q�ɐf�f���v�ʂ�\�����A�w�肵����
% �����Ńx�[�X���[�N�X�y�[�X�ɃZ�[�u���܂��BMODEL �́A��A���f���̎���
% ���R���g���[�����܂��B�f�t�H���g�ł́AREGSTATS �́A �萔���������`
% ���Z���f���ɑ΂���݌v�s����o�͂��܂��B
%
% MODEL �ɂ́A���̕�������g�p���邱�Ƃ��ł��܂��B
%   'linear'        - �萔�A���`�����܂�
%   'interaction'   - �萔�A���`���A�N���X�ς̍����܂�
%   'quadratic'     - ���ݍ�p�ɓ�捀��ǉ�
%   'purequadratic' - �萔�A���`���A��捀���܂�
%
% �W���̏��Ԃ́A�֐� X2FX�ɂ���`����鏇�Ԃł��B
%
% STATS=REGSTATS(RESPONSES,DATA,MODEL,WHICHSTATS)�́AWHICHSTATS��
% ���X�g���ꂽ���v�ʂ��܂ޏo�͍\����STATS���쐬���܂��B
% WHICHSTATS�́A'leverage'�̂悤�ȒP��̖��O�A���邢�́A
% {'leverage' 'standres' 'studres'}�̂悤�Ȗ��O�̃Z���z��̂����ꂩ
% �ɂȂ�܂��B�g�p�\�Ȗ��O�́A���̂悤�ɂȂ�܂��B
%
%      ���O          �Ӗ�
%      'Q'           X��QR ���������Q
%      'R'           X��QR ���������R
%      'beta'        ��A�W��
%      'covb'        ��A�W���̋����U
%      'yhat'        �����f�[�^�̃t�B�b�e���O�����l
%      'r'           �c��
%      'mse'         ���ϓ��덷
%      'leverage'    Leverage
%      'hatmat'      Hat (�ˉe) �s��
%      's2_i'        Delete-1 ���U
%      'beta_i'      Delete-1 �W��
%      'standres'    �W�������ꂽ�c��
%      'studres'     �X�`���[�f���g�����ꂽ�c��
%      'dfbetas'     ��A�W���̃X�P�[�����ꂽ�ω�
%      'dffit'       �t�B�b�e���O���ꂽ�l�ɂ�����ω�
%      'dffits'      �t�B�b�e���O���ꂽ�l�ɂ�����X�P�[�����ꂽ�ω�
%      'covratio'    �����U�̕ω�
%      'cookd'       Cook�̋���
%      'tstat'       �W���ɑ΂���t���v��
%      'fstat'       F���v��
%      'all'         ��L�̓��v�ʂ����ׂĐ�������
%
% ���:  Hald�f�[�^�ɑ΂���c���ƃt�B�b�g�����l���v���b�g���܂��B
%      load hald
%      s = regstats(heat,ingredients,'linear',{'yhat','r'});
%      scatter(s.yhat,s.r)
%      xlabel('Fitted Values'); ylabel('Residuals');
%
% �Q�l : LEVERAGE, STEPWISE, REGRESS.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:54 $ 
