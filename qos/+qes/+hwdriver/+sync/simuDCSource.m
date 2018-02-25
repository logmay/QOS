classdef simuDCSource < qes.hwdriver.icinterface_compatible
    % wrap ustcadda as dc source
    
% Copyright 2017 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        numChnls
    end
    properties (SetAccess = private, GetAccess = private)
        chnlMap
    end
    properties (Dependent = true)
        range
    end
    methods
        function obj = simuDCSource(chnlMap_)
            if iscell(chnlMap_) % for chnlMap_ data loaded from registry saved as json array
                chnlMap_ = cell2mat(chnlMap_);
            end
            if numel(unique(chnlMap_)) ~= numel(chnlMap_) ||...
				~all(round(chnlMap_) == chnlMap_) ||...
				~all(chnlMap_>0)
                throw(MException('QOS_ustc_dc:inValidInput','bad chnlMap'));
            end
            
			obj.chnlMap = chnlMap_;
			obj.numChnls = numel(chnlMap_);

            obj.cmdList = {[],[],[]};
            obj.ansList = {[],[],[]};
            obj.fcnList = {[],[],[]};
        end
        function val = get.range(obj)
            val = 1e4;
        end
        function SetDC(obj,dcval,chnl)
        end
        function delete(obj)
		end
    end
end