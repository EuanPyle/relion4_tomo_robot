function template_tlt = tilt_template(scheme, max_tilt_angle, tilt_increments, n_flip)

% Number of tilts
seq_ntilt=((max_tilt_angle./tilt_increments).*2)+1;

seq=zeros(seq_ntilt,2); 

% Generates tilt order for dose symmetric scheme and an n_flip of 2

if scheme == 'dose_sym' & (n_flip == 2 | n_flip == '2')
for i=2:4:seq_ntilt
    seq(i,2)=seq(i-1,2)+tilt_increments;
    seq(i+1,2)=-seq(i,2);
    seq(i+2,2)=seq(i+1,2)-tilt_increments;
    seq(i+3,2)=-seq(i+2,2);
end
elseif scheme == 'dose_sym' & (n_flip == 3 | n_flip == '3')
for i=2:6:seq_ntilt
    seq(i,2)=seq(i-1,2)+tilt_increments; 
    seq(i+1,2)=seq(i-1,2)+(2*tilt_increments); 
    seq(i+2,2)=-seq(i,2); 
    seq(i+3,2)=-seq(i,2)-tilt_increments; 
    seq(i+4,2)=-seq(i,2)-(2*tilt_increments); 
    seq(i+5,2)=-seq(i+3,2)+(tilt_increments); 
end
elseif scheme == 'dose_sym' & (n_flip == 1 | n_flip == '1')
for i=2:2:seq_ntilt
    if seq(i-1,2) >= 0
    seq(i,2)=seq(i-1,2)+tilt_increments; 
    else
    seq(i,2)=-seq(i-1,2)+tilt_increments; 
    end
    seq(i+1,2)=-seq(i,2); 
end
else
    disp('Sorry, this program does not currently support your choice of tilt scheme.')
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADD OTHER DOSE SCHEMES HERE

seq = seq(1:seq_ntilt,:);
seq(:,1)=[1:seq_ntilt];

template_tlt = seq;

end
