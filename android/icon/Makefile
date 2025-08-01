# NAME must contain only lowercase letters, numbers, or underscores.
NAME=love2d_camera_demo

ICON=selfie.png

SIPS=sips --setProperty format png --setProperty formatOptions best

.PHONY: apk-icon
apk-icon: $(ICON)
	$(SIPS) --resampleHeightWidthMax 36 $(ICON) --out $(NAME)-ldpi.png
	$(SIPS) --resampleHeightWidthMax 48 $(ICON) --out $(NAME)-mdpi.png
	$(SIPS) --resampleHeightWidthMax 72 $(ICON) --out $(NAME)-hdpi.png
	$(SIPS) --resampleHeightWidthMax 96 $(ICON) --out $(NAME)-xhdpi.png
	$(SIPS) --resampleHeightWidthMax 144 $(ICON) --out $(NAME)-xxhdpi.png
	$(SIPS) --resampleHeightWidthMax 192 $(ICON) --out $(NAME)-xxxhdpi.png
