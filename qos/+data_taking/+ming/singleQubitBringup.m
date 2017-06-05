% bring up qubits one by one
% GM, 2017/4/14
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\Dropbox\MATLAB GUI\USTC Measurement System\settings');
QS.SU('Ming');
QS.SS('s170602');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
import data_taking.public.util.*
import data_taking.public.xmon.*
%%
% qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
qubits = {'q10','q9','q8','q7','q6','q5','q4','q3','q2','q1'};
dips = [6.64320 6.68880 6.73840 6.77460 6.81090 6.85010 6.89200 6.93300 6.94520 6.99620]*1e9; % by qubit index
%%
data_taking.public.jpa.turnOnJPA('jpaName','impa1','pumpFreq',13.55e9,'pumpPower',5,'bias',0.00014,'on',true)
%%
ustcaddaObj.close()
%%
for ii=3:3
s21_zdc_networkAnalyzer('qubit',qubits{ii},'NAName',[],'startFreq',dips(ii)-10e6,'stopFreq',dips(ii)+2e6,'numFreqPts',500,'avgcounts',30,'NApower',-15,'amp',[-3e4:1e3:3e4],'bandwidth',10000,'notes','','gui',true,'save',true)
end
%% S21
s21_zdc('qubit', qubits{1},...
      'freq',6.5e9:2e6:7e9,'amp',0,...
      'notes','','gui',true,'save',true);
%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift
amps=[logspace(log10(1000),log10(30000),41)];
for ii = 2:2
s21_rAmp('qubit',qubits{ii},'freq',[dips(ii)-3e6:0.1e6:dips(ii)-1e6],'amp',amps,...  % logspace(log10(1000),log10(32768),25)
      'notes','HW 500M Amp, 6dB att. in, RT Amp x2','gui',true,'save',true,'r_avg',1000);
end
%%

for II=2
s21_zdc('qubit', qubits{II},...
      'freq',[dips(II)-2e6:0.1e6:dips(II)+2e6],'amp',[-5e3:0.5e3:5e3],...
      'notes',[qubits{II}],'gui',true,'save',true);
end

%%
for ii=2
s21_zpa('qubit', qubits{ii},...
      'freq',[dips(ii)-2e6:0.1e6:dips(ii)+2e6],'amp',[-3e4:3e3:3e4],...
      'notes',[qubits{ii} ', S21 vs Z pulse'],'gui',true,'save',true);
end



%% spectroscopy1_zpa_s21

for ii=2
    QS.saveSSettings({qubits{ii},'spc_driveAmp'},3000)
    data0=spectroscopy1_zpa_s21('qubit',qubits{ii},...
       'biasAmp',-3e4:1e3:3e4,'driveFreq',[6.e9:2e6:6.6e9],...
       'r_avg',500,'notes','','gui',true,'save',true,'dataTyp','P');
end
%%
data_taking.public.scripts.qubitStability('qubit','q3','Repeat',1,...
       'biasAmp',0,'driveFreq',[6.45e9:2e6:6.55e9],...
       'r_avg',1000,'notes','','gui',true,'save',true);
  
%%
amp=5e3;
QS.saveSSettings({qubits{2},'spc_driveAmp'},amp)
spectroscopy1_zpa_s21('qubit',qubits{2},...
       'biasAmp',0,'driveFreq',[5.4e9:1e6:5.9e9],...
       'notes',[qubits{2} ', spc amp: ' num2str(amp)],'r_avg',1000,'gui',true,'save',true);
%%
% setZDC('q2',-2000);
rabi_amp1('qubit','q3','biasAmp',[0],'biasLonger',10,...
      'xyDriveAmp',[0:500:3e4],'detuning',0,'driveTyp','X','notes','RT 26dB',...
      'dataTyp','P','r_avg',1000,'gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%% To do
rabi_long1('qubit','q3','biasAmp',[0],'biasLonger',10,...
      'xyDriveAmp',[1.5e4],'xyDriveLength',[10:10:1000],'detuning',[0],'driveTyp','X',...
      'dataTyp','P','r_avg',1000,'gui',true,'save',true);
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
tuneup.xyGateAmpTuner('qubit','q3','gateTyp','X','gui',false,'save',true);
%%
% QS.saveSSettings({'q2','r_amp'},0.77e4);
tuneup.optReadoutFreq('qubit','q3','gui',true,'save',true);
%%
tuneup.iq2prob_01('qubit','q3','numSamples',1e4,...
      'gui',true,'save',true)
 %% automatic function, after previous steps pined down qubit parameters, 
q = qubits{2};
tuneup.correctf01bySpc('qubit',q,'gui',true,'save',true); % measure f01 by spectrum
XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
for ii = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{ii},'gui',true,'save',true); % finds the XY gate amplitude and update to settings
end
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
%%
spectroscopy1_zdc('qubit','q2',...
       'biasAmp',[-10000:250:10000],'driveFreq',[5.e9:2e6:6.4e9],'dataTyp','S21','note','F2',...
       'r_avg',1000,'gui',true,'save',true);
%%
% ramsey_df('qubit','q4',...
%       'time',[0:400:30000],'detuning',[1]*1e6,...
%       'dataTyp','S21','notes','','gui',true,'save',true);
ramsey_df01('qubit','q3',...
      'time',[0:10:2000],'detuning',[5]*1e6,...
      'dataTyp','P','notes','','gui',true,'save',true);
%%
T1_1('qubit','q3','biasAmp',[0,1000],'time',[0:400:20e3],'biasDelay',16,...
      'gui',true,'save',true,'r_avg',1000,'fit',true)
%%
T1_1('qubit','q3','biasAmp',[2e4:0.5e3:3e4],'time',[0:400:20e3],'biasDelay',16,...
      'gui',true,'save',true,'r_avg',5000,'fit',true)
%%
T1_1_s21('qubit','q3','biasAmp',[0],'time',[0:200:10e3],'biasDelay',0,...
      'gui',true,'save',true,'r_avg',1000)
  %%
  T1_1_s21('qubit','q2','biasAmp',[-3e4:1e3:3e4],'time',[0:200:10e3],...
      'gui',true,'save',true,'r_avg',5000)