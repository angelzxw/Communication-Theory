% Project 2
format compact; clear all; close all; clc;

% Keene's Holy Constants
numIter = 1000;
nSym = 1000;
SNR_Vec = 12;
lenSNR = length(SNR_Vec);

% Xiangling's Holy Constants
M = 64;
k = log2(M);
train = 25;
% t = poly2trellis(7, [171 133], 171);
% t = poly2trellis([5 4], [23 35 0; 0 5 13]);
t = poly2trellis(4, [13 15], 13);

intrlvrIndices = randperm(round(nSym * k / 3));
hEnc = comm.TurboEncoder('TrellisStructure', t, 'InterleaverIndices', intrlvrIndices);
hDec = comm.TurboDecoder('TrellisStructure', t, 'NumIterations', 9, 'InterleaverIndices', intrlvrIndices);
hEMod = comm.RectangularQAMModulator('ModulationOrder', M, ...
    'BitInput', true);
hDMod = comm.RectangularQAMDemodulator('ModulationOrder', M, ...
    'BitOutput', true, ...
    'DecisionMethod', 'Log-likelihood ratio');

% Pick a Channel
% chan = 1; % No Channel (Aww Yes Best Channel)
chan = [1 .2 .4]; % Moderate ISI (Looks Decent)
% chan = [0.227 0.460 0.688 0.460 0.227]; % Severe ISI (Looks Nasty. Ewww)

% Danger! Do Not Uncomment Below
% ========================================================================
% ts = 1/1000;
% chan = rayleighchan(ts, 1);
% chan.pathDelays = [0 ts 2*ts];
% chan.AvgPathGaindB = [0 5 10];
% chan.StoreHistory = 1;
% ========================================================================

berVec = zeros(numIter, lenSNR);
brVec = zeros(numIter, lenSNR);
hw = waitbar(0, 'Please wait while your computer is heating up...');
for i = 1:numIter
    txBits = randi([0,1], 1, round(nSym * k / 3));
    txTurbo = step(hEnc, txBits.');
    tx = step(hEMod, txTurbo).';
    % Pick a Channel
    if isequal(chan, 1)
        txFiltered = tx;
    elseif isa(chan, 'channel.rayleigh')
        reset(chan);
        txFiltered = filter(chan, tx);
    else
        txFiltered = filter(chan, 1, tx);
    end
    for j = 1:lenSNR
        % Add Noise
        txFilteredAndNoise = awgn(txFiltered, SNR_Vec(j) + 10*log10(k * 1 / 3), 'measured');
        % Equalizer
        eq1 = dfe(3, 3, rls(0.99));
        eq1.SigConst = qammod(0:M-1, M);
        RefTap = 1;
        eq1.RefTap = RefTap;
        [rxEqualized, rxDetected] = equalize(eq1, txFilteredAndNoise, tx(1:train));
        rxEqualized = [rxEqualized(RefTap:end) zeros(1, RefTap-1)];
        rxTurbo = step(hDMod, rxEqualized.');
        % Plot signals.
        %h = scatterplot(txFilteredAndNoise, 1, train, 'bx'); hold on;
        %scatterplot(rxEqualized, 1, train, 'g.', h);
        %legend('Before Equalizer', 'After Equalizer'); hold off;
        % Decode
        rxBits = step(hDec, -rxTurbo).';
        txBits_1 = txBits((train + 1) * k : end-RefTap-5);
        rxBits_1 = rxBits((train + 1) * k : end-RefTap-5);
        [Discard, berVec(i,j)] = biterr(txBits_1, rxBits_1);
        % Count Bits
        brVec(i,j) = length(txBits_1);
        % Beautiful Wait Bar
        waitbar((i * lenSNR + j) / (numIter * lenSNR), hw);
    end
end
close(hw);

ber = mean(berVec, 1);
br = mean(brVec, 1);
BER_AT_12_SNR = ber(1)
BIT_RATE_AT_12_SNR = br(1)