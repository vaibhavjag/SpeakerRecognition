function output = normalizevalues(array,dim)
	if nargin < 2 
		[r,c] = size(array);
		if r == 1 && c>1
			dim = 2;
		elseif c == 1 && r > 1
			dim = 1;
		elseif c == 1 && r == 1
			output = [1];
			return
		end
	end
	max_array = max(array,[],dim);
	min_array = min(array,[],dim);
	output = bsxfun(@rdivide,bsxfun(@minus, array, min_array),max_array-min_array);
end