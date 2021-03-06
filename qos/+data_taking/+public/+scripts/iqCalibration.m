%% IQ mixer calibration for 2 channels
data_taking.public.calibration.iqChnl(...
        'awgName','da_ustc_1','chnlSet','C11_1_2','maxSbFreq',500e6,'sbFreqStep',20e6,...
			'loFreqStart',4.86e9,'loFreqStop',7e9,'loFreqStep',10e6,'spcAvgNum',1,...
          'notes','DAC C11, I:CH2, Q CH1','gui',false,'save',true,'calSideband',true);