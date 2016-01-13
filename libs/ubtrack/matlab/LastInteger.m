function [n, sn, prev] = LastInteger(s)

% last integer appearing in string s
% Return -1 if no integer found.
% Return also caracters of s preceding the last integer
% (useful for continuing processing s in the client code)
% Return also string version of n as found in s (incl prefix 0s)


n = -1;
prev = s;
% Find end of integer (pe)
found = 0;
for pe = length(s):(-1):1
    if IsDigit(s(pe))
        found = 1;
        break;
    end
end
if not(found)
    return;
end

% Find start of integer (ps)
ps = pe;
for ps = (pe-1):(-1):1
    if not(IsDigit(s(ps)))
        ps = ps + 1;
        break;
    end
end

sn = s(ps:pe);
n = str2num(sn);
prev = s(1:(ps-1));
