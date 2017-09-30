% bring up qubits one by one
data_taking.ming.InitMeasure
import data_taking.public.util.*
import data_taking.public.xmon.*
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.util.readoutFreqDiagram
%%
ustcaddaObj.close()

%%
for II=1:numel(qubits)
    setQSettings('r_fr',dips(II),qubits{II});
end
%%
setQSettings('r_fc',6.73255e9)
%%
setQSettings('r_avg',0.5e3)
%%
setQSettings('spc_sbFreq',400e6);
setQSettings('spc_driveLn',6e3);
%%
setQSettings('zdc_amp',0);
%%
for II=1:12
setQSettings('channels.z_dc.chnl',II,['q' num2str(II)]);
end
%%
setQSettings('channels.xy_mw.chnl',3);
setQSettings('qr_xy_uSrcPower',7);
%%
setQSettings('channels.r_mw.instru','mwSrc_sc5511a');
setQSettings('channels.r_mw.chnl',1);
setQSettings('r_uSrcPower',-7);
%%
setQSettings('g_XY_ln',60)
setQSettings('g_XY2_ln',30)
setQSettings('g_XY4_ln',15)
%%
for II=1:numel(qubits)
    setZDC(qubits{II},0);
end
%%
readoutFreqDiagram(qubits,200e6)
%%
data_taking.public.jpa.turnOnJPA('jpaName','impa1','pumpFreq',13.55e9,'pumpPower',5,'bias',0.00014,'on',true)
%% S21
s21_rAmp('qubit', qubits{1},...
    'freq',dips(1)-1e6:0.5e6:dips(end)+1e6,'amp',1e4,...
    'notes','H5H6','gui',true,'save',true);
%%
s21_rAmp('qubit', qubits{1},...
    'freq',6.e9:1e6:7.e9,'amp',1e4,...
    'notes','','gui',true,'save',true);
%%
for II=1:numel(qubits)
    s21_zdc_networkAnalyzer('qubit',qubits{II},'NAName',[],'startFreq',dips(II)-3e6,'stopFreq',dips(II)+3e6,'numFreqPts',500,'avgcounts',5,'NApower',-20,'biasAmp',[-3e4:1e3:3e4],'bandwidth',2000,'notes','','gui',true,'save',true)
end
%%
for II=1:numel(qubits)
    s21_zdc('qubit', qubits{II},...
        'freq',[dips(II)-1e6:0.1e6:dips(II)+2e6],'amp',[-3e4:3e3:3e4],...
        'notes',[qubits{II}],'gui',true,'save',true);
end

%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift
amps=[logspace(log10(1000),log10(30000),41)];
for II =  2
    data1{II}=s21_rAmp('qubit',qubits{II},'freq',[dips(II)-1.e6:0.05e6:dips(II)+2.e6],'amp',amps,...  % logspace(log10(1000),log10(32768),25)
        'notes','30dB @ RT','gui',true,'save',true,'r_avg',500);
