function template_tlt = tilt_template(scheme, max_tilt_angle, tilt_increments, n_flip, add_zero)

% Number of tilts
seq_ntilt=((max_tilt_angle./tilt_increments).*2)+1;

% Generates tilt order for dose symmetric scheme and an n_flip of 2

seq=zeros(seq_ntilt,2);

if contains(scheme,'dose') & contains(scheme,'sym') & (contains(add_zero,'y'))
seq=zeros(1,2); 
for i=1:n_flip:seq_ntilt
    offset=i;
    for n=0:n_flip-1
        seq(end+1,2)=(offset+n)*tilt_increments;
    end
    for n=0:n_flip-1
        seq(end+1,2)=-(offset+n)*tilt_increments;
    end
end
elseif contains(scheme,'dose') & contains(scheme,'sym') & ~(contains(add_zero,'y'))
seq=[]; 
for i=1:n_flip:seq_ntilt
    offset=i;
    if offset==1
        for n=0:n_flip-1
            seq(end+1,2)=((offset+n)*tilt_increments) - tilt_increments;
        end
        for n=0:n_flip-1
            seq(end+1,2)=-(offset+n)*tilt_increments;
        end
    else
        for n=0:n_flip-1
            seq(end+1,2)=(offset+n)*tilt_increments - tilt_increments;
        end
        for n=0:n_flip-1
            seq(end+1,2)=-(offset+n)*tilt_increments;
        end
    end
end

elseif contains(scheme,'bidi') & contains(scheme,'+ve') 
seq(:,2) = [0:tilt_increments:max_tilt_angle,-tilt_increments:-tilt_increments:-max_tilt_angle]';
elseif contains(scheme,'bidi') & contains(scheme,'-ve') 
seq(:,2) = [0:-tilt_increments:-max_tilt_angle,tilt_increments:tilt_increments:max_tilt_angle]';
else
    disp('Sorry, this program does not currently support your choice of tilt scheme.')
    return
end

seq = seq(1:seq_ntilt,:);
seq(:,1)=[1:seq_ntilt];

template_tlt = seq;

end
