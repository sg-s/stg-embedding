% PURPOSE: generate envelop of average activity around phase plane of data
% INPUT:       data - horizontal array containing data to be analyzed
%                dt - time step across indices
%          varargin - low Pass frequency (default 5)
% OUTPUT:
%   oscillationMean - mean trajectory of oscillations
%    oscillationStd - standard deviation of trajectory
%            normVm - normalized voltage trace in terms of arc length
%           normdVm - normalized derivative of voltage in term of arc
%                     length

function [oscillationMean, oscillationStd, normVm, normdVm]...
    = phaseEnvelop(data, dt, varargin)

% check number of Inputs
if ~isempty(varargin)
    fPass = varargin{1};
else
    fPass = 5;
end

Vm = data;
dVm = WienerDeriv(Vm, dt);

% Low-pass filter results
wFilt = (2 * dt) * fPass;
[B,A] = butter(2, wFilt, 'low');
dVm_filt = filtfilt(B, A, dVm);
Vm_filt = filtfilt(B, A, Vm);

% remove filter run-in
dVm_filt = dVm_filt(floor(1/(fPass*dt)):end);
Vm_filt = Vm_filt(floor(1/(fPass*dt)):end);

% normalise amplitude
Vm_filt = Vm_filt/std(Vm_filt);
dVm_filt = dVm_filt/std(dVm_filt);

% reparametrise in terms of arc length
velocity = sqrt(diff(Vm_filt).^2 + diff(dVm_filt).^2);
Vm_filt = Vm_filt(1:end-1);
dVm_filt = dVm_filt(1:end-1);
s = cumsum(dt*velocity);

t_seg_norm = (1:length(s))/length(s);
s_norm = s/max(s);

% Vm, dVm as functions of arc-length
normVm = interp1(s_norm,Vm_filt,t_seg_norm);
normdVm = interp1(s_norm,dVm_filt,t_seg_norm);

% tossed the first numbers in array as sometimes is NaN
% had to hack not sure why this is the case
normVm(isnan(normVm)) = [];
normdVm(isnan(normdVm)) = [];

% center at origin
normVm = normVm - mean(normVm);
normdVm = normdVm - mean(normdVm);

theta = atan2(normdVm,normVm);
r = sqrt(normdVm.^2 + normVm.^2);

nbins = 200;

oscillationMean = zeros(1,nbins);
oscillationStd = 0*oscillationMean;

% calculate envelop
for j=0:nbins-1
    ang = (j/nbins)*2*pi - pi;
    nextang = ((j+1)/nbins)*(2*pi) - pi;
    oscillationMean(j+1) = mean(r(((theta < nextang) & (theta >= ang))));
    oscillationStd(j+1) = std(r(((theta < nextang) & (theta >= ang))));
end