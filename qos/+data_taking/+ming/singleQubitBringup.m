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
setQSettings('r_fc',6.63105e+09)
%%
setQSettings('r_avg',0.5e3)
%%
setQSettings('r_ln',2e3)
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
setQSettings('channels.xy_mw.chnl',2);
setQSettings('qr_xy_uSrcPower',7);
%%
setQSettings('channels.z_dc.instru','dcSrc_ustcda_1');
setQSettings('channels.z_dc.chnl',1);
%%
for ii=1:2:9
setQSettings('qr_xy_fc',5.6e9,qubits{ii});
end
%%
for ii=5:9
    setQSettings('channels.xy_mw.chnl',3,qubits{ii});
    setQSettings('qr_xy_uSrcPower',15,qubits{ii});
end
%%
setQSettings('channels.r_mw.instru','mwSrc_sc5511a');
setQSettings('channels.r_mw.chnl',1);
setQSettings('r_uSrcPower',-7);
%%
for ii=[1:3 5:9]
    ramp=getQSettings('r_amp',qubits{ii})
    setQSettings('r_amp',round(ramp/sqrt(10)),qubits{ii});
end
%%
setQSettings('g_XY_ln',80)
setQSettings('g_XY2_ln',40)
setQSettings('g_XY4_ln',20)
%%
setQSettings('spc_zLonger',0)
%% reorganize readout qubit information
list1=[1:12];
list2=[8 7 6 5 4 3 2 12 11 10 9 1];
swaps=swap2list(list1,list2);
for ii=1:size(swaps,1)
    swapq1=['q' num2str(swaps(ii,1))];
    swapq2=['q' num2str(swaps(ii,2))];
    r_amp_=getQSettings('r_amp',swapq1);
    r_fr_=getQSettings('r_fr',swapq1);
    r_freq_=getQSettings('r_freq',swapq1);
    setQSettings('r_amp',getQSettings('r_amp',swapq2),swapq1);
    setQSettings('r_fr',getQSettings('r_fr',swapq2),swapq1);
    setQSettings('r_freq',getQSettings('r_freq',swapq2),swapq1);
    setQSettings('r_amp',r_amp_,swapq2);
    setQSettings('r_fr',r_fr_,swapq2);
    setQSettings('r_freq',r_freq_,swapq2);
end
%%
for II=1:numel(qubits)
    setZDC(qubits{II},0);
end
%%
readoutFreqDiagram(qubits,200e6)
%%
data_taking.public.jpa.turnOnJPA('jpaName','impa1','pumpFreq',13.55e9,'pumpPower',5,'bias',0.00014,'on',true)
%% S21
data=s21_rAmp('qubit', qubits{1},...
    'freq',dips(3)-1e6:0.1e6:dips(3)+3e6,'amp',1e4,...
    'notes','24bit','gui',true,'save',true);
%%
for ii=1:100
data=s21_rAmp('qubit', qubits{1},...
    'freq',dips(3)-1e6:0.1e6:dips(3)+3e6,'amp',1e4,...
    'notes','24bit','gui',true,'save',true);
dd(ii,:)=cell2mat(data.data{1})';
figure(22);imagesc(abs(dd));drawnow
end
%%
s21_rAmp('qubit', qubits{1},...
    'freq',6.5e9:1e6:7e9,'amp',3e4,...
    'notes','','gui',true,'save',true);
%%
for II=1:numel(qubits)
    s21_zdc_networkAnalyzer('qubit',qubits{II},'NAName',[],'startFreq',dips(II)-3e6,'stopFreq',dips(II)+3e6,'numFreqPts',500,'avgcounts',5,'NApower',-20,'biasAmp',[-3e4:1e3:3e4],'bandwidth',2000,'notes','','gui',true,'save',true)
end
%% Dip and Qubit Correlation ZDC
for JJ=1:numel(dips)
    for II=1:numel(qubits)
        s21_zdc('qubit', qubits{II},...
            'freq',[dips(JJ)-1e6:0.1e6:dips(JJ)+1e6],'amp',[-3e4:6e3:3e4],...
            'notes',['Dip ' num2str(JJ) ' ' qubits{II}],'gui',true,'save',true);
    end
end

%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift
amps=[logspace(log10(100),log10(30000),51)];
swprng=[-2e6:0.2e6:2e6];
for II =  4
    data1{II}=s21_rAmp('qubit',qubits{II},'freq',dips(II)+swprng,'amp',amps,...  % logspace(log10(1000),log10(32768),25)
        'notes','RT 23dB','gui',true,'save',true,'r_avg',2000);
