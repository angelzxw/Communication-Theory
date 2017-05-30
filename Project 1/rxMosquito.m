function [numCorrect] = rxMosquito(sig, bits, gain)
% Constants
fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;

% Global feedback
global feedback_mosquito;
uint8(feedback_mosquito);

% Decode feedback variable
block_mosquito = bitand(feedback_mosquito, 15);
state_mosquito = bitand(bitshift(feedback_mosquito, -4), 15);

% Pick M value for modulation scheme
if state_mosquito == 0
    msgM = 4;
else
    msgM = 2;
end

% Initialize bit matrix and signal detector
bitmatrix = [];
power_score = zeros(1, 15);
for tonecoeff = 1:15
    % Skip ice block channel
    if tonecoeff == block_mosquito
        continue
    end
    % Decode low power signal from all other channels
    carrier = fskmod(tonecoeff * ones(1,1024), M, fsep, nsamp, Fs);
    rx = sig .* conj(carrier);
    rx = intdump(rx, nsamp);
    power_score(tonecoeff) = std(rx);
    rxMsg = pskdemod(rx, msgM);
    rx1 = de2bi(rxMsg,'left-msb');
    rx2 = reshape(rx1.',numel(rx1),1);
    rxBits = de2bi(rx2);
    rxBits = rxBits(:);
    % Remember to invert bits on odd channels
    if mod(tonecoeff, 2) == 1
        rxBits = -1 * (rxBits - 1);
    else
        rxBits = bits;
    end
    bitmatrix = [bitmatrix rxBits];
end

% Organize signal detector matrix
power_score = power_score / max(power_score);
power_score(power_score < 0.7) = 0;
power_score(power_score >= 0.7) = 1;
if sum(power_score) > 7
    power_score(:) = 0;
end

% Detect highest power channel as enemy
block_mosquito = 0;
for chid = 1:15
    if power_score(chid) == 1
        block_mosquito = chid;
        break;
    end
end

% Decrease prediction
if state_mosquito > 0
    state_mosquito = state_mosquito - 1;
end

% Maxvote to retrieve signal
rxBits = mode(bitmatrix, 2);

ber = biterr(rxBits, bits);
if ber == 0
    numCorrect = length(bits);
else
    numCorrect = 0;
    state_mosquito = 2;
end

feedback_mosquito = bitshift(state_mosquito, 4) + block_mosquito;
end