% make a given patch object highlighted
% with a thick black border

function boxPatch(ph)

arguments
	ph (1,1) matlab.graphics.primitive.Patch
end

ph.EdgeColor = [0 0 0];
ph.LineWidth = 2.5;
uistack(ph,'top');