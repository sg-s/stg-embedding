function d = ISIDist_core(A,B)

	d = 0;

	if isempty(A)
		A = 0;
	end

	if isempty(B)
		B = 0;
	end

	for k = 1:length(A)
		d = d + min(abs(A(k) - B));
	end

	for k = 1:length(B)
		d = d + min(abs(B(k) - A));
	end

	% normalize
	d = d/(length(B) + length(A));


end
