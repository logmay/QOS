
q = 'q7';
setQSettings('r_avg',500, q);
setQSettings('spc_driveAmp',1000, q);
setQSettings('qr_xy_fc',getQSettings('qr_xy_fc','q7'), 'q8');
spectroscopy111_zpa('biasQubit','q8','biasAmp',[-30000:10000:30000],...
       'driveQubit','q7','driveFreq',[5.15e9:0.1e6:5.25e9],...
       'readoutQubit','q7','dataTyp','P',...
       'notes','q8->q7 cross talk, bias q8, drive & readout q7','gui','true','save','true');
   
q = 'q8';
setQSettings('r_avg',500, q);
setQSettings('spc_driveAmp',1000, q);
spectroscopy111_zpa('biasQubit','q7','biasAmp',[-30000:10000:30000],...
       'driveQubit','q8','driveFreq',[4.6e9:0.1e6:4.75e9],...
       'readoutQubit','q8','dataTyp','P',...
       'notes','q8->q7 cross talk, bias q8, drive & readout q7','gui','true','save','true');
   
q = 'q7';   
setQSettings('r_avg',500, q);
setQSettings('spc_driveAmp',10000, q);
q7zAmp2f01 = @(x) - 0.46539*x.^2 + 2709.5*x + 5.222e+09-120e6;
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
spectroscopy1_zpa_bndSwp('qubit',q,...
       'swpBandCenterFcn',q7zAmp2f01,'swpBandWdth',80e6,...
       'biasAmp',[-32500:500:32500],'driveFreq',[4.7e9-120e6:0.2e6:4.95e9],...
       'gui',true,'save',true); 
   
%%   
q = 'q8';
setQSettings('r_avg',1000, q);
setQSettings('spc_driveAmp',1000, q);
q8zAmp2f01 =@(x) - 0.2994*x.^2 + 1890.6*x + 4.7344e+09;
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
spectroscopy1_zpa_bndSwp('qubit',q,...
       'swpBandCenterFcn',q8zAmp2f01,'swpBandWdth',30e6,...
       'biasAmp',[-32500:250:32500],'driveFreq',[4.37e9:0.1e6:4.77e9],...
       'gui',true,'save',true);

   
setQSettings('r_avg',1000, q);
setQSettings('spc_driveAmp',20000, q);
q8zAmp2f01 =@(x) - 0.2994*x.^2 + 1890.6*x + 4.7344e+09-97e6;
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
spectroscopy1_zpa_bndSwp('qubit',q,...
       'swpBandCenterFcn',q8zAmp2f01,'swpBandWdth',40e6,...
       'biasAmp',[-32500:500:32500],'driveFreq',[4.37e9-97e6:0.1e6:4.77e9-97e6],...
       'gui',true,'save',true);

   
