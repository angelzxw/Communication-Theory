% Project 2 BER Detector for 4 QAM and 16 QAM
format compact; clear all; close all; clc;

% Keene's Holy Constants
numIter = 10;
nSym = 1000;
SNR_Vec = 0:1:16;
lenSNR = length(SNR_Vec);

% Xiangling's Holy Constants
M = 16;
k = log2(M);

berVec = zeros(numIter, lenSNR);
for i = 1:numIter
    bits = randi([0,1], 1, nSym * k);
    msg = bi2de(reshape(bits, k, length(bits) / k).', 'left-msb')';
    for j = 1:lenSNR
        tx = qammod(msg, M);
        % Add Noise
        txNoise = awgn(tx, SNR_Vec(j) + 10*log10(k), 'measured');
        % Receive Data
        rxMSG = qamdemod(txNoise, M);
        rxBits = de2bi(rxMSG, 'left-msb');
        rxBits = reshape(rxBits.', numel(rxBits), 1).';
        [Discard, berVec(i,j)] = biterr(bits, rxBits);
    end
end

% Display Plots
ber = mean(berVec, 1);
berTheory = berawgn(SNR_Vec, 'qam', M, 'nondiff');
figure
semilogy(SNR_Vec, ber);
hold on
semilogy(SNR_Vec, berTheory, 'r');
hold off
legend('BER', 'Theoretical BER');
title(strcat(num2str(M), ' QAM'));