end
%% figure out dispersive shift
for II=4
    dd=abs(cell2mat(data1{1,II}.data{1,1}));
    z_ = 20*log10(abs(dd));
    sz=size(z_);
    for jj = 1:sz(2)
        z_(:,jj) = z_(:,jj) - z_(1,jj);
    end
    frqs=dips(II)+swprng;
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
r_amp=[6979 16240 9487 9487 10240 10240 12900 8137 12900]*0.8;
for II=1:numel(r_amp)
    %     setQSettings('r_freq',r_freq(II),qubits{11-II});
    setQSettings('r_amp',r_amp(II),qubits{II});
end
%% Get all S21 curves with current readout setup, and update r_freq
for II=4
    r_freq=getQSettings('r_fr', qubits{II});
    s_r_freq=r_freq-2e6:0.025e6:r_freq+2e6;
    data2{II}=s21_rAmp('qubit', qubits{II},...
        'freq',s_r_freq,'amp',getQSettings('r_amp', qubits{II}),...
        'notes',qubits{II},'gui',true,'save',true);
    dat=smooth(abs(cell2mat(data2{1,II}.data{1,1})),3)';
    [~,lo]=min(dat);
    r_freq1=s_r_freq(lo)
    setQSettings('r_freq',r_freq1,qubits{II});
end
%%
for II=1:numel(qubits)
    r_freq=getQSettings('r_freq', qubits{II});
    r_fr=getQSettings('r_fr', qubits{II});
    f01_pre=r_freq-(30e6)^2/(r_freq-r_fr)
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
        'freq',[dips(II)-1e6:0.1e6:dips(II)+1e6],'amp',[-3e4:10e3:3e4],...
        'notes',[qubits{II} ', S21 vs Z pulse'],'gui',true,'save',true,'r_avg',300);
end
%% Dip and Qubit Correlation ZPA
for JJ=12:numel(qubits)
    for II=[ 3 7 8 10:12]
        s21_zpa('qubit', [qubits{JJ}],...
            'freq',[dips(II)-1e6:0.05e6:dips(II)+1e6],'amp',[-3e4:10e3:3e4],...
            'notes',['Dip' num2str(II) ' ' qubits{JJ} ', S21 vs Z pulse'],'gui',true,'save',true,'r_avg',300);
    end
    close all
end
%% spectroscopy1_zpa
for II=4
    cP=getQSettings('qr_xy_uSrcPower', qubits{II});
    setQSettings('qr_xy_uSrcPower',cP-20, qubits{II});
    setQSettings('spc_sbFreq',300e6, qubits{II});
    QS.saveSSettings({qubits{II},'spc_driveAmp'},30000)
    data0{II}=spectroscopy1_zpa('qubit',qubits{II},...
        'biasAmp',0,'driveFreq',[4.5e9:1e6:4.8e9],...
        'r_avg',1000,'notes','','gui',true,'save',true,'dataTyp','S21');
    setQSettings('qr_xy_uSrcPower',cP, qubits{II});
end
% sendmail2me('minggong@ustc.edu.cn', 'Measurement Done')
%%
II=7;
for ii=1:12
    setQSettings('channels.xy_q.chnl',ii*2+3, qubits{II});
    setQSettings('channels.xy_i.chnl',ii*2+4, qubits{II});
    cP=getQSettings('qr_xy_uSrcPower', qubits{II});
    setQSettings('qr_xy_uSrcPower',cP-20, qubits{II});
    setQSettings('spc_sbFreq',-200e6, qubits{II});
    QS.saveSSettings({qubits{II},'spc_driveAmp'},30000)
    data0{II}=spectroscopy1_zpa('qubit',qubits{II},...
        'biasAmp',0,'driveFreq',[5.e9:1e6:6.2e9],...
        'r_avg',500,'notes',[num2str(ii*2+3)],'gui',true,'save',true,'dataTyp','S21');
    setQSettings('qr_xy_uSrcPower',cP, qubits{II});
end
% setQSettings('channels.xy_q.chnl',17);
% setQSettings('channels.xy_i.chnl',18);
%% Spectrum Auto
for II=[5]
    cP=getQSettings('qr_xy_uSrcPower', qubits{II});
    setQSettings('qr_xy_uSrcPower',-30, qubits{II});
    setQSettings('spc_sbFreq',300e6, qubits{II});
    QS.saveSSettings({qubits{II},'spc_driveAmp'},30000)
    data0{II}=spectroscopy1_zpa_auto('qubit',qubits{II},'gui',true,'r_avg',1000,'swpInitBias',1.8e4,'swpInitf01',5.234e9,...
        'biasAmp',1.8e4:0.04e3:2e4,'swpBandWdth',8e6,'swpBandStep',0.1e6,'dataTyp','P','peak',true);
    setQSettings('qr_xy_uSrcPower',cP, qubits{II});
