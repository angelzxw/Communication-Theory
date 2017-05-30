format compact; clear all; clear global; clc; close all
noiseLevel = randi([0 20]);

Fs = 120e4;
sumForSpec = [];

total1 = 0;
total2 = 0;
for i = 1:16
    [sig1, bits1, gain1] = tx1_flat();
    [sig2, bits2, gain2] = txMosquito();

    sum = sig1 + sig2;
    sumNoisy = awgn(sum, noiseLevel, 1);

    sumForSpec =  [sumForSpec, sumNoisy];

    total1 = total1 + rx1_flat(sumNoisy, bits1, gain1);
    total2 = total2 + rxMosquito(sumNoisy, bits2, gain2);
end

noiseLevel
[total1, total2]
spectrogram(sumForSpec, 64, [], [], Fs, 'yaxis');