function d = extract_depth(profiles)

N = length(profiles);
L = length(profiles{1}.H);
mid = round(L/2);

d = zeros(1,N);

for k=1:N
    d(k) = min(profiles{k}.H(mid-10:mid+10));
end