end
%%
spectroscopy1_zdc('qubit','q2',...
    'biasAmp',[-10000:250:10000],'driveFreq',[5.e9:2e6:6.4e9],'dataTyp','S21','note','F2',...
    'r_avg',1000,'gui',true,'save',true);
%% qubitStability
data=data_taking.public.scripts.qubitStability('qubit','q2','Repeat',100,...
    'biasAmp',0,'driveFreq',[5.91e9:0.2e6:5.923e9],'dataTyp','P',...
    'r_avg',1000,'notes','','gui',false,'save',false);

%%
% setZDC('q2',-2000);
rabi_amp1('qubit','q4','biasAmp',0,'biasLonger',0,...
    'xyDriveAmp',[0e4:500:3.2e4],'detuning',0,'driveTyp','X','notes','',...
    'dataTyp','S21','r_avg',2000,'gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%%
rabi_long1('qubit','q5','biasAmp',0,'biasLonger',0,...
    'xyDriveAmp',[3e4],'xyDriveLength',[16:16:2000],'detuning',[0],'driveTyp','X','notes','',...
    'dataTyp','S21','r_avg',1000,'gui',true,'save',true);
%%
s21_01('qubit','q1','freq',[],'notes','','gui',true,'save',true);
%% High power
Ramp=logspace(2,4.5,51);
s21_01_rAmp('qubit','q4','freq',[],'rAmp',Ramp,'notes','','gui',true,'save',true);
%% Optimize readout amplitude
tuneup.optReadoutAmp('qubit','q4','gui',true,'save',true,'bnd',[1000,25000],'optnum',31,'tunerf',false);
%% Optimize readout length
for ii=[4]
q = qubits{ii};
tuneup.optReadoutLn('qubit',q,'gui',true,'save',true,'bnd',[1000,6000],'optnum',11);
end
%%
tuneup.correctf01bySpc('qubit','q2','gui',true,'save',true); % measure f01 by spectrum
%% automatic function, after previous steps pined down qubit parameters,
for ii=[8:9]
q = qubits{ii}
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.correctf01byRamsey_1('qubit',q,'gui',true,'save',true); % measure f01 by spectrum
XYGate ={'X', 'X/2'};%, 'Y', 'Y/2', '-X/2', '-Y/2'
for II = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{II},'AE',true,'AENumPi',11,'gui',true,'save',true); % finds the XY gate amplitude and update to settings
end
tuneup.iq2prob_01('qubit',q,'numSamples',2e4,'gui',true,'save',true);
end
%%
for ii=[4]
    q = qubits{ii};
    T1_1('qubit',q,'biasAmp',0,'time',[0:160*5:60e3],'biasDelay',0,...
    'gui',true,'save',true,'r_avg',10000,'fit',true)
end
%%
for ii=[1:9]
q = qubits{ii};
T1_1('qubit',q,'biasAmp',-3e4:1e3:3e4,'time',[0:160*10:60e3],'biasDelay',0,...
    'gui',true,'save',true,'r_avg',2000,'fit',true,'notes','')
end
%%
T1_1_s21('qubit','q6','biasAmp',000,'time',[0:100:8e3],'biasDelay',0,...
    'gui',true,'save',true,'r_avg',5000)
%%
T1_1_s21('qubit','q2','biasAmp',[-3e4:1e3:3e4],'time',[0:200:10e3],...
    'gui',true,'save',true,'r_avg',5000)
%% dp
ramsey('mode','dp','qubit','q4',...
    'time',[0:16*2:1600*6],'detuning',2e6,'T1',19.8,'fit',true,...
    'dataTyp','P','notes','','gui',true,'save',true,'r_avg',3000);
%% dz
ramsey('mode','dz','qubit','q4',...
    'time',[0:16*1:1600*3],'detuning',[0.1e4:0.1e3:0.9e4],'T1',13.6,'fit',true,...
    'dataTyp','P','notes','','gui',true,'save',true,'r_avg',1000);
%% time dependent T2*
t0=now;
for II=1:500
    [~,T2(II),T2_err(II)]=ramsey('mode','dp','qubit','q2',...
        'time',[0:16*3:1600*8],'detuning',3*1e6,'T1',4.66,'fit',true,...
        'dataTyp','P','notes','pulse tube on','gui',false,'save',true,'r_avg',3000);
    tt(II)=(now-t0)*24;
    figure(11)
    errorbar(tt,T2/1e3,T2_err/1e3,'-o','MarkerFaceColor','r')
    xlabel('Time (h)')
    ylabel('T2 (us)')
    drawnow
end

