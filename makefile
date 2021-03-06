
capture_path := capture
vhs_path := $(capture_path)/vhs
8mm_path := $(capture_path)/8mm

encode_path := $(if $(CONTENT_PATH),$(CONTENT_PATH),/media/billy/Backup1)

ext := ts

vhss := $(wildcard $(vhs_path)/*.mkv)
8mms := $(wildcard $(8mm_path)/*.MP4)
encodes := \
 $(patsubst $(capture_path)/%.mkv, $(encode_path)/%.$(ext), $(vhss)) \
 $(patsubst $(capture_path)/%.MP4, $(encode_path)/%.$(ext), $(8mms)) \

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
# The select(...) piece below removes those fuzzy duplicates with the given tolerance
# I have it disabled right now because I'd rather ff in the player than lose content
CUT_DUPLICATES := \
 -vf "select='if(gt(scene,0.01),st(1,t),lte(t-ld(1),1))',setpts=N/FRAME_RATE/TB" \

# The -i anullsrc=... adds silent audio which fixes the HLS player scrub bar ('cause I'm bad at js)
8MM_PARAMS := \
 -hide_banner \
 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=32000 -c:a aac -shortest \
 -threads auto \
 -s 720x540 \
 -vcodec libx264 \
 -pix_fmt yuv420p \
 -force_key_frames "expr:eq(mod(n,60),0)" \
 -x264opts crf=18:rc-lookahead=60:keyint=120:min-keyint=60 \
 -preset slow \
 -maxrate 1.5M -bufsize 3M \

$(encode_path)/%.$(ext) : $(capture_path)/%.MP4
	@mkdir -p $(dir $@)
	ffmpeg -y -i $< $(8MM_PARAMS) $(dir $<)/$(notdir $@)
	mv $(dir $<)/$(notdir $@) $@

