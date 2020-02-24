# _*_ coding=utf-8 _*_

from scipy import signal
__date__ = '8/4/2019 16:20'

import pylab as pl
from sklearn.mixture import GaussianMixture
import os
import librosa
import numpy as np
import matplotlib.pyplot as plt
import wave
import time

from pydub import AudioSegment
from pydub.silence import split_on_silence


#Exclusde silecne part of voice signal
def excludeSilentReadWav(filename):
    song = AudioSegment.from_wav(filename)

    chunks = split_on_silence(song,
        # must be silent for at least 2 seconds or 2000 ms
        min_silence_len=1500,
        # consider it silent if quieter than -16 dBFS
        #Adjust this per requirement
        silence_thresh=-40
    )
    return chunks

def enframe(wave_data, nw, inc, winfunc):
    '''Transfer signal into frame
    Parameters meanings：
    wave_data:original signal
    nw:length of each frame( length * time)
    inc:Interval of adjacent frames (as defined above)
    '''
    wlen=len(wave_data) # Total signal length
    # if the signal length is less than the length of one frame,
    # the number of frames is defined as 1
    if wlen<=nw:
        nf=1
    else: # otherwise, calculate the total length of the frame
        nf=int(np.ceil((1.0*wlen-nw+inc)/inc))
    pad_length=int((nf-1)*inc+nw) # the total smoothed length of all frames
    # insufficient length is filled with 0, similar to the extended array operation in FFT
    zeros=np.zeros((pad_length-wlen,))
    pad_signal=np.concatenate((wave_data,zeros)) # the filled signal is recorded as pad_signal
    # it is equivalent to extracting the point in time of all frames to get the matrix of nf*nw length
    indices=np.tile(np.arange(0,nw),(nf,1))+np.tile(np.arange(0,nf*inc,inc),(nw,1)).T
    indices=np.array(indices,dtype=np.int32) # converting indices to Matrix
    frames=pad_signal[indices] # get frame signal
    win=np.tile(winfunc,(nf,1))  # window function, where default is 1
    print("the length of the wave signal is:",wlen)
    return frames*win   # return frame signal matrix

def getWaveData(filename):
    fw = wave.open(filename,'rb')
    params = fw.getparams()
    print(params)
    nchannels, sampwidth, framerate, nframes = params[:4]
    str_data = fw.readframes(nframes)
    wave_data = np.fromstring(str_data, dtype=np.int16)
    wave_data = wave_data * 1.0 / (max(abs(wave_data)))  # normalization of wave amplitude
    fw.close()
    return wave_data

def getGMM(filename):

    nw = 320  # number of sampling points for 16KHz files and 20ms
    inc = 160
    wave_data=getWaveData(filename)
    winfunc = signal.hann(nw)
    X = enframe(wave_data, nw, inc, winfunc)
    frameNum = X.shape[0]  # return the number of matrix columns and get the number of frames
    print("the frame Number is:",frameNum)


    data=[]
    for oneframe in X:
        tmpList=list()
        for a in librosa.feature.mfcc(y=oneframe, sr=16000, n_mfcc=24):
            tmpList.append(a[0])
        data.append(tmpList)
    data=np.array(data)


    gmm = GaussianMixture(7, covariance_type='full', random_state=0).fit(data)
    return gmm


if __name__=="__main__":
    start=time.clock()
    # generating trained models
    names=['A', 'B', 'C', 'D','E','F','G','H','I' ]
    files=['./train/aojiao.wav', './train/feifei.wav', './train/fushun.wav', './train/hemei.wav',
           './train/jili.wav','./train/kangkang.wav','./train/lulu.wav','./train/nike.wav','./train/nuomi.wav']
    beTestFile= "./recog/nuomi2.wav"
    GMMs=[]
    for file in files:
        GMMs.append(getGMM(file))
    timePointAfterGmm=time.clock()

    nw = 320
    inc = 160
    winfunc = signal.hamming(nw)
    fragmentListOfSample = excludeSilentReadWav(beTestFile)
    # fragmentListOfSample=excludeSilentReadWav("./sample/晟兵对话.wav")
    lenOffragment = len(fragmentListOfSample)
    for ind, fragment in enumerate(fragmentListOfSample):
        fragment.export("TEST{0}.wav".format(ind), format="wav", )
    for dialogNum in range(0, lenOffragment):
        testFrames = enframe(getWaveData("TEST{0}.wav".format(dialogNum)), nw, inc, winfunc)
        probilityList = []
        sampleData = []
        count = 0
        sum_pro = 0
        for oneframe in testFrames:
            tmpList = list()
            for a in librosa.feature.mfcc(y=oneframe, sr=16000, n_mfcc=24):
                tmpList.append(a[0])
            sampleData.append(tmpList)
            count += 1
        maxPro = GMMs[0].score(sampleData)
        maxName = names[0]
        for index, GMM in enumerate(GMMs):
            probility = GMM.score(sampleData)
            print("the score of model of {0}".format(names[index]), probility)
            if maxPro < probility:
                maxPro = probility
                maxName = names[index]
        print("the max probability :{0}, name :{1}".format(maxPro, maxName))
    end = time.clock()

    print("to train GMM model: ", timePointAfterGmm - start,"seconds")
    print("total process: ", end - start, "seconds")
    # Intermediate File cleanup
    os.system("pause")
    for dialogNum in range(0, lenOffragment):
        fileName = "dialog{0}.wav".format(dialogNum)
        try:
            os.remove(fileName)
        except:
            print("intermediate file delete faild : " + fileName)