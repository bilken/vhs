# Create m3u8s and static html for each clip. Link them in vhs.html.

content_path := content
script_path := scripts

# The clips in their original path
org_clip_path := $(if $(CONTENT_PATH),$(CONTENT_PATH),/media/billy/Backup1)
vhs_clip_path := $(org_clip_path)/vhs
8mm_clip_path := $(org_clip_path)/8mm
pre_clips := \
 $(shell find $(vhs_clip_path) -type f -name '*.ts') \
 $(shell find $(8mm_clip_path) -type f -name '*.ts') \

# If there are none, the caller probably goofed up the CONTENT_PATH
$(if $(pre_clips),,$(error No clips found))

# The clips (in the linked web path)
# Note how they're relative to the root of the org_clip_path
# Sub-directories from org_clip_path will be mirrored in the content_path
clips := $(patsubst $(org_clip_path)/%, $(content_path)/%, $(pre_clips))

# The IDR frame probe listing for each clip
probes := $(patsubst $(content_path)/%.ts, $(content_path)/%.probe, $(clips))

# A preview image for each clip
jpgs := $(patsubst %.probe, %.jpg, $(probes))

# The byte-range HLS child manifest
m3u8s := $(patsubst %.probe, %.m3u8, $(probes))

# The metadata file for web viewing (title, date, etc.)
metas := $(patsubst %.m3u8, %.meta, $(m3u8s))

# An html video clip, built from create_video_html.py
htmls := $(patsubst %.meta, %.html, $(metas))

# The root list of videos
root_html := vhs.html


.PHONY : all default install help clips clean
all default install : $(root_html)
clips : $(clips)

$(root_html) : $(htmls) $(metas) $(clips) $(m3u8s) $(probes) $(jpgs) $(script_path)/create_root_html.py
	$(script_path)/create_root_html.py $(metas) > $@

%.html : %.meta $(script_path)/create_video_html.py $(script_path)/video.template
	python $(script_path)/create_video_html.py $< > $@

# The touch fixes the case where it doesn't rewrite since attributes didn't change
%.meta : %.m3u8 %.ts %.jpg
	@echo sources: $^
	@echo target: $@
	w=`file $(word 3, $^) | sed 's;.* \([0-9]*\)x\([0-9]*\),.*;\1;g'`; \
    h=`file $(word 3, $^) | sed 's;.* \([0-9]*\)x\([0-9]*\),.*;\2;g'`; \
    python $(script_path)/metadata.py \
        -f "title:$(notdir $(word 1, $^))" \
        -f "hls:$(notdir $(word 1, $^))" \
        -f "ts:$(notdir $(word 2, $^))" \
        -f "jpg:$(notdir $(word 3, $^))" \
        -f "width:$$w" \
        -f "height:$$h" \
        $@
	touch $@

%.m3u8 : %.ts %.probe
	cat $(word 2, $^) | ../hls-byte-range.pl $(notdir $<) > $@

%.probe : %.ts
	../probe.pl $< > $@

%.jpg : %.ts
	ffmpeg -ss 5 -i $< -frames:v 1 $@ -y

$(content_path)/%.ts : $(org_clip_path)/%.ts
	@mkdir -p $(dir $@)
	ln -s $< $@

# Clean just the m3u8s. The probes take forever.
# For a full clean, delete the whole directory. But don't do that or
# you lose the meta content which will eventually be important.
clean :
	rm -f $(m3u8s)

help :
	@echo Build web accessible versions of TS video content
	@echo Override content path with "make CONTENT_PATH=..."

