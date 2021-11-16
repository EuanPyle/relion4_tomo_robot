function [newst_com, tilt_com] = template_generator

%Default values for template com files
TS = '100';
x_dim = '5760';
y_dim = '4092';
thickness = '3000';
%%%

newst_com = ['$newstack -StandardInput' newline 'InputFile	TS_' TS '.st' newline 'OutputFile	TS_' TS '.ali' newline 'TransformFile	TS_' TS '.xf' newline 'TaperAtFill	1,0' newline 'AdjustOrigin' newline 'SizeToOutputInXandY	' y_dim ',' x_dim '' newline 'OffsetsInXandY	0.0,0.0' newline '#DistortionField	.idf' newline 'ImagesAreBinned	1.0' newline 'BinByFactor	1' newline '#GradientFile	TS_' TS '.maggrad' newline '$if (-e ./savework) ./savework' newline];


tilt_com = ['$tilt -StandardInput' newline 'InputProjections TS_' TS '.ali' newline 'OutputFile TS_' TS '_full.rec' newline 'IMAGEBINNED 1' newline 'TILTFILE TS_' TS '.tlt' newline 'THICKNESS ' thickness '' newline 'FalloffIsTrueSigma 1' newline 'XAXISTILT 0.0' newline 'LOG 0.0' newline 'SCALE 0.0 250.0' newline 'PERPENDICULAR' newline 'MODE 2' newline 'FULLIMAGE ' y_dim ' ' x_dim '' newline 'SUBSETSTART 0 0' newline 'AdjustOrigin' newline 'ActionIfGPUFails 1,2' newline 'XTILTFILE TS_' TS '.xtilt' newline 'OFFSET 0.0' newline 'SHIFT 0.0 0.0' newline 'FakeSIRTiterations 50' newline '$if (-e ./savework) ./savework' newline];

fileID = fopen('template_newst.com','w');
fprintf(fileID, '%s',newst_com);
fclose(fileID);

fileID = fopen('template_tilt.com','w');
fprintf(fileID, '%s',tilt_com);
fclose(fileID);
end
