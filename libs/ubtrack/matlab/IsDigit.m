function b = IsDigit(c)

% true iff char c is a digit

b = (floor(c) >= floor('0') & floor(c) <= floor('9'));
