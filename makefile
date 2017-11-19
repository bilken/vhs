
capture_path := capture
tmp_path := $(capture_path)
encode_path := /media/billy/Backup1/vhs/

ext := ts

captures := $(wildcard $(capture_path)/*.mkv)
encodes := $(patsubst $(capture_path)/%.mkv, $(encode_path)/%.$(ext), $(captures))

.PHONY : all default install clean
all default install : $(encodes)

# Trying to get IDR frames every 3 seconds on 25fps content
ENCODE_PARAMS := \
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
	ffmpeg -y -i $< $(ENCODE_PARAMS) $(tmp_path)/$(notdir $@)
	mv $(tmp_path)/$(notdir $@) $@

