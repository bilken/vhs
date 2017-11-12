# Create m3u8s and static html for each clip. Link them in vhs.html.

content_path := content
script_path := scripts

# The clips in their original path
org_clip_path := $(if $(CONTENT_PATH),$(CONTENT_PATH),/home/billy/Desktop/vhs/content)
pre_clips := $(shell find $(org_clip_path) -type f -name '*.ts')

# If there are none, the caller probably goofed up the CONTENT_PATH
$(if $(pre_clips),,$(error No clips found at $(org_clip_path)/))

# The clips (in the linked web path)
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


.PHONY : all default install help clips
all default install : $(root_html)
clips : $(clips)

$(root_html) : $(clips) $(htmls) $(metas) $(m3u8s) $(probes) $(jpgs)
	echo "<!DOCTYPE html><html><head><title>Videos</title></head><body>" > $@
	for n in $(patsubst %.html,%,$(htmls)); do \
        echo "<div>" >> $@; \
        echo "  <a href=\"$$n.html\">" >> $@; \
        echo "    <img src=\"$$n.jpg\" height=\"60\" />" >> $@; \
        echo "</a>" >> $@; \
        echo "</div>" >> $@; \
        done;
	echo "</body></html>" >> $@

%.html : %.meta %.m3u8 %.jpg
	python $(script_path)/create_video_html.py $< $(addprefix /,$(filter-out %.meta,$^)) > $@

# The touch fixes the case where it doesn't rewrite since attributes didn't change
%.meta : %.m3u8
	python $(script_path)/metadata.py -f "hls:$(notdir $<)" $@
	touch $@

%.m3u8 : %.probe
	cat $< | ../hls-byte-range.pl $(patsubst %.m3u8,%.ts,$(notdir $@)) > $@

$(content_path)/%.probe : $(content_path)/%.ts
	../probe.pl $< > $@

$(content_path)/%.jpg : $(content_path)/%.ts
	ffmpeg -loglevel panic -ss 15 -i $< -frames:v 1 $@ -y

$(content_path)/%.ts : $(org_clip_path)/%.ts
	@mkdir -p $(dir $@)
	ln -s $< $@

help :
	@echo Build web accessible versions of TS video content
	@echo Override content path with "make CONTENT_PATH=..."

