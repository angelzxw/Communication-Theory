function [tx, bits, gain] = txMosquito()
% Constants
fsep = 8e4;
nsamp = 16;
Fs = 120e4;
M = 16;

% Global feedback
global feedback_mosquito;
uint8(feedback_mosquito);

% Initialize feedback
if isempty(feedback_mosquito)
    feedback_mosquito = 0;
end

% Decode feedback variable
block_mosquito = bitand(feedback_mosquito, 15);
state_mosquito = bitand(bitshift(feedback_mosquito, -4), 15);

% Pick M value for modulation scheme
if state_mosquito == 0
    msgM = 4;
else
    msgM = 2;
end

% Generate correct number of bits for modulation scheme
k = log2(msgM);
bits = randi([0 1], 1024 * k, 1);

% Generate ice block
syms_garbage = repmat([0 1], 1, 512);
msg_garbage = qammod(syms_garbage, 4);
msgUp_garbage = rectpulse(msg_garbage, 16);

tx = zeros(1, 16384);
for tonecoeff = 1:15
    if block_mosquito == tonecoeff
        % Apply ice block to channel
        carrier = fskmod(tonecoeff * ones(1, 1024), M, fsep, nsamp, Fs);
        tx = tx + msgUp_garbage .* carrier;
    else
        % Invert bits on odd channels
        if mod(tonecoeff, 2) == 1
            bits_transmit = -1 * (bits - 1);
        else
            bits_transmit = bits;
        end
        % Apply low power signal to all other channels
        syms = bi2de(reshape(bits_transmit, k, length(bits_transmit) / k).', 'left-msb')';
        msg = pskmod(syms, msgM);
        msglength = length(msg);
        carrier = fskmod(tonecoeff * ones(1, msglength), M, fsep, nsamp, Fs);
        msgUp = rectpulse(msg, nsamp);
        tx = tx + msgUp .* carrier;
    end
end

% Normalize signal power
gain = std(tx);
tx = tx ./ gain;
end