%% qubit freq stability
f01=[];
f01_err=[];
for ii=1:30
    [~,f01(end+1),f01_err(end+1)]=tuneup.correctf01byRamsey_1('qubit','q2','gui',true,'save',true);
    figure(2);
    subplot(2,1,1);
    hist(f01);
    xlabel('f01 (Hz)')
    ylabel('p')
    title(['f01 STD:' num2str(std(f01),'%.3e') ', error mean:' num2str(mean(f01_err),'%.3e')])
    subplot(2,1,2)
    errorbar(1:ii,f01,f01_err,'.')
    xlabel('Measurement Index')
    ylabel('f01 (Hz)')
    drawnow;
end
%% qubit freq stability versus attenuator
attns=[0:3:15];
for jj=1:length(attns)
    try
        qes.hwdriver.sync.HWUSBATT(attns(jj))
        pause(10)
        f01=[];
        f01_err=[];
        for ii=1:25
            [~,f01(end+1),f01_err(end+1)]=tuneup.correctf01byRamsey_1('qubit','q2','gui',true,'save',true);
            figure(21);
            subplot(2,1,1);
            hist(f01);
            xlabel('f01 (Hz)')
            ylabel('p')
            title(['f01 STD:' num2str(std(f01),'%.3e') ', error mean:' num2str(mean(f01_err),'%.3e')])
            subplot(2,1,2)
            errorbar(1:ii,f01,f01_err,'.')
            xlabel('Measurement Index')
            ylabel('f01 (Hz)')
            drawnow;
            saveas(gcf,['E:\Data\matlab\20170921_YYS_3bit\f01Stab_withUPS_withAtt3_' num2str(attns(jj)) '.fig'])
            saveas(gcf,['E:\Data\matlab\20170921_YYS_3bit\f01Stab_withUPS_withAtt3_' num2str(attns(jj)) '.png'])
            save(['E:\Data\matlab\20170921_YYS_3bit\f01Stab_withUPS_withAtt3_' num2str(attns(jj)) '.mat'],'f01','f01_err')
        end
    end
end
%% fully auto callibration
qubits = {'q4','q5'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',1000,q);
    tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    tuneup.correctf01byRamsey('qubit',q,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',11,'gui',true,'save',true);
    end
    [~,~,vis]=tuneup.iq2prob_01('qubit',q,'numSamples',2e4,'gui',true,'save',true);
    disp(vis)
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
%% figure out Z control
zchannels=[27 29:32 ];% 
qubitss = sqc.util.loadQubits();
qubit = qubitss{9};
q=qubit.name;
rstime=[0:16*2:1600*3];
dd=NaN(length(zchannels),length(rstime));
for ii=1:length(zchannels)
    temp=qubit.channels.z_pulse.chnl;
    setQSettings('channels.z_pulse.chnl',zchannels(ii),q);
    data=ramsey('mode','dz','qubit',q,...
    'time',rstime,'detuning',1e4,'T1',5.8,'fit',true,...
    'dataTyp','P','notes',['zchannels=' num2str(zchannels(ii))],'gui',false,'save',true,'r_avg',3000);
    setQSettings('channels.z_pulse.chnl',temp,q);
    dd(ii,:)=(data.data{1,1});
    figure(101);
    imagesc(zchannels,rstime,dd');drawnow;
    xlabel('chnl Z')
    ylabel([q ' biasAmp'])
end
saveas(gcf,[QS.loadSSettings('data_path') '\' q 'Z control Ramsey' '.fig'])
%% figure out X control
chnlI=[6:2:22];
chnlQ=[5:2:21];
qubitss = sqc.util.loadQubits();
qubit = qubitss{3};
q=qubit.name;
driveFreq=[qubit.f01-30e6:1e6:qubit.f01+30e6];
driveAmp=[0:1000:3e4];
dd=NaN(length(chnlI),length(driveAmp));
for ii=1:length(chnlI)
    temp1=qubit.channels.xy_i.chnl;
    temp2=qubit.channels.xy_q.chnl;
    setQSettings('channels.xy_i.chnl',chnlI(ii), q);
    setQSettings('channels.xy_q.chnl',chnlQ(ii), q);
    setQSettings('qr_xy_uSrcPower',7, q);
    data=rabi_amp1('qubit',q,'biasAmp',0,'biasLonger',0,...
    'xyDriveAmp',driveAmp,'detuning',0,'driveTyp','X','notes',[num2str(chnlI(ii)) ' ' num2str(chnlQ(ii))],...
    'dataTyp','S21','r_avg',2000,'gui',false,'save',false);
    setQSettings('channels.xy_i.chnl',temp1, q);
    setQSettings('channels.xy_q.chnl',temp2, q);
    dd(ii,:)=cell2mat(data.data{1,1});
    figure(101);
    imagesc(chnlI,driveAmp,dd');
    xlabel('chnl I')
    ylabel([q ' driveAmp'])
    drawnow
end
saveas(gcf,[QS.loadSSettings('data_path') '\' q 'XY control Rabi 7dB' '.fig'])