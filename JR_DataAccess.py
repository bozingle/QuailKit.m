# -*- coding: utf-8 -*-
"""
Created on Mon Feb 25 10:45:14 2019

@author: jreznick
"""

import scipy.io as sio
import h5py
import numpy as np

class JR_Data:
    def __init__(self,filepath, recording, setting = 'spgram'):
        #Loading in data from .mat file
        matData = sio.loadmat(filepath+recording+"\\processed"+recording+".mat", squeeze_me=True, struct_as_record=False)
        propStruct = matData['propertiesStruct']
        self.scale = propStruct.scale
        self.audiofs = propStruct.audiofs
        self.spgramfs = propStruct.spgramfs
        self.filepath = filepath+recording
        self.finalTimeAudio = propStruct.finalTimeAudio
        self.finalTimeSpgram = propStruct.finalTimeSpgram
        
        self.set = setting
        
        self.h5File = h5py.File(self.filepath+'\\information.h5','r')
        self.audioDS = self.h5File['audio']
        self.spgramDS = self.h5File['spgram']
        self.spgramfs = self.spgramDS.attrs["propertiesArray"][0]
        self.audiofs = self.audioDS.attrs["audiofs"][0]
        
    def __call__(self, setting):
        self.set = setting
        return self
    
    def __getitem__(self, index):
        s = []
        t = []
        if self.set == "spgram":
            startIn = int(index[0]/(1/self.spgramfs))
            endIn = int(index[1]/(1/self.spgramfs) - startIn -1)
            t = self.spgramDS[0,startIn:endIn]
            s = self.spgramDS[1:, startIn:endIn]
        elif self.set == "audio":
            startIn = int(index[0]/(1/self.audiofs))
            endIn = int(index[1]/(1/self.audiofs) - startIn - 1)
            t = self.audioDS[0,startIn:endIn]
            s = self.audioDS[1:, startIn:endIn]
        return s,t
    
    def close(self):
        self.h5File.close()

DataObj = JR_Data("","SM304472_0+1_20181219$100000")

#Long way
DataObj('audio')
s,t = DataObj[0,10]

#Short hand
s,t = DataObj('audio')[0,10]

#Meaning, If I wanted to do a proccess over the spectrogram, I could do this
DataObj('spgram')
for i in range(0,10):
    s,t = DataObj[0,10]
#And it doesn't require me to do the short hand. It essentially sets which one
# to work with when "DataObj('spgram')" is stated.
DataObj.close()