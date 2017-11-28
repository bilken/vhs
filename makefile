
capture_path := capture
vhs_path := $(capture_path)/vhs
8mm_path := $(capture_path)/8mm

encode_path := /media/billy/Backup1/

ext := ts

vhss := $(wildcard $(vhs_path)/*.mkv)
8mms := $(wildcard $(8mm_path)/*.MP4)
encodes := \
 $(patsubst $(capture_path)/%.mkv, $(encode_path)/%.$(ext), $(vhss)) \
 $(patsubst $(capture_path)/%.mkv, $(encode_path)/%.$(ext), $(8mms)) \

.PHONY : all default install clean
all default install : $(encodes)

# Trying to get IDR frames every 3 seconds on 25fps content
VHS_PARAMS := \
 -hide_banner \
 -threads auto \
 -vcodec libx264 \
 -force_key_frames "expr:eq(mod(n,75),0)" \
 -x264opts crf=18:rc-lookahead=75:keyint=150:min-keyint=75 \
 -preset slow \
 -maxrate 1.5M -bufsize 3M \
 -acodec aac \
 -vsync 2 \

# This rule writes to tmp.* so that make doesn't delete it on ctrl-c.
$(encode_path)/%.$(ext) : $(capture_path)/%.mkv
	@mkdir -p $(dir $@)
	ffmpeg -y -i $< $(VHS_PARAMS) $(dir $<)/$(notdir $@)
	mv $(dir $<)/$(notdir $@) $@

# The 8mm capture device I have sometimes gets stuck on a frame.
# The select(...0.05...) piece below removes those fuzzy duplicates with the 0.05 being the tolerance
8MM_PARAMS := \
 -hide_banner \
 -threads auto \
 -s 720x540 \
 -vf "select='if(gt(scene,0.05),st(1,t),lte(t-ld(1),1))',setpts=N/FRAME_RATE/TB" \
 -vcodec libx264 \
 -force_key_frames "expr:eq(mod(n,60),0)" \
 -x264opts crf=18:rc-lookahead=60:keyint=120:min-keyint=60 \
 -preset slow \
 -maxrate 1.5M -bufsize 3M \

$(encode_path)/%.$(ext) : $(capture_path)/%.MP4
	@mkdir -p $(dir $@)
	ffmpeg -y -i $< $(8MM_PARAMS) $(dir $<)/$(notdir $@)
	mv $(dir $<)/$(notdir $@) $@

