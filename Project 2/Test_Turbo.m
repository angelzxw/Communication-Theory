clear all; close all; clc;

nSym = 1000; % Ignore this, just a dummy variable it's actually generating more than 1k symbols but rate / symbol is the same.
M = 16;
k = log2(M);
t = poly2trellis(4, [13 15], 13);

intrlvrIndices = randperm(round(nSym * k / 3) - 5);
hEnc = comm.TurboEncoder('TrellisStructure', t, 'InterleaverIndices', intrlvrIndices);
hDec = comm.TurboDecoder('TrellisStructure', t, 'NumIterations', 9, 'InterleaverIndices', intrlvrIndices);
hEMod = comm.RectangularQAMModulator('ModulationOrder', M, ...
    'BitInput', true, ...
    'NormalizationMethod', 'Average power');
hDMod = comm.RectangularQAMDemodulator('ModulationOrder', M, ...
    'BitOutput', true, ...
    'NormalizationMethod', 'Average power', ...
    'DecisionMethod', 'Log-likelihood ratio');

txBits = randi([0,1], 1, round(nSym * k / 3) - 5);
txTurbo = step(hEnc, txBits.');
txTurbo_Len = length(txTurbo);
%txTurbo = vertcat(txTurbo, zeros(rem(txTurbo_Len, M) * M, 1));
msgQAM = step(hEMod, txTurbo);
rate = length(txBits) / (length(msgQAM))
msgQAM = awgn(msgQAM, 12, 'measured');
rxTurbo = step(hDMod, msgQAM);
%rxTurbo = rxTurbo(1:txTurbo_Len);
rxBits = step(hDec, -rxTurbo).';
[v1, v2] = biterr(txBits, rxBits)
plot(1:length(txBits), abs(txBits-rxBits));