end
%% figure out dispersive shift
for II=[1 2 3]
    dd=abs(cell2mat(data1{1,II}.data{1,1}));
    z_ = 20*log10(abs(dd));
    sz=size(z_);
    for jj = 1:sz(2)
        z_(:,jj) = z_(:,jj) - z_(1,jj);
    end
    frqs=dips(II)+(-0.5e6:0.05e6:2.5e6);
    [~,mm]=min(z_);
    figure;surface(frqs,amps,z_','edgecolor','none')
    hold on;plot3(frqs(mm),amps,100*ones(1,length(amps)),'-or')
    set(gca,'YScale','log')
    axis tight
    colormap('jet')
    title(qubits{II})
end
%% Set all dispersive readout point
% r_freq=[6.849e9 6.819e9 6.794e9 6.755e9 6.708e9 6.683e9 6.66e9 6.642e9 6.624e9 6.591e9];
r_amp=[1.392e4 1.29e4 1.024e4 9487 1.024e4 8786 7536];
for II=1:numel(r_amp)
%     setQSettings('r_freq',r_freq(II),qubits{11-II});
    setQSettings('r_amp',r_amp(II),qubits{II});
end
%% Get all S21 curves with current readout setup, and update r_freq
for II=2
    r_freq=getQSettings('r_fr', qubits{II});
    s_r_freq=r_freq-0.5e6:0.025e6:r_freq+3e6;
    data2{II}=s21_rAmp('qubit', qubits{II},...
        'freq',s_r_freq,'amp',getQSettings('r_amp', qubits{II}),...
        'notes',qubits{II},'gui',true,'save',true);
    dat=smooth(abs(cell2mat(data2{1,II}.data{1,1})),3)';
    [~,lo]=min(dat);
    r_freq1=s_r_freq(lo)
    setQSettings('r_freq',r_freq1,qubits{II});
end
%% for High power readout
Damp=logspace(0,4.5,51);
for II=2
    data=s21_rAmp('qubit', qubits{II},...
        'freq',6.742e9,'amp',Damp,...
        'notes','0dB @ RT pump','gui',true,'save',true);
    data1=cell2mat(data.data{1,1});
    figure;semilogx(Damp,abs(data1))
    xlabel([qubits{II} ' Readout Amp'])
    ylabel('|IQ|')
end
%% S21_ZPA
for II=1:numel(qubits)
    s21_zpa('qubit', qubits{II},...
        'freq',[dips(II)-1e6:0.1e6:dips(II)+1e6],'amp',[-3e4:6e3:3e4],...
        'notes',[qubits{II} ', S21 vs Z pulse'],'gui',true,'save',true,'r_avg',300);
end
%% S21_ZPA Loop, check z pulse
for II=7
    for JJ=9:10
        s21_zpa('qubit', ['q' num2str(JJ)],...
            'freq',[dips(II)-1e6:0.02e6:dips(II)+1e6],'amp',[-3e4:4e3:3e4],...
            'notes',['Dip' num2str(II) ' ' 'q' num2str(JJ) ', S21 vs Z pulse'],'gui',true,'save',true,'r_avg',300);
    end
end
%% spectroscopy1_zpa
for II=2
    cP=getQSettings('qr_xy_uSrcPower', qubits{II});
    setQSettings('qr_xy_uSrcPower',7-20, qubits{II});
    setQSettings('spc_sbFreq',-400e6, qubits{II});
    QS.saveSSettings({qubits{II},'spc_driveAmp'},5000)
    data0{II}=spectroscopy1_zpa('qubit',qubits{II},...
        'biasAmp',[-3e4:1e3:3e4],'driveFreq',[5.5e9:1e6:5.95e9],...
        'r_avg',500,'notes','26dB in RT','gui',true,'save',true,'dataTyp','S21');
    setQSettings('qr_xy_uSrcPower',cP, qubits{II});
end
% sendmail2me('minggong@ustc.edu.cn', 'Measurement Done')
%% Spectrum single
for II=10
    cP=getQSettings('qr_xy_uSrcPower', qubits{II});
    setQSettings('qr_xy_uSrcPower',7-20, qubits{II});
    setQSettings('spc_sbFreq',200e6, qubits{II});
    QS.saveSSettings({qubits{II},'spc_driveAmp'},5000)
    data0{II}=spectroscopy1_zpa('qubit',qubits{II},...
        'biasAmp',000,'driveFreq',[4.5e9:1e6:5.8e9],...
        'r_avg',3000,'notes','200M sb, -20dB','gui',true,'save',true,'dataTyp','S21');
    setQSettings('qr_xy_uSrcPower',cP, qubits{II});
end
%% Spectrum Auto
for II=2
    cP=getQSettings('qr_xy_uSrcPower', qubits{II});
    setQSettings('qr_xy_uSrcPower',7-20, qubits{II});
    setQSettings('spc_sbFreq',-400e6, qubits{II});
    QS.saveSSettings({qubits{II},'spc_driveAmp'},5000)
    data0{II}=spectroscopy1_zpa_auto('qubit',qubits{II},'gui',true,'r_avg',1000,'biasAmp',-3e4:1e3:3e4);
    setQSettings('qr_xy_uSrcPower',cP, qubits{II});
end
%% qubitStability
data=data_taking.public.scripts.qubitStability('qubit','q2','Repeat',100,...
    'biasAmp',0,'driveFreq',[5.91e9:0.2e6:5.923e9],'dataTyp','P',...
    'r_avg',1000,'notes','','gui',false,'save',false);

%%
% setZDC('q2',-2000);
rabi_amp1('qubit','q2','biasAmp',0,'biasLonger',10,...
    'xyDriveAmp',[0:500:3e4],'detuning',0,'driveTyp','X','notes','20dB attn.',...
    'dataTyp','S21','r_avg',2000,'gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%% 
rabi_long1('qubit','q2','biasAmp',0,'biasLonger',10,...
    'xyDriveAmp',[0.1e4],'xyDriveLength',[20:20:10000],'detuning',[0],'driveTyp','X','notes','',...
    'dataTyp','P','r_avg',1000,'gui',true,'save',true);
%%
s21_01('qubit','q3','freq',6.93e9:1e5:6.938e9,'notes','','gui',true,'save',true);
%% High power
Ramp=logspace(2,4.5,51);
s21_01_rAmp('qubit','q2','freq',[],'rAmp',Ramp,'notes','','gui',true,'save',true);
%%
tuneup.xyGateAmpTuner('qubit','q2','gateTyp','X/2','gui',false,'save',true);
%%
% QS.saveSSettings({'q2','r_amp'},0.77e4);
tuneup.optReadoutFreq('qubit','q2','gui',true,'save',true);
%%
tuneup.iq2prob_01('qubit','q2','numSamples',1e4,...
    'gui',true,'save',true)
%% Optimize readout amplitude
tuneup.optReadoutAmp('qubit','q2','gui',true,'save',true,'bnd',[1000,30000],'optnum',51,'tunerf',true);
%% Optimize readout length
tuneup.optReadoutLn('qubit','q7','gui',true,'save',true,'bnd',[1000,8000],'optnum',11);
%% automatic function, after previous steps pined down qubit parameters,
q = qubits{2};
tuneup.correctf01byRamsey('qubit',q,'gui',true,'save',true); % measure f01 by spectrum
XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2'};
for II = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{II},'gui',true,'save',true); % finds the XY gate amplitude and update to settings
end
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
%%
spectroscopy1_zdc('qubit','q2',...
    'biasAmp',[-10000:250:10000],'driveFreq',[5.e9:2e6:6.4e9],'dataTyp','S21','note','F2',...
    'r_avg',1000,'gui',true,'save',true);
%%
ramsey('mode','dp','qubit','q2',...
    'time',[0:16*3:1600*10],'detuning',2*1e6,'T1',4.66,'fit',true,...
    'dataTyp','P','notes','pulse tube on','gui',true,'save',true,'r_avg',3000);
%%
ramsey('mode','dz','qubit','q2',...
    'time',[0:16*3:1600*5],'detuning',0,'detuneAmp',[-0.1e4,0.1e4],'T1',4.66,'fit',true,...
    'dataTyp','P','notes','pulse tube on','gui',true,'save',true,'r_avg',3000);
%%
T1_1('qubit','q2','biasAmp',0,'time',[0:160*3:30e3],'biasDelay',16,...
    'gui',true,'save',true,'r_avg',3000,'fit',true)
%%
T1_1('qubit','q2','biasAmp',[-6100:0.1e3:6000],'time',[0:160*3:30e3],'biasDelay',16,...
    'gui',true,'save',true,'r_avg',3000,'fit',true,'notes','unplug thermalmeter')
%%
T1_1_s21('qubit','q6','biasAmp',000,'time',[0:100:8e3],'biasDelay',0,...
    'gui',true,'save',true,'r_avg',5000)
%%
T1_1_s21('qubit','q2','biasAmp',[-3e4:1e3:3e4],'time',[0:200:10e3],...
    'gui',true,'save',true,'r_avg',5000)
%%
for ii=1:1000
[~,f01(end+1)]=tuneup.correctf01byRamsey('qubit','q2','gui',false,'save',true);
figure(2);
subplot(2,1,1);
hist(f01);
title(['STD:' num2str(std(f01),'%.3e') ', mean:' num2str(mean(f01),'%.3e') ', rate:' num2str(std(f01)/mean(f01),'%.3e')])
subplot(2,1,2)
plot(f01,'.')
drawnow;
end
%% fully auto callibration
qubits = {'q2'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000,q);
    tuneup.correctf01byRamsey('qubit',q,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',false,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',21,'gui',true,'save',true);
    end
end
%%
state = '|0>-i|1>';
data = singleQStateTomo('qubit','q2','reps',2,'state',state);
rho = sqc.qfcns.stateTomoData2Rho(data);
h = figure();bar3(real(rho));h = figure();bar3(imag(rho));
%%
gate = 'Y/2';
data = singleQProcessTomo('qubit','q2','reps',2,'process',gate);
chi = sqc.qfcns.processTomoData2Rho(data);
h = figure();bar3(real(chi));h = figure();bar3(imag(chi));
%% single qubit gate benchmarking
setQSettings('r_avg',500);
numGates = 1:1:10;
[Pref,Pi] = randBenchMarking('qubit1','q2','qubit2',[],...
       'process','X/2','numGates',numGates,'numReps',70,...
       'gui',true,'save',true);